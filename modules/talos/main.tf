locals {
  all_node_patch = yamlencode({
    cluster = {
      allowSchedulingOnControlPlanes = true
    }

    machine = {
      certSANs = var.cluster_endpoints

      features = {
        hostDNS = {
          enabled              = true
          forwardKubeDNSToHost = true
          resolveMemberNames   = true
        }

        kubePrism = {
          enabled = true
          port    = 7445
        }
      }

      install = {
        image = "ghcr.io/siderolabs/installer:${var.talos_version}"
      }

      kubelet = {
        registerWithFQDN = false
      }

      network = {
        interfaces = [
          {
            addresses = ["169.254.2.53/32"]
            interface = "dummy0"
          }
        ]

        kubespan = {
          advertiseKubernetesNetworks = true
          allowDownPeerBypass         = true
          enabled                     = true
        }

        nameservers = [
          "100.100.100.100",
          "1.1.1.1",
        ]
      }

      sysctls = {
        "net.core.rmem_max"                = "2500000"
        "net.core.wmem_max"                = "2500000"
        "net.ipv4.conf.all.src_valid_mark" = "1"
      }

      time = {
        servers = [
          "169.254.169.123",
          "169.254.169.254",
          "time.cloudflare.com"
        ]
      }
    }
  })
}

resource "talos_machine_secrets" "this" {}

data "talos_client_configuration" "this" {
  client_configuration = talos_machine_secrets.this.client_configuration
  cluster_name         = var.cluster_name
  endpoints            = var.cluster_endpoints
  nodes                = concat(var.controlplane_node_ips, var.worker_node_ips)
}

data "talos_machine_configuration" "controlplane" {
  cluster_endpoint   = "https://${var.cluster_endpoints[0]}:6443"
  cluster_name       = var.cluster_name
  config_patches     = concat([local.all_node_patch], var.config_patches)
  docs               = false
  examples           = false
  machine_secrets    = talos_machine_secrets.this.machine_secrets
  machine_type       = "controlplane"
  kubernetes_version = var.kubernetes_version
}

resource "talos_machine_configuration_apply" "controlplane" {
  count = length(var.controlplane_node_ips)

  client_configuration        = talos_machine_secrets.this.client_configuration
  endpoint                    = var.cluster_endpoints[0]
  machine_configuration_input = data.talos_machine_configuration.controlplane.machine_configuration
  node                        = var.controlplane_node_ips[count.index]
}

resource "talos_machine_bootstrap" "controlplane" {
  depends_on = [talos_machine_configuration_apply.controlplane]

  client_configuration = talos_machine_secrets.this.client_configuration
  endpoint             = var.cluster_endpoints[0]
  node                 = var.controlplane_node_ips[0]
}

data "talos_machine_configuration" "worker" {
  cluster_endpoint   = "https://${var.cluster_endpoints[0]}:6443"
  cluster_name       = var.cluster_name
  config_patches     = concat([local.all_node_patch], var.config_patches)
  docs               = false
  examples           = false
  machine_secrets    = talos_machine_secrets.this.machine_secrets
  machine_type       = "worker"
  kubernetes_version = var.kubernetes_version
}

data "talos_cluster_kubeconfig" "this" {
  depends_on = [talos_machine_bootstrap.controlplane]

  client_configuration = talos_machine_secrets.this.client_configuration
  endpoint             = var.cluster_endpoints[0]
  node                 = var.controlplane_node_ips[0]
  timeouts = {
    read = "30s"
  }
}