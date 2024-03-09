# Required providers definition.
terraform {
  required_providers {
    linode = {
      source = "linode/linode"
    }
    tls = {
      source = "hashicorp/tls"
    }
    auth0 = {
      source = "auth0/auth0"
    }
  }
}