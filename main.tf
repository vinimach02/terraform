resource "google_compute_subnetwork" "cluster_subnet" {
    name      = "cluster-subnet"
    ip_cidr_range = "10.2.0.0/16"
    region = var.location
    network = google_compute_network.cluster_network.id
    secondary_ip_range {
      range_name =  "services-range"
      ip_cidr_range = "192.168.1.0/24"
    }

    secondary_ip_range  {
      range_name = "pod-ranges"
      ip_cidr_range = "192.168.64.0/22"
    }

}

resource "google_compute_network" "cluster_network" {
  name = "cluster-network"
  auto_create_subnetworks = false
}

resource "google_container_cluster" "gke_cluster-1" {
    name = "gke-cluster-1"
    location = var.location
    initial_node_count = 1

    network = google_compute_network.cluster_network.id
    subnetwork = google_compute_subnetwork.cluster_subnet.id

    node_config {
      machine_type = "e2-standard-2"
      metadata = {
        disable-legacy-endpoints = true
      }  
    }
    
    
}