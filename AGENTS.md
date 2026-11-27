# AGENTS.md for Terraform Project

This file provides instructions for AI coding agents working on this Terraform Project.

## Project Overview

This project provisions a Microsoft Entra ID (Azure AD) app registration, its enterprise application (service principal), and a federated identity credential (FIC) that allows the workspaces of an HCP Terraform project to authenticate to Azure using OpenID Connect (OIDC) dynamic credentials, without storing client secrets.

It also provisions a second app registration authenticated with a generated client secret valid for 3 months (expiration computed with `time_offset`), for cases where dynamic credentials can't be used.

The app registration is created by calling the private registry module `app.terraform.io/benoitblais-hashicorp/appregistration/azuread` and does not declare `azuread` resources directly. The code uses the `hashicorp/azuread` provider.

## Module and Repository Structure

Organize your Terraform project as follows:

```text
├── .gitignore
├── LICENSE
├── README.md
├── main.tf
├── outputs.tf
├── providers.tf
├── variables.tf
├── versions.tf
├── docs/
│   ├── CODE_OF_CONDUCT.md
│   ├── CONTRIBUTING.md
│   ├── PULL_REQUEST_TEMPLATE.md
│   ├── README_footer.md
│   ├── README_header.md
│   ├── SECURITY.md
```

### Required Files and Directories

- `README.md` – Required in the root module. Generated automatically (e.g., via Terraform-Docs). Do not edit manually.
- `docs/README_header.md` - Describe the purpose of the code and provide required context.
- `docs/README_footer.md` - Provide links to external documentation used to generate the code. It must start with a top-level heading (`# External Documentation`) to satisfy markdownlint rule MD041.
- `main.tf` – The `appregistration/azuread` module call and supporting data sources.
- `outputs.tf` – Output value definitions (alphabetical order).
- `providers.tf` – Provider configurations.
- `variables.tf` – Input variable definitions (alphabetical order with required variables at the top).
- `versions.tf` - Terraform version and provider requirements.

## README_header.md

When editing this file, describe the purpose of the code (Entra ID app registration and federated identity credential for HCP Terraform OIDC) and include:

- **Permissions**: the Microsoft Graph / Entra ID permissions required by the identity running Terraform (e.g., `Application.ReadWrite.All`, or the `Application Administrator` / `Cloud Application Administrator` role).
- **Authentication**: how the `azuread` provider authenticates (e.g., environment variables such as `ARM_TENANT_ID`, `ARM_CLIENT_ID`, or HCP Terraform dynamic credentials).
- **Manual configurations**: any Azure/Entra ID settings that cannot be managed by this code (e.g., Azure RBAC role assignments for the service principal, workspace variables such as `TFC_AZURE_RUN_CLIENT_ID`, admin consent for API permissions).

## README_footer.md

When editing or creating `docs/README_footer.md`, ensure it contains:

- A top-level heading (`# External Documentation`) as the first line.
- Links to relevant external documentation used to develop the code (e.g., Terraform documentation, `azuread` provider documentation, HCP Terraform dynamic provider credentials for Azure, Microsoft Entra workload identity federation).

## Code Guidelines

Refer to `docs/CONTRIBUTING.md` for general coding guidelines. HashiCorp's Terraform style guide should be applied for all code generated.

## Resource Naming

- Use descriptive nouns separated by underscores.
- Do not include the resource type in the resource name.
- Wrap resource type and name in double quotes.
- Example: `resource "azuread_application" "main"` not `resource "azuread_application" "azuread_application_main"`.

## Federated Identity Credentials

- Use the issuer `https://app.terraform.io` (or the configured HCP Terraform / Terraform Enterprise hostname) and the audience `api://AzureADTokenExchange`.
- The subject claim format is `organization:<ORG>:project:<PROJECT>:workspace:<WORKSPACE>:run_phase:<plan|apply>`.
- To trust a whole HCP Terraform project, use a flexible federated credential (`flexible_federated_credentials` input of the module) with the expression `claims['sub'] matches 'organization:<ORG>:project:<PROJECT>:workspace:*:run_phase:*'`. This is an Entra ID preview feature.
- To trust specific workspaces only, use standard federated credentials (`federated_credentials` input), one per workspace and run phase.
- Never add the module `secret` input to the federated app registration (`module.appregistration`); it must rely exclusively on federated credentials.
- Client secrets are only allowed on the dedicated `module.appregistration_secret`. They must always have an explicit expiration date, and the secret output must stay `sensitive = true`.

## Version Management

- Prefer the pessimistic constraint operator (`~>`) for modules and providers to allow safe updates within a compatible version range.
- Avoid using only the equals (`=`) operator unless you must lock to a single version for reproducibility or known issues.
- Pin the Terraform version using `required_version` in the `terraform` block.

## Provider Configuration

- Always include a default provider configuration.
- Define all providers in the same file (`providers.tf`).
- Define the default provider first, then aliased providers.
- Use `alias` as the first parameter in non-default provider blocks.

## Security and Secrets

- Never commit `.terraform` directories or local state files.
- Access secrets securely via workspace variables.
- Set `sensitive = true` for sensitive variables across all definitions.
- Never hardcode tenant IDs, subscription IDs, client IDs, or credentials in code; provide them via variables or environment variables.
- Apply least privilege to the identity that runs Terraform and to any role assigned to the created service principal.

## State Management

- Do NOT configure local state backend blocks or manipulate state manually. State is natively stored and handled remotely in HCP Terraform.
