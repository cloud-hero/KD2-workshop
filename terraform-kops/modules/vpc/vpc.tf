resource "google_compute_network" "vpc" {
  name                    = "kube-vpc"
  auto_create_subnetworks = "true"
}

output "network_name" {
  value = google_compute_network.vpc.name
}