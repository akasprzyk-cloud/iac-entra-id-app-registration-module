output "client_id" {
  description = "Client ID of the application registration."
  value       = azuread_application.this.client_id
}

output "application_object_id" {
  description = "Object ID of the application registration."
  value       = azuread_application.this.object_id
}

output "service_principal_object_id" {
  description = "Object ID of the enterprise application."
  value       = azuread_service_principal.this.object_id
}

output "app_role_ids" {
  description = "Map of app role values to their IDs."

  value = {
    for key, role in var.app_roles :
    role.value => random_uuid.app_role[key].result
  }
}

output "api_scope_ids" {
  description = "Map of OAuth2 scope values to their IDs."

  value = {
    for key, scope in var.api_scopes :
    scope.value => random_uuid.api_scope[key].result
  }
}