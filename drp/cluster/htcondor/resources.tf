variable "bucket_name" {
    type = string
    default = ""
}
variable "cluster_name" {
    type = string
    default = "condor"
}
variable "admin_email" {
    type = string
    default = ""
}
variable "osversion" {
    type = string
    default = "7"
}
variable "osimage" {
    type = string
    default = "lsst"
}
variable "osproject" {
  type = string
  default = "htcondor-lsst"
}
variable "condorversion" {
    type = string
    default = ""
}
variable "project" {
    type = string
}
variable "zone" {
    type = string
}
variable "min_replicas" {
    type = number
    default = 1
}
variable "max_replicas" {
    type = number
    default = 20
}
variable "use_preemptibles" {
    type = bool
    default = true
}
variable "metric_target_loadavg" { 
  type = number 
  default = "1.0"
}
variable "metric_target_queue" { 
  type = number 
  default = 10
}
variable "instance_type" {
  type = string
  default = "n1-standard-4"
}
variable "service_account" {
  type = string
  default = "default"
}
locals{
  compute_startup = templatefile(
    "${path.module}/startup-centos-noinstall.sh", 
    {
      "bucket_name" = var.bucket_name,
      "project" = var.project,
      "cluster_name" = var.cluster_name,
      "htserver_type" = "compute", 
      "osversion" = var.osversion, 
      "condorversion" = var.condorversion, 
      "admin_email" = var.admin_email
    })
  submit_startup = templatefile(
    "${path.module}/startup-centos-noinstall.sh", 
    {
      "bucket_name" = var.bucket_name,
      "project" = var.project,
      "cluster_name" = var.cluster_name,
      "htserver_type" = "submit", 
      "osversion" = var.osversion, 
      "condorversion" = var.condorversion, 
      "admin_email" = var.admin_email
    })
  master_startup = templatefile(
    "${path.module}/startup-centos-noinstall.sh", 
    {
      "bucket_name" = var.bucket_name,
      "project" = var.project,
      "cluster_name" = var.cluster_name,
      "htserver_type" = "master", 
      "osversion" = var.osversion, 
      "condorversion" = var.condorversion, 
      "admin_email" = var.admin_email
    })
}
data "google_compute_image" "startimage" {
  family  = var.osimage
  project = var.osproject
}
resource "google_compute_instance" "condor-master" {
  boot_disk {
    auto_delete = "true"
    device_name = "boot"

    initialize_params {
      image = data.google_compute_image.startimage.self_link
      size  = "200"
      type  = "pd-standard"
    }

    mode   = "READ_WRITE"
  }

  can_ip_forward      = "false"
  deletion_protection = "false"
  enable_display      = "false"

  machine_type            = var.instance_type
  metadata_startup_script = local.master_startup
  name                    = "${var.cluster_name}-master"
  network_interface {
    access_config {
      network_tier = "PREMIUM"
    }

    network            = "default"
    network_ip         = "10.128.0.2"
    subnetwork         = "default"
    subnetwork_project = var.project
  }

  project = var.project

  scheduling {
    automatic_restart   = "true"
    on_host_maintenance = "MIGRATE"
    preemptible         = "false"
  }

  service_account {
    email = var.service_account
    scopes = ["https://www.googleapis.com/auth/logging.write", "https://www.googleapis.com/auth/trace.append", "https://www.googleapis.com/auth/monitoring.write", "https://www.googleapis.com/auth/devstorage.full_control"]
  }

  shielded_instance_config {
    enable_integrity_monitoring = "true"
    enable_secure_boot          = "false"
    enable_vtpm                 = "true"
  }

  tags = ["${var.cluster_name}-master"]
  zone = var.zone
}

