provider "oci" {
  private_key = base64decode(var.private_key)
}