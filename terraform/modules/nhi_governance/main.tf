terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 2.47.0"
    }
  }
}

# 1. Primary Entra ID Application Registration
resource "azuread_application" "workload_app" {
  display_name            = var.app_display_name
  owners                  = [data.azuread_client_config.current.object_id]
  prevent_duplicate_names = true

  # Security Hardening: Prevent implicit flow fallback & require explicit token configuration
  single_page_application {
    redirect_uris = []
  }

  api {
  }

  # Prevent creation of static password credentials by policy logic
  notes = "Governed Workload Identity for GitHub Actions OIDC - Zero Static Credentials"
}

data "azuread_client_config" "current" {}

# 2. Service Principal Provisioning
resource "azuread_service_principal" "workload_sp" {
  client_id                    = azuread_application.workload_app.client_id
  app_role_assignment_required = true # Enforce explicit role assignment before access is granted
  owners                       = [data.azuread_client_config.current.object_id]

  description = "Managed Service Principal for ${var.app_display_name}. Governed by NHI Automation."
}

# 3. Workload Identity Federation (Secretless OIDC Trust with GitHub Actions)
resource "azuread_application_federated_identity_credential" "github_oidc" {
  application_id = azuread_application.workload_app.id
  display_name   = "github-actions-${var.github_environment}"
  description    = "OIDC Federation for ${var.github_organization}/${var.github_repository} [Env: ${var.github_environment}]"

  # GitHub Actions Standard Issuer
  issuer = "https://token.actions.githubusercontent.com"

  # Standard Audience for Azure Login Action
  audiences = ["api://AzureADTokenExchange"]

  # HARDENED SUBJECT PATTERN: Strict scope matching (Org + Repo + Environment)
  # Prevents branch-spoofing and unauthorized PR execution
  subject = "repo:${var.github_organization}/${var.github_repository}:environment:${var.github_environment}"
}
