terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.54.0"
    }
  }
}

provider "aws" {
  # Configuration options
  region = "ap-south-1"   #Mumbai
  alias = "Primary"
}

# provider "aws" {
#   # Configuration options
#   region = "ap-south-2"    #Hydrabad
#   alias = "Secondary"
# }
