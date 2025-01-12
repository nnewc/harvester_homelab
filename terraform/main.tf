
module "rancher_cluster" {
  source = "./modules/rke2_cluster"
  cluster_name = "rancher-tf"
  kubeconfig = "rke2.yaml"
  vm_network = "host"
  os_image = "ubuntu24-04"
  ssh_pub_key = var.ssh_pub_key
  ssh_user = var.ssh_user
  control_plane_vip = "192.168.60.101"
  worker_node_count = 2
  rancher_bootstrap_password = var.rancher_bootstrap_password
  rancher_version = var.rancher_version
  cert_manager_version = var.cert_manager_version
  rke2_channel = var.rke2_channel
  rancher_chart_url = "https://rancherfederal.github.io/carbide-charts"
  system_default_registry = "rgcrprod.azurecr.us"
  registry_user = var.registry_user
  registry_password = var.registry_password
}