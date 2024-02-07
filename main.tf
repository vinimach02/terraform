resource "google_compute_subnetwork" "cluster_subnet" {
  name          = "cluster-subnet"
  ip_cidr_range = "10.2.0.0/16"
  region        = var.location
  network       = google_compute_network.cluster_network.id
  secondary_ip_range {
    range_name    = "services-range"
    ip_cidr_range = "192.168.1.0/24"
  }

  secondary_ip_range {
    range_name    = "pod-ranges"
    ip_cidr_range = "192.168.64.0/22"
  }

}

resource "google_compute_network" "cluster_network" {
  name                    = "cluster-network"
  auto_create_subnetworks = false
}

resource "google_container_cluster" "gke_cluster-1" {
  name               = "gke-cluster-1"
  location           = var.location
  initial_node_count = 1

  network    = google_compute_network.cluster_network.id
  subnetwork = google_compute_subnetwork.cluster_subnet.id
  addons_config {
    dns_cache_config {
      enabled = true
    }

    gce_persistent_disk_csi_driver_config {
      enabled = true
    }

    horizontal_pod_autoscaling {
      disabled = false
    }

    http_load_balancing {
      disabled = false
    }

    network_policy_config {
      disabled = true
    }
  }

  node_config {
    disk_size_gb = 100
    disk_type = "pd-standard"
    image_type = "COS_CONTAINERD"
    machine_type = "e2-standard-2"
    labels = {
      k8s-anthos-dev-node = true
    }
    metadata = {
      disable-legacy-endpoints = true
    }
  }

  cluster_autoscaling {
    autoscaling_profile = "BALANCED"
    enabled             = false
  }

  database_encryption {
    state = "DECRYPTED"
  }

  default_max_pods_per_node = 100
  default_snat_status {
    disabled = false
  }

  enable_intranode_visibility = true
  enable_shielded_nodes       = false
  logging_config {
    enable_components = ["SYSTEM_COMPONENTS", "WORKLOADS"]
  }

  master_auth {
    client_certificate_config {
      issue_client_certificate = false
    }
  }

  master_authorized_networks_config {
    cidr_blocks {
      cidr_block = "0.0.0.0/0"
    }
  }

  node_locations = [var.location-node]
  notification_config {
    pubsub {
      enabled = false
    }
  }


}