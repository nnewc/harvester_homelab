data "harvester_image" "os_image" {
  display_name = var.os_image
  namespace = var.os_image_namespace
}

data "harvester_network" "vm_network" {
  name = var.vm_network
}

