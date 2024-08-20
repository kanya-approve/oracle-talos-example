resource "oci_identity_compartment" "compartment" {
  compartment_id = module.tf_dynamic_credentials.root_compartment_id
  description    = var.compartment_description
  name           = var.compartment_name
}

module "oci_vcn" {
  source = "oracle-terraform-modules/vcn/oci"

  compartment_id                = oci_identity_compartment.compartment.id
  create_internet_gateway       = true
  create_nat_gateway            = true
  create_service_gateway        = true
  internet_gateway_display_name = var.internet_gateway_display_name
  nat_gateway_display_name      = var.nat_gateway_display_name
  vcn_name                      = var.vcn_name

  subnets = {
    public = {
      cidr_block = "10.0.0.0/24"
      name       = var.public_subnet_name
      type       = "public"
    }
    private = {
      cidr_block = "10.0.1.0/24"
      name       = var.private_subnet_name
      type       = "private"
    }
  }
}

resource "oci_core_security_list" "security_list" {
  compartment_id = oci_identity_compartment.compartment.id
  vcn_id         = module.oci_vcn.vcn_id

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }

  ingress_security_rules {
    protocol = "all"
    source   = "${module.oci_vcn.nat_gateway_all_attributes[0].nat_ip}/32"
  }

  ingress_security_rules {
    protocol = "all"
    source   = "${oci_network_load_balancer_network_load_balancer.talos_nlb.ip_addresses[0]["ip_address"]}/32"
  }

  ingress_security_rules {
    protocol = "all"
    source   = "10.0.0.0/8"
  }

  ingress_security_rules {
    protocol = "all"
    source   = var.personal_ip
  }
}

module "oci_talos_image" {
  source = "./modules/oci_talos_image"

  compartment_id = oci_identity_compartment.compartment.id
  images_bucket  = var.talos_images_bucket
}

resource "oci_network_load_balancer_network_load_balancer" "talos_nlb" {
  compartment_id = oci_identity_compartment.compartment.id
  display_name   = "talos-nlb"
  is_private     = false
  subnet_id      = module.oci_vcn.subnet_all_attributes["public"]["id"]
}

module "talos" {
  source = "./modules/talos"

  cluster_endpoints = compact([
    var.cluster_domain_endpoint,
    oci_network_load_balancer_network_load_balancer.talos_nlb.ip_addresses[0]["ip_address"],
  ])
  controlplane_node_ips = module.oci_talos.controlplane_node_ips
  worker_node_ips       = module.oci_talos.worker_node_ips
}

module "oci_talos" {
  source = "./modules/oci_talos"

  ad_number        = var.ad_number
  amd64_image_id   = module.oci_talos_image.amd64_image_id
  arm64_image_id   = module.oci_talos_image.arm64_image_id
  compartment_id   = oci_identity_compartment.compartment.id
  nlb_id           = oci_network_load_balancer_network_load_balancer.talos_nlb.id
  subnet_id        = module.oci_vcn.subnet_all_attributes["private"]["id"]
  worker_user_data = module.talos.worker_machine_configuration
}

resource "tls_private_key" "flux" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

data "github_repository" "this" {
  name = var.flux_repository_name
}

resource "github_repository_deploy_key" "this" {
  title      = "FluxCD"
  repository = data.github_repository.this.name
  key        = tls_private_key.flux.public_key_openssh
  read_only  = "false"
}

provider "flux" {
  git = {
    url = "ssh://git@github.com/${data.github_repository.this.full_name}.git"
    ssh = {
      username    = "git"
      private_key = tls_private_key.flux.private_key_pem
    }
  }

  kubernetes = {
    client_certificate     = base64decode(module.talos.kubeconfig.client_certificate)
    client_key             = base64decode(module.talos.kubeconfig.client_key)
    cluster_ca_certificate = base64decode(module.talos.kubeconfig.ca_certificate)
    host                   = module.talos.kubeconfig.host
  }
}

resource "flux_bootstrap_git" "talos_cluster" {
  depends_on = [helm_release.cilium, module.talos]

  interval       = "5m0s"
  network_policy = false
  path           = var.flux_repository_path
}