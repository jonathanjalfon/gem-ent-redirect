variable "project" {
  description = "GCP project ID for the load balancer"
  type        = string
}

variable "dns_project" {
  description = "GCP project ID where Cloud DNS zone is managed"
  type        = string
}

variable "domain" {
  description = "Custom domain for the redirect"
  type        = string
}

variable "dns_zone" {
  description = "Cloud DNS managed zone name for the domain"
  type        = string
}

variable "redirect_url" {
  description = "Full URL to redirect to"
  type        = string
}
