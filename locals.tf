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

  permission_values_are_unique = (
    length(local.application_permission_values) ==
    length(toset(local.application_permission_values))
  )

  required_resource_access = {
    for api_name, permission in var.api_permissions :
    api_name => {
      resource_app_id = permission.resource_app_id

      resource_access = concat(
        [
          for role in permission.application_roles : {
            id   = data.azuread_service_principal.api[api_name].app_role_ids[role]
            type = "Role"
          }
        ],
        [
          for scope in permission.delegated_scopes : {
            id   = data.azuread_service_principal.api[api_name].oauth2_permission_scope_ids[scope]
            type = "Scope"
          }
        ]
      )
    }
  }
}
