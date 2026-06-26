resource "google_compute_global_address" "frontend_ip" {
  name = "offline-map-global-ip"

  depends_on = [
    google_project_service.services
  ]
}