# The following data source is used to retrieve the identity running Terraform, which becomes owner of the app registration.

data "azuread_client_config" "current" {}

# The following module block is used to create the app registration, its enterprise application and a flexible federated
# credential trusting every workspace and run phase of the HCP Terraform project.

module "appregistration" {
  source  = "app.terraform.io/benoitblais-hashicorp/appregistration/azuread"
  version = "~> 0.0.2"

  display_name = var.display_name
  description  = "Used by HCP Terraform project ${var.tfc_project_name} to provision infrastructure with dynamic credentials."
  owners       = [data.azuread_client_config.current.object_id]

  flexible_federated_credentials = {
    "tfc-${replace(lower(var.tfc_project_name), " ", "-")}" = {
      issuer                     = "https://${var.tfc_hostname}"
      claims_matching_expression = "claims['sub'] matches 'organization:${var.tfc_organization_name}:project:${var.tfc_project_name}:workspace:*:run_phase:*'"
      description                = "All workspaces and run phases of the HCP Terraform project ${var.tfc_project_name}."
    }
  }
}
