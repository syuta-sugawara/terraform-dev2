variable "project-name" {}
#variable "project-region" {}

#variable "project-zone" {}

locals {
  # region for subnet, nat,router and gke

  region = "asia-northeast1"

  env-repo-name="terraform-env-repo-dev"

  cluster-name="rpa-dev-cluster"

 
}

variable "numberOfApp" {
  
}
