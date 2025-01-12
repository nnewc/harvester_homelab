variable "cluster_name" {
  type = string
  default = "harv-tf"
}

variable "namespace" {
  type = string
  default = "default"
}

variable "ssh_user" {
  type = string
  default = ""
}

variable "ssh_host" {
  type = string
  default = ""
}

variable "kubeconfig" {
  type = string
  default = "rke2.yaml"
}

variable "kubecontext" {
  type = string
  default = "default"
}

variable "control_plane_vip" {
  type = string
  default = ""
}

variable "system_default_registry" {
  type = string
  default = ""
}

variable "rke2_channel" {
  type = string
  default = "stable"
}

variable "ssh_pub_key" {
  type = string
  default = ""
}

variable "airgapped_image" {
  type = bool
  default = false
}

variable "shared_token" {
  type = string
  default = "i-am-a-token"
}

variable "rancher_channel" {
  type = string
  default = "stable"
}

variable "rancher_version" {
  type = string
  default = ""
}

variable "master_cpu_count" {
  type = number
  default = 4
}

variable "master_mem_size" {
  type = string
  default = "8Gi"
}

variable "master_disk_size" {
  type = string
  default = "40Gi"
}

variable "master_node_count" {
  type = number
  default = 0
}

variable "worker_node_count" {
  type = number
  default = 0
}

variable "worker_cpu_count" {
  type = number
  default = 4
}

variable "worker_mem_size" {
  type = string
  default = "8Gi"
}

variable "worker_disk_size" {
  type = string
  default = "40Gi"
}

variable "os_image" {
  type = string
  default = ""
}

variable "os_image_namespace" {
  type = string
  default = "default"
}

variable "vm_network" {
  type = string
  default = ""
}

variable "vm_network_namespace" {
  type = string
  default = "default"
}

variable "rancher_bootstrap_password" {
  type = string
  default = ""
}

variable "registry_user" {
  type = string
  default = ""
}

variable "registry_password" {
  type = string
  default = ""
}

variable "cert_manager_version" {
  type = string
  default = ""
}

variable "rancher_chart_url" {
  type = string
  default = ""
}

variable "registry_endpoint" {
  type = string
  default = ""
}