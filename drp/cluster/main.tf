variable "cluster_name" {
  type = string
  default = "condor"
  description = "Name used to prefix resources in cluster."
  
}

module "htcondor" {
  source = "./htcondor/"
  cluster_name = var.cluster_name
  osimage = "lsst"
  osversion = "7"
  bucket_name = "prject-condor-test"
  zone="us-central1-f"
  project="htcondor-lsst"
  max_replicas=20
  min_replicas=1
  service_account="lsst-htc@htcondor-lsst.iam.gserviceaccount.com"
  use_preemptibles=true
}