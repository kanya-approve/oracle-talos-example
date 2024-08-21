resource "local_sensitive_file" "private_key" {
  content  = var.private_key
  filename = "${path.module}/oci.pem"
}

provider "oci" {
  fingerprint      = var.fingerprint
  private_key_path = local_sensitive_file.private_key.filename
  region           = var.region
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
}