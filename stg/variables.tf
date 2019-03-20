variable "project-name" {}

variable "numberOfApp" {}

variable "cluster-name" {}


locals {
  # region for subnet, nat,router and gke

  region = "asia-northeast1"

  env-repo-name="terraform-env-repo-stg"

}


