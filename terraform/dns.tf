data "google_dns_managed_zone" "default" {
  provider = google.dns
  name     = var.dns_zone
}

resource "google_dns_record_set" "gemini" {
  provider     = google.dns
  name         = "${var.domain}."
  type         = "A"
  ttl          = 300
  managed_zone = data.google_dns_managed_zone.default.name
  rrdatas      = [google_compute_global_address.default.address]
}
