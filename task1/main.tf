terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }

  backend "s3" {
    endpoint                    = "fra1.digitaloceanspaces.com"
    region                      = "us-east-1" 
    bucket                      = "hrynko-bucket"
    key                         = "terraform.tfstate"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    use_path_style
  }
}

provider "digitalocean" {
  token = var.do_token
}

# 1. VPC
resource "digitalocean_vpc" "hrynko_vpc" {
  name     = "hrynkoo-vpc"
  region   = "fra1"
  ip_range = "10.10.10.0/24"
}

# 2. ВМ (Droplet)
resource "digitalocean_droplet" "hrynko_node" {
  name     = "hrynkoo-node"
  region   = "fra1"
  size     = "s-2vcpu-4gb" 
  image    = "ubuntu-24-04-x64"
  vpc_uuid = digitalocean_vpc.hrynko_vpc.id
  ssh_keys = [var.ssh_fingerprint]
}

# 3. Фаєрвол
resource "digitalocean_firewall" "hrynko_firewall" {
  name        = "hrynkoo-firewall"
  droplet_ids = [digitalocean_droplet.hrynko_node.id]

  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }
  inbound_rule {
    protocol         = "tcp"
    port_range       = "80"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }
  inbound_rule {
    protocol         = "tcp"
    port_range       = "443"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }
  inbound_rule {
    protocol         = "tcp"
    port_range       = "8000-8003"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}
