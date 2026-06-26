variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "europe-west3"
}

variable "db_password" {
  description = "Password for offline_map_app database user"
  type        = string
  sensitive   = true
}

variable "map_cors_origins" {
  description = "Allowed CORS origins for map static bucket"
  type        = list(string)
  default = [
    "https://new.map.of.by",
    "http://localhost:3000"
  ]

}