terraform {
  required_version = ">= 0.13"

  required_providers {
    talos = {
      source = "siderolabs/talos"
      version = "~> 0.7.1"
    }
  }
}
