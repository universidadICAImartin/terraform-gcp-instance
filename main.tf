resource "google_compute_address" "tf-vm-ip" {
name = "ipv4-address-tf-vm"
}
resource "google_compute_instance" "tf-vm" {
  name         = "tf-vm"
  zone         = "us-central1-c"
  machine_type = "n1-standard-1"
  allow_stopping_for_update = true
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  # Add SSH access to the Compute Engine instance
  metadata = {
    ssh-keys = "${var.gcp-username}:${file("~/.ssh/id_rsa.pub")}"
  }

  # Add http tag to the instance to identify it in the firewall rule
  tags = ["http"]

  # Startup script
  metadata_startup_script = file("setup-docker.sh")

  network_interface {
    network    = var.gcp-network
    subnetwork = var.gcp-network

    access_config {nat_ip = google_compute_address.tf-vm-ip.address}
  }
}
output "tf-vm-ip" {
value = google_compute_address.tf-vm-ip.address
depends_on = [google_compute_instance.tf-vm]
}

resource "google_compute_disk" "tf-disk" { 
  name = "tf-disk"
  type = "pd-ssd"
  size = 1 
}
resource "google_compute_attached_disk" "attached-tf-disk" {
  disk = google_compute_disk.tf-disk.id 
  instance = google_compute_instance.tf-vm.id 
}

output "tf-vm-internal-ip" {
  value      = google_compute_instance.tf-vm.network_interface.0.network_ip
  depends_on = [google_compute_instance.tf-vm]
}

output "tf-vm-ephemeral-ip" {
  value      = google_compute_instance.tf-vm.network_interface.0.access_config.0.nat_ip
  depends_on = [google_compute_instance.tf-vm]
}
