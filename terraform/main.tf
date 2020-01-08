terraform {
  required_version = "~> 0.12"
  backend "gcs" {
    bucket      = "circleci-gke-terraform-demo-1"
    prefix      = "terraform/state"
    credentials = "account.json"
  }
}

provider "google" {
  credentials = file("account.json")
  project     = "development-257513"
  region      = "europe-west1"
}

resource "google_container_cluster" "gke-cluster" {
  name                     = "dev-cluster"
  location                 = "europe-west1-b"
  remove_default_node_pool = true
  # In regional cluster (location is region, not zone) 
  # this is a number of nodes per zone 
  initial_node_count = 1
}

resource "google_container_node_pool" "preemptible_node_pool" {
  name     = "dev-cluster-node-pool"
  location = "europe-west1-b"
  cluster  = google_container_cluster.gke-cluster.name
  # In regional cluster (location is region, not zone) 
  # this is a number of nodes per zone
  node_count = 1

  node_config {
    preemptible  = true
    machine_type = "n1-standard-1"
    oauth_scopes = [
      "storage-ro",
      "logging-write",
      "monitoring"
    ]
  }
}
