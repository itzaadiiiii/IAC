provider "google" {
    project     = "my-project-id" # Get from the UI
    region      = "us-central1"
    #below are optional
    zone = "us-central1-a"
    credentials = ""  # Create service account and mention json string
}
