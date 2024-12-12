variable "rancher_api_url" {
    type = string
    default = ""
}

variable "rancher_admin_password" {
  type = string
  default = ""
}

variable "carbide_charts_url" {
  type = string
  default = "https://rancherfederal.github.io/carbide-charts"
}

variable "insecure_api" {
  type = bool
  default = false
  description = "toggle to disable HTTPS certificate verification in the module"
}

variable "registry_user" {
  type = string
  default = ""
}

variable "registry_password" {
  type = string
  default = ""
}

variable "system_default_registry" {
  type = string
  default = ""
}

variable "kubeconfig_filepath" {
  type = string
  description = "kubeconfig to cluster Rancher will be installed on"
  default = "rke2.yaml"
}

variable "rancher_server" {
  type = string
  default = ""
}

variable "rancher_version" {
  type = string
  default = "2.8.2"
}

variable "cert_manager_version" {
  type = string
  default = ""
}

variable "rancher_bootstrap_password" {
  type = string
  default = ""
}