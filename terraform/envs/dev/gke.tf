resource "google_container_cluster" "gke" {
  name     = "offline-map-gke"
  location = var.region

  enable_autopilot    = true
  deletion_protection = false

  network    = google_compute_network.main.id
  subnetwork = google_compute_subnetwork.gke.id

  ip_allocation_policy {
    cluster_secondary_range_name  = "pods"
    services_secondary_range_name = "services"
  }

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  release_channel {
    channel = "REGULAR"
  }

  vertical_pod_autoscaling {
    enabled = true
  }

  maintenance_policy {
    recurring_window {
      start_time = "2026-01-01T03:00:00Z"
      end_time   = "2026-01-01T07:00:00Z"
      recurrence = "FREQ=WEEKLY;BYDAY=SU"
    }
  }

  depends_on = [
    google_project_service.services,
    google_compute_subnetwork.gke
  ]
}