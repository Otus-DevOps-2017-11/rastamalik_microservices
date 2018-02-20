provider "google" {
  version = "1.4.0"
  
  project = "${var.project}"
  region  = "${var.region}"

}
resource "google_service_account_key" "app" {
  service_account_id = "${var.service_account_email}"
  pgp_key = "keybase:keybaseusername"
  public_key_type = "${var.credentials_file}" 
}

resource "google_compute_instance" "app" {
     
  name         = "reddit-app"
  machine_type = "g1-small"
  zone         = "${var.zone}"

  boot_disk {
    initialize_params {
      image = "${var.disk_image}"
    }
  }

  metadata {
    sshKeys = "appuser:${file(var.public_key_path)} "
    
 }



  tags = ["reddit-app"]

  network_interface {
    network       = "default"
    access_config = {}
  }

  connection {
    type        = "ssh"
    user        = "appuser"
    agent       = false
    private_key = "${file(var.private_key)}"
  }
}

