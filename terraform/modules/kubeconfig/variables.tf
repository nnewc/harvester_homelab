variable "ssh_user" {
  type = string
  default = ""
}

variable "ssh_host" {
  type = string
  default = ""
}

variable "kubeconfig_filename" {
  type = string
  default = "rke2.yaml"
}