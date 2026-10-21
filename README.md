# terraform-azuread-app-registration

Reusable Terraform module creating an **Entra ID app registration** together with (optionally):

- service principal (enterprise application) and user/group assignments,
- exposed API: identifier URIs, app roles, delegated scopes (stable generated IDs),
- requested API permissions referenced **by name** (e.g. `Group.Read.All`) and optional **admin consent**,
- Web / SPA / public client platform configuration and optional claims,
- federated identity credentials (GitHub Actions OIDC by default),
- client secrets with automatic rotation (`time_rotating`).

## Usage

```hcl
module "app_payments" {
  source = "git::https://github.com/<modules-org>/terraform-azuread-app-registration.git?ref=v1.0.0"

  display_name = "app-payments-api-prod"

  api_permissions = [{
    resource_app_id   = "00000003-0000-0000-c000-000000000000" # Microsoft Graph
    application_roles = ["Group.Read.All"]
  }]
  grant_admin_consent = true

  federated_identity_credentials = {
    github = {
      display_name = "github-prod"
      subject      = "repo:my-org/my-repo:environment:prod"
    }
  }
}
```

See `examples/complete`.

## Permissions required by the Terraform identity

| Capability | Microsoft Graph application permission |
|---|---|
| Create apps / SPs | `Application.ReadWrite.All` (or `Application.ReadWrite.OwnedBy` for apps it owns, plus the *Cloud Application Administrator* role to create new ones) |
| `grant_admin_consent`, `principal_assignments` | `AppRoleAssignment.ReadWrite.All`, `DelegatedPermissionGrant.ReadWrite.All` |
| Reading resource SPs (Graph etc.) | `Application.Read.All` |

## Notes

- Outputs `app_role_ids` and `oauth2_permission_scope_ids` let other stacks reference generated IDs.
- `client_secrets` output is sensitive - push it to Key Vault, prefer federated credentials.
- Identifier URIs are managed by `azuread_application_identifier_uri`; do not set `identifier_uris` on the application directly.
- Version modules with git tags (SemVer) and pin `?ref=` in tenant repositories.
- The module contains no `provider` blocks - configure `azuread` in the tenant repository.
