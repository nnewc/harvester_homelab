output "filepath" {
   value = local_sensitive_file.kubeconfig_file.filename
}

output "kubeconfig_content" {
  value = local_sensitive_file.kubeconfig_file.content
}

output "kubeconfig_content_hcl" {
  value = "${yamldecode(local_sensitive_file.kubeconfig_file.content)}"
}