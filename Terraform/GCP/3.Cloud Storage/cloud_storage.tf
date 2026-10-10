provider "google" {
    project = "my-project-id"
    region  = "us-central1"
}

resource "google_storage_bucket" "static_bucket" {
    name          = "globally-unique-bucket-name-12345"
    location      = "US"
    force_destroy = false

    uniform_bucket_level_access = true

    versioning {
        enabled = true
    }
}
