resource "harvester_cloudinit_secret" "bootstrap" {
  name = local.bootstrap_vm_name
  user_data = <<EOF
    #cloud-config
    package_update: true
    package_upgrade: true
    packages:
      - qemu-guest-agent
    write_files: 
    - path: /etc/rancher/rke2/config.yaml
      owner: root
      content: |
        token: ${var.shared_token}
        system-default-registry:  ${var.system_default_registry}
        tls-san:
          - ${local.bootstrap_vm_name}
          - ${var.control_plane_vip}
        secrets-encryption: true
    - path: /etc/hosts
      owner: root
      content: |
        127.0.0.1 localhost
        127.0.0.1 ${local.bootstrap_vm_name}
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
          version: ${var.rancher_version}
          chart: rancher
          repo: https://releases.rancher.com/server-charts/${var.rancher_channel}
          valuesContent: |-
            hostname: rancher.${var.control_plane_vip}.nip.io
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
    # - path: /var/lib/rancher/rke2/server/manifests/kube-vip.yaml
    #   owner: root
    #   content: |
    #     apiVersion: helm.cattle.io/v1
    #     kind: HelmChart
    #     metadata:
    #       name: kube-vip
    #       namespace: kube-system
    #     spec:
    #       chart: kube-vip
    #       targetNamespace: kube-system
    #       repo: https://kube-vip.github.io/helm-charts
    #       valuesContent: |-
    #         config:
    #           address: ${var.control_plane_vip}
    #         env:
    #           cp_enable: "true"
    #           svc_enable: "true"
    #           svc_election: "true"
    #           vip_leaderelection: "true"
    #           vip_interface: "enp1s0"
    runcmd:
    - - systemctl
      - enable
      - '--now'
      - qemu-guest-agent.service
    %{ if var.airgapped_image != true }
    - mkdir -p /var/lib/rancher/rke2-artifacts && wget https://get.rke2.io -O /var/lib/rancher/install.sh && chmod +x /var/lib/rancher/install.sh
    %{ endif }
    - INSTALL_RKE2_CHANNEL=${ var.rke2_channel } /var/lib/rancher/install.sh
    - systemctl enable rke2-server.service
    - useradd -r -c "etcd user" -s /sbin/nologin -M etcd -U
    - systemctl start rke2-server.service
    - echo 'source /etc/bash_completion' >> /root.bashrc
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

resource "harvester_cloudinit_secret" "master" {
    name = "${format("${var.cluster_name}-master-%03d",count.index + 1)}"
    count = var.master_node_count
    user_data = <<EOF
    #cloud-config
    package_update: true
    package_upgrade: true
    packages:
      - qemu-guest-agent
    write_files: 
    - path: /etc/rancher/rke2/config.yaml
      owner: root
      content: |
        token: ${var.shared_token}
        server: https://${var.control_plane_vip}:9345
        system-default-registry:  ${var.system_default_registry}
        tls-san:
          - ${format("${var.cluster_name}-master-%03d",count.index + 1)}
          - ${var.control_plane_vip}
        secrets-encryption: true
    - path: /etc/hosts
      owner: root
      content: |
        127.0.0.1 localhost
        127.0.0.1 ${format("${var.cluster_name}-master-%03d",count.index + 1)}
    runcmd:
    - - systemctl
      - enable
      - '--now'
      - qemu-guest-agent.service
    %{ if var.airgapped_image != true }
    - mkdir -p /var/lib/rancher/rke2-artifacts && wget https://get.rke2.io -O /var/lib/rancher/install.sh && chmod +x /var/lib/rancher/install.sh
    %{ endif }
    - INSTALL_RKE2_CHANNEL=${ var.rke2_channel } /var/lib/rancher/install.sh
    - systemctl enable rke2-server.service
    - useradd -r -c "etcd user" -s /sbin/nologin -M etcd -U
    - systemctl start rke2-server.service
    - echo 'source /etc/bash_completion
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

resource "harvester_cloudinit_secret" "worker" {
    name = "${format("${var.cluster_name}-worker-%03d",count.index)}"
    count = var.worker_node_count
    user_data = <<EOF
    #cloud-config
    package_update: true
    package_upgrade: true
    packages:
      - qemu-guest-agent
    write_files: 
    - path: /etc/rancher/rke2/config.yaml
      owner: root
      content: |
        token: ${var.shared_token}
        server: https://${var.control_plane_vip}:9345
        system-default-registry:  ${var.system_default_registry}
    - path: /etc/hosts
      owner: root
      content: |
        127.0.0.1 localhost
        127.0.0.1 ${format("${var.cluster_name}-worker-%03d",count.index)}
    runcmd:
    - - systemctl
      - enable
      - '--now'
      - qemu-guest-agent.service
    %{ if var.airgapped_image != true }
    - mkdir -p /var/lib/rancher/rke2-artifacts && wget https://get.rke2.io -O /var/lib/rancher/install.sh && chmod +x /var/lib/rancher/install.sh
    %{ endif }
    - INSTALL_RKE2_CHANNEL=${ var.rke2_channel } INSTALL_RKE2_TYPE=agent /var/lib/rancher/install.sh
    - systemctl enable rke2-agent.service
    - systemctl start rke2-agent.service
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