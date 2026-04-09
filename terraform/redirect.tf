# Static IP for the load balancer
resource "google_compute_global_address" "default" {
  name = "gem-ent-redirect-ip"

  depends_on = [google_project_service.compute]
}

locals {
  url_parts     = regex("^https?://([^/]+)(/.*)$", var.redirect_url)
  redirect_host = local.url_parts[0]
  redirect_path = local.url_parts[1]
}

# URL map that redirects all requests to the target URL
resource "google_compute_url_map" "redirect" {
  name = "gem-ent-redirect"

  default_url_redirect {
    https_redirect         = false
    strip_query            = false
    host_redirect          = local.redirect_host
    path_redirect          = local.redirect_path
    redirect_response_code = "FOUND"
  }
}

# HTTP → HTTPS redirect
resource "google_compute_url_map" "http_redirect" {
  name = "gem-ent-redirect-http"

  default_url_redirect {
    https_redirect         = true
    strip_query            = false
    redirect_response_code = "MOVED_PERMANENTLY_DEFAULT"
  }
}

# Google-managed SSL certificate
resource "google_compute_managed_ssl_certificate" "default" {
  name = "gem-ent-redirect-cert"

  managed {
    domains = [var.domain]
  }
}

# HTTPS frontend
resource "google_compute_target_https_proxy" "default" {
  name             = "gem-ent-redirect-https"
  url_map          = google_compute_url_map.redirect.id
  ssl_certificates = [google_compute_managed_ssl_certificate.default.id]
}

resource "google_compute_global_forwarding_rule" "https" {
  name       = "gem-ent-redirect-https"
  target     = google_compute_target_https_proxy.default.id
  port_range = "443"
  ip_address = google_compute_global_address.default.address
}

# HTTP frontend (redirects to HTTPS)
resource "google_compute_target_http_proxy" "default" {
  name    = "gem-ent-redirect-http"
  url_map = google_compute_url_map.http_redirect.id
}

resource "google_compute_global_forwarding_rule" "http" {
  name       = "gem-ent-redirect-http"
  target     = google_compute_target_http_proxy.default.id
  port_range = "80"
  ip_address = google_compute_global_address.default.address
}
