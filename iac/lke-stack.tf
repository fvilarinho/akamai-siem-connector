# Applies the LKE stack settings.
resource "null_resource" "applyLkeSettings" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    quiet   = true
    command = "./applyLkeSettings.sh"
  }

  depends_on = [
    local_sensitive_file.privateKey,
    local_sensitive_file.certificate,
    local_sensitive_file.kubeconfig
  ]
}

# Applies the LKE stack services and deployments.
resource "null_resource" "applyLkeStack" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    quiet   = true
    command = "./applyLkeStack.sh"
  }

  depends_on = [ null_resource.applyLkeSettings ]
}