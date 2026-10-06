terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.3"
    }
  }
}

provider "helm" {
  kubernetes = {
    config_path    = "~/.kube/config"
    config_context = "kind-what3words"
  }
}

resource "helm_release" "greeter" {
  name             = "greeter"
  namespace        = "greeter"
  create_namespace = true
  upgrade_install  = true #Add on considering existing helm release  greeter in namespace greeter in task 3

  chart = "../helm/greeter"

  set = [
    {
      name  = "replicaCount"
      value = var.replica_count
    },
    {
      name  = "greetingName"
      value = var.greeting_name
    },
    {
      name  = "version"
      value = var.environment
    }
  ]
}