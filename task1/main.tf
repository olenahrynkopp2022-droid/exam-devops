provider "digitalocean" {
  token = var.do_token
  
  spaces_access_id  = var.spaces_access_key
  spaces_secret_key = var.spaces_secret_key
}

resource "digitalocean_vpc" "vpc" {
  name     = "hrynkoo-vpc"
  region   = "fra1"
  ip_range = "10.10.10.0/24"
}

resource "digitalocean_droplet" "node" {
  name   = "hrynkoo-node"
  region = "fra1"
  size   = "s-2vcpu-4gb"
  image  = "ubuntu-24-04-x64"

  vpc_uuid = digitalocean_vpc.vpc.id
  ssh_keys = [var.ssh_fingerprint]
}

resource "digitalocean_firewall" "fw" {
  name = "hrynko-firewall"
  droplet_ids = [digitalocean_droplet.node.id]

  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["0.0.0.0/0"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "80"
    source_addresses = ["0.0.0.0/0"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "443"
    source_addresses = ["0.0.0.0/0"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "8000-8003"
    source_addresses = ["0.0.0.0/0"]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0"]
  }
}

resource "digitalocean_spaces_bucket" "bucket" {
  name   = "hrynko-bucket"
  region = "fra1"
}

variable "do_token" {}
variable "ssh_fingerprint" {}
variable "spaces_access_key" {}
variable "spaces_secret_key" {}

output "ip" {
  value = digitalocean_droplet.node.ipv4_address
}
