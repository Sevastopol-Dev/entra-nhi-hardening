terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 2.47.0"
    }
  }
}

provider "azuread" {
}

# Module Instantiate

module "nhi_governance" {
  source              = "./modules/nhi_governance"
  app_display_name    = var.app_display_name
  github_organization = var.github_organization
  github_repository   = var.github_repository
  github_environment  = var.github_environment
}
