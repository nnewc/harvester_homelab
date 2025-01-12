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

variable "cluster_name" {
  type = string
  default = "rancher-tf"
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

variable "registry_user" {
  type = string
  default = ""
}

variable "registry_password" {
  type = string
  default = ""
}

variable "rancher_bootstrap_password" {
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
