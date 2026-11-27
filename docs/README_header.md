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

* `ARM_TENANT_ID` – the Entra ID tenant.
* `ARM_USE_OIDC` and `ARM_CLIENT_ID` – to authenticate with OIDC (recommended).
* `ARM_CLIENT_SECRET` – only when OIDC is not possible. Set it as a sensitive workspace variable.

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
