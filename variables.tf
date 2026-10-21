variable "display_name" {
  description = "Display name of the Entra application."
  type        = string

  validation {
    condition     = length(trimspace(var.display_name)) > 0
    error_message = "display_name must not be empty."
  }
}

variable "description" {
  description = "Description of the application."
  type        = string
  default     = null
}

variable "sign_in_audience" {
  description = "Supported account types."
  type        = string
  default     = "AzureADMyOrg"

  validation {
    condition = contains([
      "AzureADMyOrg",
      "AzureADMultipleOrgs",
      "AzureADandPersonalMicrosoftAccount",
      "PersonalMicrosoftAccount"
    ], var.sign_in_audience)

    error_message = "Unsupported sign_in_audience value."
  }
}

variable "owners" {
  description = "Object IDs of application and service principal owners."
  type        = set(string)
  default     = []
}

variable "prevent_duplicate_names" {
  description = "Prevent duplicate application display names."
  type        = bool
  default     = true
}

variable "web" {
  description = "Web application authentication configuration."
  type = object({
    redirect_uris = optional(set(string), [])
    homepage_url  = optional(string)
    logout_url    = optional(string)
  })
  default = null
}

variable "single_page_application" {
  description = "SPA authentication configuration."
  type = object({
    redirect_uris = optional(set(string), [])
  })
  default = null
}

variable "public_client" {
  description = "Public client authentication configuration."
  type = object({
    redirect_uris = optional(set(string), [])
  })
  default = null
}

variable "app_roles" {
  description = "Application roles exposed by the application."
  type = map(object({
    display_name         = string
    description          = string
    value                = string
    allowed_member_types = optional(set(string), ["User"])
    enabled              = optional(bool, true)
  }))
  default = {}

  validation {
    condition = alltrue([
      for role in values(var.app_roles) :
      length(role.allowed_member_types) > 0 &&
      alltrue([
        for member_type in role.allowed_member_types :
        contains(["User", "Application"], member_type)
      ])
    ])

    error_message = "Each app role must allow User, Application, or both."
  }
}

variable "api_scopes" {
  description = "OAuth2 delegated scopes exposed by the application."
  type = map(object({
    value                      = string
    admin_consent_display_name = string
    admin_consent_description  = string
    user_consent_display_name  = optional(string)
    user_consent_description   = optional(string)
    enabled                    = optional(bool, true)
  }))
  default = {}
}

variable "api_permissions" {
  description = "API permissions requested by this application."
  type = map(object({
    resource_app_id = string

    resource_access = list(object({
      id   = string
      type = string
    }))
  }))
  default = {}

  validation {
    condition = alltrue(flatten([
      for api in values(var.api_permissions) : [
        for permission in api.resource_access :
        contains(["Role", "Scope"], permission.type)
      ]
    ]))

    error_message = "API permission type must be Role or Scope."
  }
}

variable "validate_permission_values" {
  description = "Validate uniqueness of app role and scope values."
  type        = bool
  default     = true
}

variable "expose_api" {
  description = "Whether to configure an Application ID URI."
  type        = bool
  default     = false
}