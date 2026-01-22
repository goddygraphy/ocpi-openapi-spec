#!/bin/bash

# OCPI OpenAPI Specification Local Validation Script
# This script runs the same validations as the CI workflow locally
# Usage: ./scripts/validate.sh [version]
# Example: ./scripts/validate.sh 2.2.1

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check required tools
check_tools() {
    local missing_tools=()
    
    if ! command_exists swagger-cli; then
        missing_tools+=("swagger-cli")
    fi
    
    if ! command_exists spectral; then
        missing_tools+=("spectral")
    fi
    
    if [ ${#missing_tools[@]} -gt 0 ]; then
        print_error "Missing required tools: ${missing_tools[*]}"
        echo ""
        echo "Install missing tools with:"
        for tool in "${missing_tools[@]}"; do
            case $tool in
                swagger-cli)
                    echo "  npm install -g swagger-cli"
                    ;;
                spectral)
                    echo "  npm install -g @stoplight/spectral-cli"
                    ;;
            esac
        done
        exit 1
    fi
}

# Function to validate a version
validate_version() {
    local version=$1
    local version_dir="$version"
    local spec_file="$version_dir/ocpi-$version.yaml"
    
    print_info "Validating OCPI version: $version"
    echo ""
    
    # Check if version directory exists
    if [ ! -d "$version_dir" ]; then
        print_warning "Version directory '$version_dir' not found, skipping..."
        return 0
    fi
    
    # Check if main spec file exists
    if [ ! -f "$spec_file" ]; then
        print_error "Main specification file '$spec_file' not found!"
        return 1
    fi
    
    # Validate common definitions (if they exist)
    if [ -f "common/definitions.yaml" ]; then
        print_info "Validating common definitions..."
        if swagger-cli validate common/definitions.yaml 2>/dev/null; then
            print_success "Common definitions validated"
        else
            print_warning "common/definitions.yaml is not a complete OpenAPI spec (expected)"
        fi
        echo ""
    fi
    
    # Validate component files (YAML syntax check)
    if [ -d "$version_dir/components" ]; then
        print_info "Checking component files for $version..."
        local component_files=()
        
        if [ -f "$version_dir/components/parameters.yaml" ]; then
            component_files+=("$version_dir/components/parameters.yaml")
        fi
        
        if [ -f "$version_dir/components/responses.yaml" ]; then
            component_files+=("$version_dir/components/responses.yaml")
        fi
        
        if [ ${#component_files[@]} -gt 0 ]; then
            for file in "${component_files[@]}"; do
                if command_exists yamllint; then
                    if yamllint "$file" 2>&1; then
                        print_success "YAML syntax OK: $(basename $file)"
                    else
                        print_error "YAML syntax issues in: $(basename $file)"
                        yamllint "$file" 2>&1 || true
                        return 1
                    fi
                else
                    print_warning "yamllint not installed, skipping YAML syntax check for components"
                    echo "  Install with: pip install yamllint (or: brew install yamllint)"
                fi
            done
        fi
        echo ""
    fi
    
    # Validate module files (YAML syntax check)
    if [ -d "$version_dir/modules" ]; then
        print_info "Checking module files for $version..."
        local module_count=0
        local module_errors=0
        
        for file in "$version_dir/modules"/*.yaml; do
            if [ -f "$file" ]; then
                module_count=$((module_count + 1))
                if command_exists yamllint; then
                    if yamllint "$file" 2>&1; then
                        print_success "YAML syntax OK: $(basename $file)"
                    else
                        print_error "YAML syntax issues in: $(basename $file)"
                        yamllint "$file" 2>&1 || true
                        module_errors=$((module_errors + 1))
                    fi
                else
                    print_warning "yamllint not installed, skipping YAML syntax check for modules"
                    echo "  Install with: pip install yamllint (or: brew install yamllint)"
                    break
                fi
            fi
        done
        
        if [ $module_errors -gt 0 ]; then
            print_error "Found $module_errors module file(s) with YAML syntax errors"
            return 1
        fi
        
        if [ $module_count -eq 0 ]; then
            print_warning "No module files found in $version_dir/modules/"
        fi
        echo ""
    fi
    
    # Validate main OpenAPI specification
    print_info "Validating OpenAPI specification: $spec_file"
    if swagger-cli validate "$spec_file"; then
        print_success "OpenAPI specification is valid"
    else
        print_error "OpenAPI specification validation failed!"
        return 1
    fi
    echo ""
    
    # Lint with Spectral
    print_info "Linting with Spectral..."
    local spectral_output
    if spectral_output=$(spectral lint "$spec_file" 2>&1); then
        print_success "Spectral linting passed"
    else
        print_error "Spectral linting found issues:"
        echo "$spectral_output"
        return 1
    fi
    echo ""
    
    # Bundle specification (test all $ref references)
    print_info "Bundling specification to test \$ref resolution..."
    local bundled_file="/tmp/bundled-$version.yaml"
    if swagger-cli bundle "$spec_file" -o "$bundled_file" >/dev/null 2>&1; then
        print_success "All \$ref references resolved successfully"
        print_info "Bundled specification created at: $bundled_file"
        
        # Validate bundled specification
        print_info "Validating bundled specification..."
        if swagger-cli validate "$bundled_file" >/dev/null 2>&1; then
            print_success "Bundled specification is valid"
        else
            print_error "Bundled specification validation failed!"
            return 1
        fi
    else
        print_error "Failed to bundle specification - \$ref references may not resolve!"
        return 1
    fi
    echo ""
    
    print_success "All validations passed for version $version!"
    return 0
}

# Main execution
main() {
    echo "=========================================="
    echo "OCPI OpenAPI Specification Validator"
    echo "=========================================="
    echo ""
    
    # Check required tools
    print_info "Checking required tools..."
    check_tools
    print_success "All required tools are installed"
    echo ""
    
    # Determine which version(s) to validate
    local versions=()
    
    if [ $# -eq 0 ]; then
        # No version specified, find all version directories
        print_info "No version specified, validating all available versions..."
        for dir in [0-9]*.[0-9]*.[0-9]*/; do
            if [ -d "$dir" ]; then
                versions+=("$(basename "$dir")")
            fi
        done
        
        if [ ${#versions[@]} -eq 0 ]; then
            print_error "No version directories found!"
            echo ""
            echo "Usage: $0 [version]"
            echo "Example: $0 2.2.1"
            exit 1
        fi
    else
        versions=("$1")
    fi
    
    # Validate each version
    local failed=0
    for version in "${versions[@]}"; do
        if ! validate_version "$version"; then
            failed=1
        fi
        echo "------------------------------------------"
        echo ""
    done
    
    # Summary
    if [ $failed -eq 0 ]; then
        echo "=========================================="
        print_success "All validations passed!"
        echo "=========================================="
        exit 0
    else
        echo "=========================================="
        print_error "Some validations failed!"
        echo "=========================================="
        exit 1
    fi
}

# Run main function
main "$@"
