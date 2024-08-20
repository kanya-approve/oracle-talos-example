terraform {
  cloud {
    organization = var.tf_organization

    workspaces {
      project = var.tf_project
    }
  }
}
