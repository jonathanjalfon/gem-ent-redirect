output "ip_address" {
  description = "Global static IP address for the load balancer"
  value       = google_compute_global_address.default.address
}

output "custom_domain" {
  description = "Custom domain URL"
  value       = "https://${var.domain}"
}
