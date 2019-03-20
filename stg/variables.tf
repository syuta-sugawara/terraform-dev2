variable "project-name" {}

variable "numberOfApp" {}

variable "cluster-name" {}

variable "env-repo" {}


locals {
  # region for subnet, nat,router and gke

  region = "asia-northeast1"


}