resource "google_compute_instance" "condor-submit" {
  boot_disk {
    auto_delete = "true"
    device_name = "boot"

    initialize_params {
      image = data.google_compute_image.startimage.self_link
      size  = "200"
      type  = "pd-standard"
    }

    mode   = "READ_WRITE"
  }

  can_ip_forward      = "false"
  deletion_protection = "false"
  enable_display      = "false"

  labels = {
    goog-dm = "mycondorcluster"
  }

  machine_type            = var.instance_type
  metadata_startup_script = local.submit_startup
  name                    = "${var.cluster_name}-submit"

  network_interface {
    access_config {
      network_tier = "PREMIUM"
    }

    network            = "default"
    network_ip         = "10.128.0.3"
    subnetwork         = "default"
    subnetwork_project = var.project
  }

  project = var.project

  scheduling {
    automatic_restart   = "true"
    on_host_maintenance = "MIGRATE"
    preemptible         = "false"
  }

  service_account {
      email = var.service_account
  #  email  = "487217491196-compute@developer.gserviceaccount.com"
    scopes = ["https://www.googleapis.com/auth/monitoring.write", "https://www.googleapis.com/auth/compute", "https://www.googleapis.com/auth/servicecontrol", "https://www.googleapis.com/auth/devstorage.read_only", "https://www.googleapis.com/auth/logging.write", "https://www.googleapis.com/auth/service.management.readonly", "https://www.googleapis.com/auth/trace.append"]
  }

  shielded_instance_config {
    enable_integrity_monitoring = "true"
    enable_secure_boot          = "false"
    enable_vtpm                 = "true"
  }

  tags = ["${var.cluster_name}-submit"]
  zone = var.zone
}
resource "google_compute_instance_template" "condor-compute" {
  can_ip_forward = "false"

  disk {
    auto_delete  = "true"
    boot         = "true"
    device_name  = "boot"
    disk_size_gb = "200"
    mode         = "READ_WRITE"
    source_image = data.google_compute_image.startimage.self_link
    type         = "PERSISTENT"
  }

  machine_type = var.instance_type

  metadata = {
    startup-script = local.compute_startup
  }

  name = "${var.cluster_name}-compute"

  network_interface {
    access_config {
      network_tier = "PREMIUM"
    }

    network = "default"
  }

  project = var.project
  region  = var.zone

  scheduling {
    automatic_restart   = "false"
    on_host_maintenance = "TERMINATE"
    preemptible         = var.use_preemptibles
  }

  service_account {
      email = var.service_account
  #  email  = "default"
    scopes = ["https://www.googleapis.com/auth/monitoring.write", "https://www.googleapis.com/auth/trace.append", "https://www.googleapis.com/auth/logging.write", "https://www.googleapis.com/auth/devstorage.full_control"]
  }

  tags = ["${var.cluster_name}-compute"]
}
resource "google_compute_instance_group_manager" "condor-compute-igm" {
  base_instance_name = "${var.cluster_name}-compute-instance"
  name               = "${var.cluster_name}-compute-igm"
  project            = var.project
  target_size        = "2"

  update_policy {
    max_surge_fixed         = 5
    minimal_action          = "REPLACE"
    type                    = "OPPORTUNISTIC"
  }

  version {
    instance_template = google_compute_instance_template.condor-compute.self_link
    name              = ""
  }
  timeouts {
    create = "60m"
    delete = "2h"
  }
  # Yup, didn't want to use this, but I was getting create and destroy errors. 
  depends_on = [
   google_compute_instance_template.condor-compute 
  ]
  zone = var.zone
}
resource "google_compute_autoscaler" "condor-compute-as" {
  autoscaling_policy {
    cooldown_period = "60"
    max_replicas    = var.max_replicas

    metric {
      name   = "custom.googleapis.com/q0"
      target = var.metric_target_queue
      type   = "GAUGE"
    }
    metric {
      name   = "custom.googleapis.com/la0"
      target = var.metric_target_loadavg
      type   = "GAUGE"
    }

    min_replicas = var.min_replicas
  }

  name    = "${var.cluster_name}-compute-as"
  project = var.project
  target  = google_compute_instance_group_manager.condor-compute-igm.self_link
  zone    = var.zone
  timeouts {
    create = "60m"
    delete = "2h"
  }

  depends_on = [
   google_compute_instance_group_manager.condor-compute-igm
  ]
}
