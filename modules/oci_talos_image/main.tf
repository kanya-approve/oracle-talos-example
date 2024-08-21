data "oci_objectstorage_namespace" "default_namespace" {
  compartment_id = var.compartment_id
}


resource "oci_core_image" "talos_amd64" {
  compartment_id = var.compartment_id
  display_name   = "Talos AMD64"
  launch_mode    = "PARAVIRTUALIZED"

  image_source_details {
    bucket_name              = var.images_bucket
    namespace_name           = data.oci_objectstorage_namespace.default_namespace
    object_name              = "oracle-amd64.oci"
    operating_system         = "Talos"
    operating_system_version = "1.7.6"
    source_image_type        = "QCOW2"
    source_type              = "objectStorageTuple"
  }

  timeouts {
    create = "30m"
  }
}

resource "oci_core_image" "talos_arm64" {
  compartment_id = var.compartment_id
  display_name   = "Talos ARM64"
  launch_mode    = "PARAVIRTUALIZED"

  image_source_details {
    bucket_name              = var.images_bucket
    namespace_name           = data.oci_objectstorage_namespace.default_namespace
    object_name              = "oracle-amd64.oci"
    operating_system         = "Talos"
    operating_system_version = "1.7.6"
    source_image_type        = "QCOW2"
    source_type              = "objectStorageTuple"
  }

  timeouts {
    create = "30m"
  }
}