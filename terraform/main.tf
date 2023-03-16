/**
 * Copyright 2018 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

locals {
  cluster_type = "simple-regional-private"
}

data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${module.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
}


module "gke" {
  source                    = "terraform-google-modules/kubernetes-engine/google//modules/private-cluster"
  project_id                = local.project_id
  name                      = "${local.cluster_type}-cluster${var.cluster_name_suffix}"
  regional                  = false
  region                    = var.region
  network                   = google_compute_network.vpc_network.name
  subnetwork                = google_compute_subnetwork.network-gke.name
  ip_range_pods             = "pod"
  ip_range_services         = "service"
  create_service_account    = false
  service_account           = "${google_project.gke_project.number}-compute@developer.gserviceaccount.com"
  enable_private_endpoint   = false
  enable_private_nodes      = true
  master_ipv4_cidr_block    = "172.16.0.0/28"
  default_max_pods_per_node = 20
  remove_default_node_pool  = true
  kubernetes_version = "latest"
  add_cluster_firewall_rules = true
  firewall_inbound_ports = ["10250"]
  zones = ["us-central1-a"]
  identity_namespace = "${local.project_id}.svc.id.goog"

  node_pools = [
    {
      name              = "pool-01"
      min_count         = 1
      max_count         = 5
      local_ssd_count   = 0
      disk_size_gb      = 100
      disk_type         = "pd-standard"
      auto_repair       = true
      auto_upgrade      = false
      service_account   = "${google_project.gke_project.number}-compute@developer.gserviceaccount.com"
      preemptible       = false
      max_pods_per_node = 12
      version = "latest"
    },
  ]

  master_authorized_networks = [
    {
      cidr_block   = "0.0.0.0/0"
      display_name = "all"
    },
  ]
}

resource "google_artifact_registry_repository" "ccm-operator" {
  location      = "us-central1"
  repository_id = "ccm-operator"
  format        = "DOCKER"
  project = google_project.gke_project.project_id
}