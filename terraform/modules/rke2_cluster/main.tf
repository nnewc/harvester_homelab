locals {
  bootstrap_vm_name = "${var.cluster_name}-master-000"
}

resource "harvester_virtualmachine" "bootstrap-node" {
  name      = local.bootstrap_vm_name
  namespace = var.namespace

  tags = {
    ssh-user = var.ssh_user
    cluster-name = var.cluster_name
    rke2-role = "server"
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'Waiting for cloud-init to complete...'",
      "cloud-init status --wait > /dev/null",
      "echo 'Completed cloud-init!'",
    ]

    connection {
      type        = "ssh"
      host        = self.network_interface[index(self.network_interface.*.name, "nic-1")].ip_address
      user        = var.ssh_user
      certificate = var.ssh_pub_key
      agent       = true
      script_path = "/tmp/user-data-check.sh"
    }
  }

  description = "test image"
  
  cpu    = var.master_cpu_count
  memory = var.master_mem_size

  efi         = true
  secure_boot = false

  hostname = local.bootstrap_vm_name
  run_strategy = "RerunOnFailure"
  machine_type = "q35"
  restart_after_update = true

  network_interface {
    name         = "nic-1"
    network_name = data.harvester_network.vm_network.id
    wait_for_lease = true
  }

  disk {
    name       = "os-disk"
    type       = "disk"
    size       = var.master_disk_size
    bus        = "virtio"
    boot_order = 1

    image       = data.harvester_image.os_image.id
    auto_delete = true
  }

  cloudinit  {
    user_data_secret_name = local.bootstrap_vm_name
  }
}

resource "harvester_virtualmachine" "master-nodes" {
    depends_on = [ harvester_virtualmachine.bootstrap-node ]

    name      = "${format("${var.cluster_name}-master-%03d",count.index + 1)}"
    count = var.master_node_count
    namespace = var.namespace

    tags = {
        ssh-user = var.ssh_user
        cluster-name = var.cluster_name
        rke2-role = "server"
    }

    provisioner "remote-exec" {
        inline = [
        "echo 'Waiting for cloud-init to complete...'",
        "cloud-init status --wait > /dev/null",
        "echo 'Completed cloud-init!'",
        ]

        connection {
        type        = "ssh"
        host        = self.network_interface[index(self.network_interface.*.name, "nic-1")].ip_address
        user        = var.ssh_user
        certificate = var.ssh_pub_key
        agent       = true
        script_path = "/tmp/user-data-check.sh"
        }
    }

    description = "test image"
    
    cpu    = var.master_cpu_count
    memory = var.master_mem_size

    efi         = true
    secure_boot = false

    hostname = "${format("${var.cluster_name}-master-%03d",count.index + 1)}"
    run_strategy = "RerunOnFailure"
    machine_type = "q35"
    restart_after_update = true

    network_interface {
        name         = "nic-1"
        network_name = data.harvester_network.vm_network.id
        wait_for_lease = true
    }

    disk {
        name       = "os-disk"
        type       = "disk"
        size       = var.master_disk_size
        bus        = "virtio"
        boot_order = 1

        image       = data.harvester_image.os_image.id
        auto_delete = true
    }

    cloudinit  {
        user_data_secret_name = "${format("${var.cluster_name}-master-%03d",count.index + 1)}"
    }

}

resource "harvester_virtualmachine" "worker-nodes" {
    depends_on = [ harvester_virtualmachine.bootstrap-node ]

    name      = "${format("${var.cluster_name}-worker-%03d",count.index)}"
    count = var.worker_node_count
    namespace = var.namespace

    tags = {
        ssh-user = var.ssh_user
        cluster-name = var.cluster_name
        rke2-role = "worker"
    }

    provisioner "remote-exec" {
        inline = [
        "echo 'Waiting for cloud-init to complete...'",
        "cloud-init status --wait > /dev/null",
        "echo 'Completed cloud-init!'",
        ]

        connection {
        type        = "ssh"
        host        = self.network_interface[index(self.network_interface.*.name, "nic-1")].ip_address
        user        = var.ssh_user
        certificate = var.ssh_pub_key
        agent       = true
        script_path = "/tmp/user-data-check.sh"
        }
    }

    description = "test image"
    
    cpu    = var.worker_cpu_count
    memory = var.worker_mem_size

    efi         = true
    secure_boot = false

    hostname = "${format("${var.cluster_name}-worker-%03d",count.index)}"
    run_strategy = "RerunOnFailure"
    machine_type = "q35"
    restart_after_update = true

    network_interface {
        name         = "nic-1"
        network_name = data.harvester_network.vm_network.id
        wait_for_lease = true
    }

    disk {
        name       = "os-disk"
        type       = "disk"
        size       = var.worker_disk_size
        bus        = "virtio"
        boot_order = 1

        image       = data.harvester_image.os_image.id
        auto_delete = true
    }

    cloudinit  {
        user_data_secret_name = "${format("${var.cluster_name}-worker-%03d",count.index)}"
    }
}
