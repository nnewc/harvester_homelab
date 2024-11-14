# Harvester Terraform

This folder is used to generate infrastructure on Harvester via Terraform

## Prerequisites

You will need to have a kubeconfig (rke2.yaml) present for the harvester cluster. See kubeconfig variable
You will need to have `ssh-agent` running and configured with your keys that you are providing to the Harvester VMs for provisioning.

## Rancher Cluster

A Rancher cluster is needed to provision other downstream clusters on harvester. 