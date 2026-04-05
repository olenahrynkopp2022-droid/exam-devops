variable "do_token" {
  type      = string
  sensitive = true
}

variable "ssh_fingerprint" {
  description = "DigitalOcean SSH key fingerprint"
  type        = string
}
