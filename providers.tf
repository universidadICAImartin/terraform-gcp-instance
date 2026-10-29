terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.5.0"
    }
  }
}

provider "google" {
  credentials = file("../dazzling-matrix-513107-a2-d8ce5216a294.json")

  project = var.gcp-project
  region  = "us-central1"
  zone    = "us-central1-c"
}
