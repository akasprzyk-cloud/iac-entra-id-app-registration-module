resource "random_uuid" "app_role" {
  for_each = var.app_roles
}

resource "random_uuid" "api_scope" {
  for_each = var.api_scopes
}

resource "azuread_application" "this" {
  display_name            = var.display_name
  description             = var.description
  sign_in_audience        = var.sign_in_audience
  prevent_duplicate_names = var.prevent_duplicate_names
  owners                  = var.owners

  lifecycle {
    precondition {
      condition = (
        !var.validate_permission_values ||
        local.permission_values_are_unique
      )

      error_message = "App role values and API scope values must be unique."
    }
  }

  dynamic "web" {
    for_each = var.web == null ? [] : [var.web]

    content {
      redirect_uris = web.value.redirect_uris
      homepage_url  = web.value.homepage_url
      logout_url    = web.value.logout_url
    }
  }

  dynamic "single_page_application" {
    for_each = (
      var.single_page_application == null
      ? []
      : [var.single_page_application]
    )

    content {
      redirect_uris = single_page_application.value.redirect_uris
    }
  }

  dynamic "public_client" {
    for_each = var.public_client == null ? [] : [var.public_client]

    content {
      redirect_uris = public_client.value.redirect_uris
    }
  }

  dynamic "app_role" {
    for_each = var.app_roles

    content {
      id                   = random_uuid.app_role[app_role.key].result
      display_name         = app_role.value.display_name
      description          = app_role.value.description
      value                = app_role.value.value
      allowed_member_types = app_role.value.allowed_member_types
      enabled              = app_role.value.enabled
    }
  }

  dynamic "api" {
    for_each = length(var.api_scopes) > 0 ? [true] : []

    content {
      requested_access_token_version = 2

      dynamic "oauth2_permission_scope" {
        for_each = var.api_scopes

        content {
          id = random_uuid.api_scope[oauth2_permission_scope.key].result

          value = oauth2_permission_scope.value.value

          type = "User"

          admin_consent_display_name = (
            oauth2_permission_scope.value.admin_consent_display_name
          )

          admin_consent_description = (
            oauth2_permission_scope.value.admin_consent_description
          )

          user_consent_display_name = (
            oauth2_permission_scope.value.user_consent_display_name
          )

          user_consent_description = (
            oauth2_permission_scope.value.user_consent_description
          )

          enabled = oauth2_permission_scope.value.enabled
        }
      }
    }
  }

  dynamic "required_resource_access" {
    for_each = var.api_permissions

    content {
      resource_app_id = required_resource_access.value.resource_app_id

      dynamic "resource_access" {
        for_each = required_resource_access.value.resource_access

        content {
          id   = resource_access.value.id
          type = resource_access.value.type
        }
      }
    }
  }
}

resource "azuread_service_principal" "this" {
  client_id = azuread_application.this.client_id
  owners    = var.owners
}