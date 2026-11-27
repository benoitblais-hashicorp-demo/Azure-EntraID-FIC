<!-- BEGIN_TF_DOCS -->
# Azure Entra ID Federated Identity Credential for HCP Terraform

Code which provisions a Microsoft Entra ID app registration (and its enterprise application) that
HCP Terraform uses to provision Azure infrastructure with dynamic provider credentials (OIDC),
without any client secret.

A single flexible federated identity credential trusts every workspace and every run phase
(`plan` and `apply`) of the HCP Terraform project `Azure ConseilsTI Shared Services`.
The app registration is created with the private registry module `appregistration/azuread`.

## Permissions

### Microsoft Entra ID Permissions

The identity running Terraform needs one of the following:

* Microsoft Graph application permission `Application.ReadWrite.All`.
* Entra ID role `Application Administrator` or `Cloud Application Administrator`.

## Authentication

### Microsoft Entra ID Authentication

The `azuread` provider is configured through environment variables (workspace variables), preferably with
HCP Terraform dynamic provider credentials:

* `TFC_AZURE_PROVIDER_AUTH` – set to `true` to enable dynamic credentials (recommended).
* `TFC_AZURE_RUN_CLIENT_ID` – the client ID of the app registration used by this workspace, which must have a federated credential matching this workspace.
* `ARM_TENANT_ID` – the Entra ID tenant.
* `ARM_CLIENT_SECRET` (with `ARM_CLIENT_ID`) – only when dynamic credentials are not possible. Set it as a sensitive workspace variable.

Do not set `ARM_CLIENT_ID`, `ARM_USE_OIDC` or `ARM_OIDC_TOKEN` together with dynamic credentials. HCP Terraform provides the OIDC token itself, and these variables make the provider look for a token that doesn't exist, then fall back to Azure CLI authentication.

## Features

* Creates an Entra ID app registration and its enterprise application (service principal).
* Creates a flexible federated identity credential (preview) trusting
  `organization:<org>:project:<project>:workspace:*:run_phase:*`.
* Makes the identity running Terraform owner of the app registration.

## Prerequisite

The module `appregistration/azuread` must be published in the private registry of the organization.

## Manual Configurations

Some configurations are not managed by this code and must be done manually:

1. **Azure role assignments**: the enterprise application has no access to any Azure subscription. Assign it the
   required Azure RBAC roles (e.g. `Contributor`) on the target scope, using the `service_principal_object_id` output.
2. **HCP Terraform workspace variables**: in the workspaces of the project (or in a project-scoped variable set), set
   `TFC_AZURE_PROVIDER_AUTH = true`, `TFC_AZURE_RUN_CLIENT_ID` (the `client_id` output), `ARM_TENANT_ID` and
   `ARM_SUBSCRIPTION_ID`.
3. **Flexible federated credentials are in preview**: they are a Microsoft Entra feature in preview and rely on the Microsoft Graph beta API.

## Documentation

## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.13.0)

- <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) (~> 3.10.0)

## Modules

The following Modules are called:

### <a name="module_appregistration"></a> [appregistration](#module\_appregistration)

Source: app.terraform.io/benoitblais-hashicorp/appregistration/azuread

Version: 0.0.2

## Required Inputs

No required inputs.

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_display_name"></a> [display\_name](#input\_display\_name)

Description: (Optional) The display name of the app registration.

Type: `string`

Default: `"hcp-terraform-azure-conseilsti-shared-services"`

### <a name="input_tfc_hostname"></a> [tfc\_hostname](#input\_tfc\_hostname)

Description: (Optional) The hostname of the HCP Terraform / Terraform Enterprise instance, used as the OIDC token issuer.

Type: `string`

Default: `"app.terraform.io"`

### <a name="input_tfc_organization_name"></a> [tfc\_organization\_name](#input\_tfc\_organization\_name)

Description: (Optional) The name of the HCP Terraform organization.

Type: `string`

Default: `"benoitblais-hashicorp"`

### <a name="input_tfc_project_name"></a> [tfc\_project\_name](#input\_tfc\_project\_name)

Description: (Optional) The name of the HCP Terraform project whose workspaces are allowed to authenticate with the app registration.

Type: `string`

Default: `"Azure ConseilsTI Shared Services"`

## Resources

The following resources are used by this module:

- [azuread_client_config.current](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/client_config) (data source)

## Outputs

The following outputs are exported:

### <a name="output_application_object_id"></a> [application\_object\_id](#output\_application\_object\_id)

Description: The object ID of the app registration.

### <a name="output_client_id"></a> [client\_id](#output\_client\_id)

Description: The client ID of the app registration. Set it as the TFC\_AZURE\_RUN\_CLIENT\_ID (and ARM\_CLIENT\_ID) variable of the workspaces.

### <a name="output_service_principal_object_id"></a> [service\_principal\_object\_id](#output\_service\_principal\_object\_id)

Description: The object ID of the enterprise application. Use it for Azure role assignments.

<!-- markdownlint-enable -->
# External Documentation

* [Terraform azuread provider](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs)
* [HCP Terraform dynamic provider credentials for Azure](https://developer.hashicorp.com/terraform/cloud-docs/dynamic-provider-credentials/azure-configuration)
* [Microsoft Entra workload identity federation](https://learn.microsoft.com/entra/workload-id/workload-identity-federation)
* [Microsoft Entra flexible federated identity credentials (preview)](https://learn.microsoft.com/entra/workload-id/workload-identities-flexible-federated-identity-credentials)
<!-- END_TF_DOCS -->