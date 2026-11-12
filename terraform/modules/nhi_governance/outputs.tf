output "application_id" {
  value       = azuread_application.workload_app.client_id
  description = "Client (Application) ID for the registered NHI"
}

output "service_principal_object_id" {
  value       = azuread_service_principal.workload_sp.object_id
  description = "Object ID of the active Service Principal"
}
