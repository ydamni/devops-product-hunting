### State Locking

terraform {
  backend "s3" {
    bucket         = "product-hunting-terraform-state"
    key            = "prod/operate/hpa/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "product-hunting-terraform-state-lock"
  }
}

### Kubeconfig

provider "kubernetes" {
  config_path = "~/.kube/config"
}

### Horizontal Pod Autoscaler (HPA)

resource "kubernetes_horizontal_pod_autoscaler" "product-hunting-hpa" {
  metadata {
    name = "product-hunting-hpa"
  }

  spec {
    min_replicas = 2
    max_replicas = 5

    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = "product-hunting"
    }

    metric {
      type = "Resource"
      resource {
        name = "cpu"
        target {
          type                = "Utilization"
          average_utilization = "50"
        }
      }
    }

    metric {
      type = "Resource"
      resource {
        name = "memory"
        target {
          type                = "Utilization"
          average_utilization = "50"
        }
      }
    }
  }
}