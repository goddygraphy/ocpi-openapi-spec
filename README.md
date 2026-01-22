# OCPI OpenAPI Specification

Unofficial, open-source OpenAPI 3.1.0 specification for the Open Charge Point Interface (OCPI) protocol.

## ⚠️ Legal Disclaimer

**This repository contains an unofficial, open-source OpenAPI definition for the OCPI protocol. It allows for code generation and validation. This project is not affiliated with the EVRoaming Foundation.**

All descriptive text has been rewritten or omitted to respect the [CC BY-ND 4.0 license](https://creativecommons.org/licenses/by-nd/4.0/deed.en) of the official documentation. This specification includes only functional requirements (field names, types, structures) necessary for interoperability, not expressive content from the official documentation.

The official OCPI standard can be downloaded from the [EVRoaming Foundation website](https://evroaming.org/ocpi-downloads/).

## Overview

This repository provides machine-readable OpenAPI specifications for OCPI versions 2.2.1 and (future) 2.3.0. These specifications enable:

- **Code Generation**: Generate client and server stubs in any language
- **API Validation**: Validate requests and responses against the specification
- **Documentation**: Auto-generate API documentation
- **Testing**: Create test suites from the specification

## Supported Versions

- **OCPI 2.2.1** ✅ (Current workhorse of the European industry)
- **OCPI 2.3.0** 🚧 (Planned - includes AFIR compliance features)

## Quick Start

### Prerequisites

Before using or contributing, install the required validation tools:

```bash
# Required tools
npm install -g swagger-cli @stoplight/spectral-cli

# Optional but recommended (for YAML syntax checking)
pip install yamllint
# Or on macOS:
brew install yamllint
```

### Using the Specification

The main specification file is located at `2.2.1/ocpi-2.2.1.yaml`.

#### Generate Code with OpenAPI Generator

```bash
# Install OpenAPI Generator
npm install @openapitools/openapi-generator-cli -g

# Generate TypeScript client
openapi-generator-cli generate \
  -i 2.2.1/ocpi-2.2.1.yaml \
  -g typescript-axios \
  -o ./generated/typescript-client

# Generate Python client
openapi-generator-cli generate \
  -i 2.2.1/ocpi-2.2.1.yaml \
  -g python \
  -o ./generated/python-client

# Generate Go server
openapi-generator-cli generate \
  -i 2.2.1/ocpi-2.2.1.yaml \
  -g go-gin-server \
  -o ./generated/go-server
```

#### Validate the Specification

**Recommended**: Use the local validation script which runs all checks:

```bash
# Validate a specific version (runs all CI checks)
./scripts/validate.sh 2.2.1

# Or validate all available versions
./scripts/validate.sh
```

**Manual validation** (if you prefer individual tools):

```bash
# Validate OpenAPI structure
swagger-cli validate 2.2.1/ocpi-2.2.1.yaml

# Lint with Spectral (uses .spectral.yaml ruleset)
spectral lint 2.2.1/ocpi-2.2.1.yaml

# Check YAML syntax (optional)
yamllint 2.2.1/ocpi-2.2.1.yaml

# Bundle to test all $ref references resolve
swagger-cli bundle 2.2.1/ocpi-2.2.1.yaml -o /tmp/bundled.yaml
swagger-cli validate /tmp/bundled.yaml
```

#### View Documentation

```bash
# Using swagger-ui
npx swagger-ui-watcher 2.2.1/ocpi-2.2.1.yaml

# Or use online tools like Swagger Editor
# https://editor.swagger.io/
```

## Repository Structure

```
ocpi-openapi-spec/
├── 2.2.1/
│   ├── ocpi-2.2.1.yaml          # Main specification (references modules)
│   ├── modules/                  # Module-specific schemas and paths
│   │   ├── tokens.yaml          # Tokens module (Module 2)
│   │   ├── locations.yaml       # Locations module (Module 4)
│   │   ├── sessions.yaml         # Sessions module (Module 5)
│   │   ├── cdrs.yaml            # CDRs module (Module 6)
│   │   ├── tariffs.yaml         # Tariffs module (Module 7)
│   │   ├── commands.yaml        # Commands module (Module 8)
│   │   └── hub.yaml             # Hub Client Info module (Module 9)
│   └── components/              # Shared components
│       ├── parameters.yaml      # Reusable query parameters
│       └── responses.yaml       # Reusable response definitions
├── 2.3.0/                       # Future version
├── common/
│   └── definitions.yaml         # Shared type definitions across versions
├── .github/
│   └── workflows/
│       └── validate.yml         # CI/CD validation (supports multiple versions)
├── .spectral.yaml               # Spectral linting ruleset configuration
├── scripts/
│   └── validate.sh              # Local validation script (run before PRs)
└── docs/
    └── Open Source OCPI OpenAPI Strategy.md
```

## Specification Features

- **Modular Architecture**: Organized into reusable modules and components for maintainability
- **Unified Entry Point**: Single main specification file (`ocpi-2.2.1.yaml`) that references modular components
- **Complete Coverage**: All OCPI 2.2.1 modules implemented
  - Tokens (Module 2)
  - Locations (Module 4)
  - Sessions (Module 5)
  - CDRs (Module 6)
  - Tariffs (Module 7)
  - Commands (Module 8)
  - Hub Client Info (Module 9)
- **Strict Typing**: Proper data types, formats, and validation rules
- **Role Documentation**: Clear indication of CPO/eMSP operations
- **Push/Pull Support**: Models both pull (GET) and push (PUT) operations
- **Quality Assurance**: Automated validation with swagger-cli, Spectral linting, and yamllint
- **Operation IDs**: All operations include `operationId` for code generation compatibility

## Contributing

Contributions are welcome! This project follows a "Clean Room" methodology to respect the CC BY-ND 4.0 license of the official OCPI documentation.

### Legal Compliance Guidelines

**Critical**: Never copy descriptive text from the official OCPI PDF or documentation. This project includes only functional requirements (field names, types, structures) necessary for interoperability.

**Sanitization Rules**:
- ✅ **Keep**: Object names, field names, data types, enum values (functional requirements)
- ✅ **Keep**: Field constraints (maxLength, minLength, required, etc.)
- ❌ **Don't Copy**: Long-form explanatory text, examples from official docs
- ✅ **Do Instead**: Write functional summaries or link to official spec sections

**Example**:
- ❌ Bad: "The address of the location where the EVSEs are installed. This field is mandatory and should contain the complete street address."
- ✅ Good: "Street address. See OCPI Spec 2.2.1 Module 4."

### Development Workflow

1. **Fork and Clone**: Fork the repository and clone your fork
2. **Create Branch**: Create a feature branch (`git checkout -b feature/your-feature`)
3. **Make Changes**: 
   - Follow the sanitization rules above
   - Ensure all `$ref` references resolve correctly
   - Use proper OpenAPI 3.1.0 syntax
   - Module-specific changes should be made in `2.2.1/modules/`
   - Shared components go in `2.2.1/components/` or `common/`
4. **Validate**: Run validation before committing:
   
   **Recommended**: Use the local validation script (runs all CI checks):
   ```bash
   # Validate a specific version
   ./scripts/validate.sh 2.2.1
   
   # Or validate all available versions
   ./scripts/validate.sh
   ```
   
   The validation script performs:
   - ✅ YAML syntax checking (yamllint) - optional but recommended
   - ✅ OpenAPI structure validation (swagger-cli)
   - ✅ Spectral linting with ruleset (`.spectral.yaml`)
   - ✅ Reference resolution testing (bundling)
   - ✅ Bundled specification validation
   
   **Manual validation** (if you prefer individual tools):
   ```bash
   # Validate the main specification (validates all referenced modules)
   swagger-cli validate 2.2.1/ocpi-2.2.1.yaml
   
   # Lint with Spectral (uses .spectral.yaml ruleset)
   spectral lint 2.2.1/ocpi-2.2.1.yaml
   
   # Bundle to test all $ref references resolve
   swagger-cli bundle 2.2.1/ocpi-2.2.1.yaml -o /tmp/bundled.yaml
   swagger-cli validate /tmp/bundled.yaml
   ```
5. **Test**: Ensure the specification can be used for code generation
6. **Commit**: Write clear commit messages
7. **Push and PR**: Push to your fork and create a pull request

### Validation Requirements

All pull requests must:
- ✅ Pass `swagger-cli validate` without errors
- ✅ Have all `$ref` references resolve correctly (tested via bundling)
- ✅ Pass Spectral linting checks (warnings are treated as errors)
- ✅ Pass YAML syntax checks (yamllint) - required in CI, optional locally
- ✅ Follow OpenAPI 3.1.0 specification standards
- ✅ Maintain legal compliance (no copied text)

**Quick Check**: Run `./scripts/validate.sh` before opening a PR to ensure all checks pass locally. This script runs the same validations as the CI workflow.

**Note**: The CI workflow will fail if:
- Any Spectral linting warnings are found (configured in `.spectral.yaml`)
- YAML syntax errors are detected
- OpenAPI validation fails
- Reference resolution fails during bundling

### Reporting Issues

When reporting issues:
- Describe the problem clearly
- Include the OCPI version (2.2.1)
- Reference the relevant module if applicable
- Link to the official OCPI spec section if relevant

## License

This project is licensed under the Apache License 2.0. See [LICENSE](LICENSE) for details.

## Resources

- [EVRoaming Foundation](https://evroaming.org/)
- [OCPI Official Downloads](https://evroaming.org/ocpi-downloads/)
- [OpenAPI Specification](https://swagger.io/specification/)

## Status

This is an active project. The OCPI 2.2.1 specification is being developed and validated. Check the [Issues](https://github.com/yourusername/ocpi-openapi-spec/issues) for current status and known limitations.
