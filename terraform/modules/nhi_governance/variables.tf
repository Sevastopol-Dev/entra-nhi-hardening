variable "app_display_name" {
  type        = string
  description = "Display name for the Entra ID Workload Identity App Registration"
}

variable "github_organization" {
  type        = string
  description = "GitHub Organization or Account name permitted for OIDC federation"
}

variable "github_repository" {
  type        = string
  description = "GitHub Repository name permitted for OIDC federation"
}

variable "github_environment" {
  type        = string
  default     = "production"
  description = "Target deployment environment enforced in the OIDC claim subject"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Resource metadata tags for governance tracking"
}
