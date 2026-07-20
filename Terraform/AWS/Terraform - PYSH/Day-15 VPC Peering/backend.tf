terraform {
  backend "remote" {
    organization = "aadiizworld"

    workspaces {
      name = "Jan-2026"
    }
  }
}
