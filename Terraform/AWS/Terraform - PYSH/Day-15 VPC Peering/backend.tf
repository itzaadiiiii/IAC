# terraform {
#   backend "remote" {
#     organization = "aadiizworld"

#     workspaces {
#       name = "Jan-2026"
#     }
#   }
# }

terraform {
    backend "s3" {
        bucket       = "terraform-bucketttttt"
        key          = "Terraform-State"
        region       = "us-east-1"
        use_lockfile = true
    }
}
