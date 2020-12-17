provider "google" {
  project = var.project_id
  region  = var.region
}

module "gke" {
    source                  = "./modules/gke"
    gke_num_nodes           = 1
    region                  = var.region
    project_id              = var.project_id
    gce_ssh_pub_key_file    = var.gce_ssh_pub_key_file
    gce_ssh_user            = var.gce_ssh_user
}