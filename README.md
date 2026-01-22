# OCPI OpenAPI Specification

Unofficial, open-source OpenAPI 3.1.0 specification for the Open Charge Point Interface (OCPI) protocol.

## ⚠️ Legal Disclaimer

**This repository contains an unofficial, open-source OpenAPI definition for the OCPI protocol. It allows for code generation and validation. This project is not affiliated with the EVRoaming Foundation.**

All descriptive text has been rewritten or omitted to respect the [CC BY-ND 4.0 license](https://creativecommons.org/licenses/by-nd/4.0/deed.en) of the official documentation. This specification includes only functional requirements (field names, types, structures) necessary for interoperability, not expressive content from the official documentation.

The official OCPI standard can be downloaded from the [EVRoaming Foundation website](https://evroaming.org/ocpi-downloads/).

## Overview

This repository provides machine-readable OpenAPI specifications for OCPI versions 2.2.1 and 2.3.0. These specifications enable:

- **Code Generation**: Generate client and server stubs in any language
- **API Validation**: Validate requests and responses against the specification
- **Documentation**: Auto-generate API documentation
- **Testing**: Create test suites from the specification

## Supported Versions

- **OCPI 2.2.1** ✅ (Current workhorse of the European industry)
- **OCPI 2.3.0** ✅ (Includes AFIR compliance, Booking module, and enhanced features)

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

The main specification files are located at:
- `2.2.1/ocpi-2.2.1.yaml` (OCPI 2.2.1)
- `2.3.0/ocpi-2.3.0.yaml` (OCPI 2.3.0)

#### Generate Code with OpenAPI Generator

```bash
# Install OpenAPI Generator
npm install @openapitools/openapi-generator-cli -g

# Generate TypeScript client (2.2.1)
openapi-generator-cli generate \
  -i 2.2.1/ocpi-2.2.1.yaml \
  -g typescript-axios \
  -o ./generated/typescript-client-2.2.1

# Generate TypeScript client (2.3.0)
openapi-generator-cli generate \
  -i 2.3.0/ocpi-2.3.0.yaml \
  -g typescript-axios \
  -o ./generated/typescript-client-2.3.0

# Generate Python client (2.3.0)
openapi-generator-cli generate \
  -i 2.3.0/ocpi-2.3.0.yaml \
  -g python \
  -o ./generated/python-client-2.3.0

# Generate Go server (2.2.1)
openapi-generator-cli generate \
  -i 2.2.1/ocpi-2.2.1.yaml \
  -g go-gin-server \
  -o ./generated/go-server-2.2.1
```

#### Validate the Specification

**Recommended**: Use the local validation script which runs all checks:

```bash
# Validate a specific version (runs all CI checks)
./scripts/validate.sh 2.3.0

# Or validate all available versions
./scripts/validate.sh
```

**Manual validation** (if you prefer individual tools):

```bash
# Note: The main spec files reference modular components, so validation must be done on the bundled spec

# Bundle the specification (resolves all $ref references)
swagger-cli bundle 2.2.1/ocpi-2.2.1.yaml -o /tmp/bundled-2.2.1.yaml
swagger-cli bundle 2.3.0/ocpi-2.3.0.yaml -o /tmp/bundled-2.3.0.yaml

# Validate the bundled specification
swagger-cli validate /tmp/bundled-2.2.1.yaml
swagger-cli validate /tmp/bundled-2.3.0.yaml

# Lint the bundled specification with Spectral (uses .spectral.yaml ruleset)
spectral lint /tmp/bundled-2.2.1.yaml
spectral lint /tmp/bundled-2.3.0.yaml

# Check YAML syntax on individual files (optional)
yamllint 2.2.1/ocpi-2.2.1.yaml
yamllint 2.3.0/ocpi-2.3.0.yaml
```

#### View Documentation

```bash
# Using swagger-ui (2.2.1)
npx swagger-ui-watcher 2.2.1/ocpi-2.2.1.yaml

# Using swagger-ui (2.3.0)
npx swagger-ui-watcher 2.3.0/ocpi-2.3.0.yaml

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
├── 2.3.0/
│   ├── ocpi-2.3.0.yaml          # Main specification (references modules)
│   ├── modules/                  # Module-specific schemas and paths
│   │   ├── tokens.yaml          # Tokens module (Module 2)
│   │   ├── locations.yaml       # Locations module (Module 4) - AFIR compliant
│   │   ├── sessions.yaml         # Sessions module (Module 5)
│   │   ├── cdrs.yaml            # CDRs module (Module 6)
│   │   ├── tariffs.yaml         # Tariffs module (Module 7)
│   │   ├── commands.yaml        # Commands module (Module 8)
│   │   ├── hub.yaml             # Hub Client Info module (Module 9)
│   │   └── booking.yaml         # Booking module (Module 10) - NEW in 2.3.0
│   └── components/              # Shared components
│       ├── parameters.yaml      # Reusable query parameters
│       └── responses.yaml       # Reusable response definitions
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
- **Unified Entry Point**: Single main specification file per version (`ocpi-2.2.1.yaml`, `ocpi-2.3.0.yaml`) that references modular components
- **Complete Coverage**: All OCPI modules implemented
  - **OCPI 2.2.1**: Tokens, Locations, Sessions, CDRs, Tariffs, Commands, Hub Client Info
  - **OCPI 2.3.0**: All 2.2.1 modules plus:
    - Booking module (Module 10) - NEW
    - AFIR compliance features in Locations module
    - Enhanced EVSE capabilities (PLUG_AND_CHARGE, PAYMENT_TERMINAL)
    - Ad-hoc payment terminal support
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
- ✅ Good (2.2.1): "Street address. See OCPI Spec 2.2.1 Module 4."
- ✅ Good (2.3.0): "Booking identifier. See OCPI Spec 2.3.0 Module 10."

### Development Workflow

1. **Fork and Clone**: Fork the repository and clone your fork
2. **Create Branch**: Create a feature branch (`git checkout -b feature/your-feature`)
3. **Make Changes**: 
   - Follow the sanitization rules above
   - Ensure all `$ref` references resolve correctly
   - Use proper OpenAPI 3.1.0 syntax
   - Module-specific changes should be made in version-specific directories (e.g., `2.2.1/modules/`, `2.3.0/modules/`)
   - Shared components go in version-specific `components/` directories or `common/`
4. **Validate**: Run validation before committing:
   
   Use the local validation script (runs all CI checks):
   ```bash
   # Validate a specific version
   ./scripts/validate.sh 2.3.0
   
   # Or validate all available versions
   ./scripts/validate.sh
   ```
   
   The validation script performs:
   - ✅ YAML syntax checking (yamllint) on individual files
   - ✅ Bundling the specification (resolves all $ref references)
   - ✅ OpenAPI structure validation on bundled spec (swagger-cli)
   - ✅ Spectral linting on bundled spec (`.spectral.yaml` ruleset)
   
   For manual validation steps, see the [Validate the Specification](#validate-the-specification) section above.
5. **Test**: Ensure the specification can be used for code generation
6. **Commit**: Write clear commit messages
7. **Push and PR**: Push to your fork and create a pull request

### Validation Requirements

All pull requests must:
- ✅ Pass `swagger-cli validate` on the bundled specification without errors
- ✅ Have all `$ref` references resolve correctly (tested via bundling)
- ✅ Pass Spectral linting checks on the bundled spec (warnings are treated as errors)
- ✅ Pass YAML syntax checks (yamllint) on individual files - required in CI, optional locally
- ✅ Follow OpenAPI 3.1.0 specification standards
- ✅ Maintain legal compliance (no copied text)

**Quick Check**: Run `./scripts/validate.sh` before opening a PR to ensure all checks pass locally. This script runs the same validations as the CI workflow.

**Note**: The CI workflow will fail if:
- Any Spectral linting warnings are found on the bundled spec (configured in `.spectral.yaml`)
- YAML syntax errors are detected in individual files
- OpenAPI validation fails on the bundled specification
- Reference resolution fails during bundling

### Reporting Issues

When reporting issues:
- Describe the problem clearly
- Include the OCPI version (2.2.1 or 2.3.0)
- Reference the relevant module if applicable
- Link to the official OCPI spec section if relevant

## License

This project is licensed under the Apache License 2.0. See [LICENSE](LICENSE) for details.

## Resources

- [EVRoaming Foundation](https://evroaming.org/)
- [OCPI Official Downloads](https://evroaming.org/ocpi-downloads/)
- [OpenAPI Specification](https://swagger.io/specification/)

## Status

This is an active project. Both OCPI 2.2.1 and 2.3.0 specifications are available and validated. Check the [Issues](https://github.com/yourusername/ocpi-openapi-spec/issues) for current status and known limitations.
