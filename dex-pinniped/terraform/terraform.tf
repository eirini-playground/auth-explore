variable "name" {
  type = string
  default = "dex-pinniped"
}

variable "node-count-per-zone" {
  type = number
  default = 1
}

variable "region" {
  type = string
  default = "europe-west1"
}

variable "zone" {
  type = string
  default = "europe-west1-b"
}

variable "node-machine-type" {
  type = string
  default = "n1-standard-8"
}

variable "project-id" {
  type = string
  default = "cff-eirini-peace-pods"
}

variable "release-channel" {
  type = string
  default = "REGULAR"
}

provider "google" {
  project     = var.project-id
  region      = var.region
}

terraform {
  backend "gcs" {
    bucket = "eirini-ci"
  }
  required_providers {
    google = ">= 3.69.0"
  }
}

resource "google_compute_subnetwork" "subnetwork" {
  name          = var.name
  ip_cidr_range = "10.2.0.0/16"
  region        = var.region
  network       = google_compute_network.network.id
}

resource "google_compute_network" "network" {
  name = var.name
  auto_create_subnetworks = false
}

resource "google_container_cluster" "cluster" {
  name     = var.name
  location = var.zone

  network = google_compute_network.network.name
  subnetwork = google_compute_subnetwork.subnetwork.name

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count = var.node-count-per-zone

  release_channel {
    channel = var.release-channel
  }

  maintenance_policy {
    daily_maintenance_window {
      start_time = "03:00"
    }
  }

  network_policy {
     enabled = true
  }

  addons_config {
    network_policy_config  {
      disabled = false
    }
  }

  ip_allocation_policy {
    cluster_ipv4_cidr_block  = ""
    services_ipv4_cidr_block = ""
  }

}

resource "google_container_node_pool" "node_pool" {
  name       = var.name
  location   = var.zone
  cluster    = google_container_cluster.cluster.name
  management {
    auto_repair = true
    auto_upgrade = true
  }
  autoscaling {
    min_node_count = var.node-count-per-zone
    max_node_count = 12
  }
  initial_node_count = var.node-count-per-zone

  node_config {
    disk_size_gb = 200
    disk_type = "pd-ssd"
    machine_type = var.node-machine-type
    image_type = "COS_CONTAINERD"

    metadata = {
      disable-legacy-endpoints = "true"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
}

resource "google_compute_address" "ingress_address" {
  name = var.name
  region = var.region
}

output "static_ip" {
  value = google_compute_address.ingress_address.address
}
