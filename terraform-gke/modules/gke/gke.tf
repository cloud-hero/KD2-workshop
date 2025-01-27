resource "google_container_cluster" "primary" {
  name                     = "${var.project_id}-gke"
  location                 = var.region
  min_master_version       = "1.16.15-gke.4300"
  //min_master_version       = "1.17.14-gke.1600"

  remove_default_node_pool = true
  initial_node_count       = 1
  network                  = google_compute_network.vpc.name
  subnetwork               = google_compute_subnetwork.subnet.name
}

resource "google_container_node_pool" "primary_nodes" {
  name           = "${google_container_cluster.primary.name}-node-pool"
  location       = var.region
  cluster        = google_container_cluster.primary.name
  node_locations = ["${var.region}-a","${var.region}-b"]
  node_count     = var.gke_num_nodes
  version        = "1.16.15-gke.4300"
  //version        = "1.17.14-gke.1600"
  
  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/devstorage.read_write",
    ]

    labels = {
      env = var.project_id
    }

    machine_type = "n1-standard-2"
    tags         = ["gke-node", "${var.project_id}-gke"]
    metadata = {
      disable-legacy-endpoints = "true"
      ssh-keys = "${var.gce_ssh_user}:${file(var.gce_ssh_pub_key_file)}"
    }
  }

  management {
    auto_upgrade = false
  }

  provisioner "local-exec" {
    command = "gcloud container clusters get-credentials ${var.project_id}-gke --region europe-west3"
  }
}

resource "google_compute_firewall" "primary_node_firewall" {
  name    = "${google_container_cluster.primary.name}-firewall"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  target_tags = ["gke-node"]
}

