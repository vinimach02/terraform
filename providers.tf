terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.14.0"
    }
  }
}

provider "google" {
  credentials = file("terraform-with-gcp.json")
  project     = var.project
  region      = "us-central1"
  zone        = "us-central1-c"
}