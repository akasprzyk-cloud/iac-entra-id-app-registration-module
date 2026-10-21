locals {
  app_role_values = [
    for role in values(var.app_roles) : role.value
  ]

  api_scope_values = [
    for scope in values(var.api_scopes) : scope.value
  ]

  application_permission_values = concat(
    local.app_role_values,
    local.api_scope_values
  )
}

locals {
  permission_values_are_unique = (
    length(local.application_permission_values) ==
    length(toset(local.application_permission_values))
  )
}