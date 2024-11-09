module "kubeconfig" {
  depends_on = [ module.nodes ]
  source = "./modules/kubeconfig"
  ssh_host = module.nodes.bootstrap-ip
  ssh_user = var.ssh_user
}