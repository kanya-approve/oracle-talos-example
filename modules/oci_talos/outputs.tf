output "controlplane_node_ips" {
  value = [module.controlplane_instance_group.private_ip[0]]
}

output "is_first_run" {
  value = var.is_first_run && data.local_file.first_run_check.content == ""
}

output "worker_node_ips" {
  value = [module.worker_instance_group.private_ip[0]]
}