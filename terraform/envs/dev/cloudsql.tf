resource "google_sql_database_instance" "postgres" {
  name             = "offline-map-postgres-dev-01"
  region           = var.region
  database_version = "POSTGRES_17"

  settings {
    edition           = "ENTERPRISE"
    tier              = "db-custom-1-3840"
    availability_type = "ZONAL"
    disk_type         = "PD_SSD"
    disk_size         = 20
    disk_autoresize   = true

    activation_policy = "ALWAYS"

    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.main.id
    }

    backup_configuration {
      enabled                        = true
      point_in_time_recovery_enabled = true
      start_time                     = "03:00"
    }
  }

  deletion_protection = false

  depends_on = [
    google_service_networking_connection.private_vpc_connection
  ]
}

resource "google_sql_database" "app" {
  name     = "offline_map"
  instance = google_sql_database_instance.postgres.name
}

resource "google_sql_user" "app" {
  name     = "offline_map_app"
  instance = google_sql_database_instance.postgres.name
  password = var.db_password
}