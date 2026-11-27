output "application_object_id" {
  description = "The object ID of the app registration."
  value       = module.appregistration.application_object_id
}

output "client_id" {
  description = "The client ID of the app registration. Set it as the TFC_AZURE_RUN_CLIENT_ID variable of the workspaces."
  value       = module.appregistration.client_id
}

output "secret_application_object_id" {
  description = "The object ID of the app registration authenticated with a client secret."
  value       = module.appregistration_secret.application_object_id
}

output "secret_client_id" {
  description = "The client ID of the app registration authenticated with a client secret."
  value       = module.appregistration_secret.client_id
}

output "secret_client_secret" {
  description = "The generated client secret value (valid for 3 months)."
  value       = module.appregistration_secret.client_secret
  sensitive   = true
}

output "secret_client_secret_end_date" {
  description = "The expiration date of the generated client secret."
  value       = module.appregistration_secret.client_secret_end_date
}

output "secret_service_principal_object_id" {
  description = "The object ID of the enterprise application authenticated with a client secret. Use it for Azure role assignments."
  value       = module.appregistration_secret.service_principal_object_id
}

output "service_principal_object_id" {
  description = "The object ID of the enterprise application. Use it for Azure role assignments."
  value       = module.appregistration.service_principal_object_id
}
