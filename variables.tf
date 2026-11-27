variable "display_name" {
  type        = string
  description = "(Optional) The display name of the app registration."
  default     = "hcp-terraform-azure-conseilsti-shared-services"
}

variable "tfc_hostname" {
  type        = string
  description = "(Optional) The hostname of the HCP Terraform / Terraform Enterprise instance, used as the OIDC token issuer."
  default     = "app.terraform.io"
}

variable "tfc_organization_name" {
  type        = string
  description = "(Optional) The name of the HCP Terraform organization."
  default     = "benoitblais-hashicorp"
}

variable "tfc_project_name" {
  type        = string
  description = "(Optional) The name of the HCP Terraform project whose workspaces are allowed to authenticate with the app registration."
  default     = "Azure ConseilsTI Shared Services"
}
