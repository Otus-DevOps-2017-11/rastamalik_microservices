variable service_account_email {
  description = "service_account_email"
}

variable crendetials_file {
  description = "crendetials_file "
}


variable zone {
  description = "Zone"
}

variable project {
  description = "Project ID"
}

variable region {
  description = "Region"
  default     = "europe-west1"
}

variable public_key_path {
  description = "Path to the public key used for ssh access"
}

variable disk_image {
  description = "Disk image"
}

variable private_key {
  description = "private ssh key"
}
