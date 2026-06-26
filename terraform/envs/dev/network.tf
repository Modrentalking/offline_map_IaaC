resource "google_compute_network" "main" {
  name                    = "offline-map-vpc"
  auto_create_subnetworks = false

  depends_on = [google_project_service.services]
}

resource "google_compute_subnetwork" "gke" {
  name          = "offline-map-gke-subnet"
  region        = var.region
  network       = google_compute_network.main.id
  ip_cidr_range = "10.10.0.0/20"

  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = "10.20.0.0/16"
  }

  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = "10.30.0.0/20"
  }
}
#Private network range for CloudSQL 
resource "google_compute_global_address" "private_service_range" {
  name          = "offline-map-private-service-range"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  address       = "10.40.0.0"
  prefix_length = 16
  network       = google_compute_network.main.id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.main.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_service_range.name]


  deletion_policy = "ABANDON"

  depends_on = [
    google_project_service.services
  ]
}