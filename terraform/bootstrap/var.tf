variable "project_id" {
  description = "GCP project ID"
  type        = string

  validation {
    condition     = var.project_id == trimspace(var.project_id) && length(regexall("\\s", var.project_id)) == 0
    error_message = "project_id must not contain spaces, tabs or newlines."
  }
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "europe-west3"

  validation {
    condition     = var.region == trimspace(var.region) && length(regexall("\\s", var.region)) == 0
    error_message = "region must not contain spaces, tabs or newlines."
  }
}

variable "github_repositories" {
  type = list(string)

  default = [
    "Modrentalking/offline_map_IaaC",
    "Modrentalking/Map"
  ]
}

variable "local_impersonation_user" {
  description = "Local user allowed to impersonate GitHub Actions service account"
  type        = string
  default     = "maximodest@gmail.com"
}