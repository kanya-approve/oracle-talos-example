output "amd64_image_id" {
  value = oci_core_image.talos_amd64.id
}

output "arm64_image_id" {
  value = oci_core_image.talos_arm64.id
}