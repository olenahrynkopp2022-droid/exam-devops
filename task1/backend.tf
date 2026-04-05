terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
    }
  }

  backend "s3" {
    bucket = "hrynko-bucket"
    key    = "terraform.tfstate"
    region = "us-east-1"

    endpoints = {
      s3 = "https://fra1.digitaloceanspaces.com"
    }

    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
  }
}