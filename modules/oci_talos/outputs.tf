output "controlplane_node_ips" {
  value = [module.a1_flex_instance_group.private_ip[0]]
}

output "worker_node_ips" {
  value = [module.a1_flex_instance_group.private_ip[1]]
}