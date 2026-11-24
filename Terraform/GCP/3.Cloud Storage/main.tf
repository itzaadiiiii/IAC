terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "8.7.0"
    }
  }
}

# provider "google" {
#     # Configuration options
# }

provider "google" {
  project = "my-project-id"
  region  = "us-central1"
}
