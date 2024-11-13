
data "harvester_network" "vm_network" {
  name = "vm-net"
}

data "harvester_image" "os_image" {
  name = "ubuntu-rke2"
}

resource "harvester_virtualmachine" "vm1" {
  count     = 2
  name      = "${var.cluster_name}-${count.index}"
  namespace = "default"

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
  
  cpu    = 4
  memory = "8Gi"

  efi         = true
  secure_boot = false

  hostname = "${var.cluster_name}-${count.index}"
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
    size       = "40Gi"
    bus        = "virtio"
    boot_order = 1

    image       = data.harvester_image.os_image.id
    auto_delete = true
  }

  cloudinit  {
    user_data_secret_name = "${var.cluster_name}-${count.index}"
    
  }
}

resource "harvester_cloudinit_secret" "vm" {
  name = "${var.cluster_name}-${count.index}"
  count = 2
  user_data = <<EOF
    #cloud-config
    package_update: true
    packages:
      - qemu-guest-agent
    write_files: 
    - path: /etc/rancher/rke2/config.yaml
      owner: root
      content: |
        token: ${ var.shared_token }
        %{ if count.index > 0}
        server: https://${ var.control_plane_vip }:9345
        %{ endif }
        system-default-registry:  ${ var.system_default_registry }
        tls-san:
          - ${ var.cluster_name}-${count.index}
          - ${ var.control_plane_vip }
        secrets-encryption: true
    - path: /etc/hosts
      owner: root
      content: |
        127.0.0.1 localhost
        127.0.0.1 ${ var.cluster_name}-${count.index}
    - path: /var/lib/rancher/rke2/server/manifests/rancher.yaml
      owner: root
      content: |
        apiVersion: helm.cattle.io/v1
        kind: HelmChart
        metadata:
          namespace: kube-system
          name: rancher
        spec:
          targetNamespace: cattle-system
          createNamespace: true
          version: ${ var.rancher_version }
          chart: rancher
          repo: https://releases.rancher.com/server-charts/${ var.rancher_channel }
          valuesContent: |-
            hostname: rancher.${ var.control_plane_vip }.nip.io
    - path: /var/lib/rancher/rke2/server/manifests/cert-manager.yaml
      owner: root
      content: |
        apiVersion: helm.cattle.io/v1
        kind: HelmChart
        metadata:
          namespace: kube-system
          name: cert-manager
        spec:
          targetNamespace: cert-manager
          createNamespace: true
          bootstrap: true
          version: v1.13.1
          chart: cert-manager
          repo: https://charts.jetstack.io
          valuesContent: |-
            installCRDs: true
    - path: /var/lib/rancher/rke2/server/manifests/kube-vip.yaml
      owner: root
      content: |
        apiVersion: helm.cattle.io/v1
        kind: HelmChart
        metadata:
          name: kube-vip
          namespace: kube-system
        spec:
          chart: kube-vip
          targetNamespace: kube-system
          repo: https://kube-vip.github.io/helm-charts
          valuesContent: |-
            config:
              address: ${ var.control_plane_vip }
            env:
              cp_enable: "true"
              svc_enable: "true"
              svc_election: "true"
              vip_leaderelection: "true"
              vip_interface: "enp1s0"
    runcmd:
    - - systemctl
      - enable
      - '--now'
      - qemu-guest-agent.service
    # %{ if var.airgapped_image != true }
    # - mkdir -p /var/lib/rancher/rke2-artifacts && wget https://get.rke2.io -O /var/lib/rancher/install.sh && chmod +x /var/lib/rancher/install.sh
    # %{ endif }
    - INSTALL_RKE2_CHANNEL=${ var.rke2_channel } /var/lib/rancher/install.sh
    - systemctl enable rke2-server.service
    - useradd -r -c "etcd user" -s /sbin/nologin -M etcd -U
    - systemctl start rke2-server.service
    - echo 'export KUBECONFIG=/etc/rancher/rke2/rke2.yaml' >> /root/.bashrc
    - echo 'export PATH=$PATH:/var/lib/rancher/rke2/bin/' >> /root/.bashrc
    - echo 'source <(kubectl completion bash)' >> /root/.bashrc
    ssh_authorized_keys: 
    - ${ var.ssh_pub_key }
    timezone: US/Central
    users:
    - default
    - name: nathan
      plain_text_passwd: rancher
      lock_passwd: false
      shell: /bin/bash
      sudo: ALL=(ALL) NOPASSWD:ALL
      ssh_authorized_keys:
        - ${ var.ssh_pub_key }
  EOF

  network_data = <<EOM
    network:
      version: 2
      renderer: networkd
      ethernets:
        enp1s0:
          dhcp4: yes
    EOM

}