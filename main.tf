# The following data source is used to retrieve the identity running Terraform, which becomes owner of the app registrations.

data "azuread_client_config" "current" {}

# The following module block is used to create the app registration, its enterprise application and a flexible federated
# credential trusting every workspace and run phase of the HCP Terraform project.

module "appregistration" {
  source  = "app.terraform.io/benoitblais-hashicorp/appregistration/azuread"
  version = "0.0.2"

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

# The following resource block is used to compute the secret expiration date (3 months from creation).
# It is stored in the state, so the date stays stable between runs and the secret is not replaced at every plan.

resource "time_offset" "secret_expiration" {
  offset_months = 3
}

# The following module block is used to create a second app registration, authenticated with a generated client secret
# which is valid for 3 months.

module "appregistration_secret" {
  source  = "app.terraform.io/benoitblais-hashicorp/appregistration/azuread"
  version = "0.0.2"

  display_name = "${var.display_name}-secret"
  description  = "Authenticated with a client secret valid for 3 months."
  owners       = [data.azuread_client_config.current.object_id]

  secret = {
    end_date     = time_offset.secret_expiration.rfc3339
    display_name = "terraform-managed"
  }
}
