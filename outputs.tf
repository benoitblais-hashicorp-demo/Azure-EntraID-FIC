output "application_object_id" {
  description = "The object ID of the app registration."
  value       = module.appregistration.application_object_id
}

output "client_id" {
  description = "The client ID of the app registration. Set it as the TFC_AZURE_RUN_CLIENT_ID (and ARM_CLIENT_ID) variable of the workspaces."
  value       = module.appregistration.client_id
}

output "service_principal_object_id" {
  description = "The object ID of the enterprise application. Use it for Azure role assignments."
  value       = module.appregistration.service_principal_object_id
}
