terraform {
  required_providers {
    ssh = {
      source  = "loafoe/ssh"
      version = "2.6.0"
    }
  }
}

# locals {
#   kubeconfig_yaml = "${replace(ssh_resource.kubeconfig_output.result, "127.0.0.1", var.ssh_host)}"
#   kubeconfig_hcl  = yamldecode(local.kubeconfig_yaml)
# }


resource "ssh_sensitive_resource" "kubeconfig_output" {
   # The default behaviour is to run file blocks and commands at create time
  # You can also specify 'destroy' to run the commands at destroy time
  when = "create"

  host         = var.ssh_host
  user         = var.ssh_user
  agent        = true
  # An ssh-agent with your SSH private keys should be running

  
  # Try to complete in at most 15 minutes and wait 5 seconds between retries
  timeout     = "1m"

  commands = [
    "sudo sed \"s/127.0.0.1/${var.ssh_host}/g\" /etc/rancher/rke2/rke2.yaml"
  ]
}

resource "local_sensitive_file" "kubeconfig_file" {
  content = ssh_sensitive_resource.kubeconfig_output.result
  filename = "${var.kubeconfig_filename}"
}