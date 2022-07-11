### State Locking

terraform {
  backend "s3" {
    bucket         = "product-hunting-terraform-state"
    key            = "prod/deploy/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "product-hunting-terraform-state-lock"
  }
}

### Add AWS Certificate Manager certificate

data "aws_acm_certificate" "product-hunting-acm-certificate" {
  domain   = "devops-product-hunting.com"
  statuses = ["ISSUED"]
}

### Kubernetes resources

provider "kubernetes" {
  config_path = "~/.kube/config"
}

resource "kubernetes_service" "product-hunting-kube-service" {
  metadata {
    name = "product-hunting"
    annotations = {
      "service.beta.kubernetes.io/aws-load-balancer-ssl-cert"         = data.aws_acm_certificate.product-hunting-acm-certificate.arn
      "service.beta.kubernetes.io/aws-load-balancer-backend-protocol" = "tcp"
      "service.beta.kubernetes.io/aws-load-balancer-ssl-ports"        = "443,5000"
    }
    labels = {
      app = "product-hunting"
    }
  }

  spec {
    selector = {
      app = "product-hunting"
    }

    type = "LoadBalancer"

    port {
      name        = "http"
      port        = 80
      target_port = 80
    }

    port {
      name        = "https"
      port        = 443
      target_port = 443
    }

    port {
      name        = "api"
      port        = 5000
      target_port = 5000
    }
  }
}

resource "kubernetes_deployment" "product-hunting-kube-deployment" {
  metadata {
    name = "product-hunting"
    labels = {
      app = "product-hunting"
    }
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        app = "product-hunting"
      }
    }

    template {
      metadata {
        labels = {
          app = "product-hunting"
        }
      }

      spec {
        ### Start each pod on a different node
        affinity {
          pod_anti_affinity {
            preferred_during_scheduling_ignored_during_execution {
              weight = 1
              pod_affinity_term {
                topology_key = "failure-domain.beta.kubernetes.io/zone"
                label_selector {
                  match_expressions {
                    key      = "app"
                    operator = "In"
                    values   = ["product-hunting"]
                  }
                }
              }
            }
          }
        }

        container {
          name  = "product-hunting-postgres"
          image = "${var.ecr_registry}/product-hunting-postgres:prod-${var.ci_commit_short_sha}"

          port {
            container_port = 5432
          }
        }

        container {
          name  = "product-hunting-api"
          image = "${var.ecr_registry}/product-hunting-api:prod-${var.ci_commit_short_sha}"

          port {
            container_port = 5000
          }

          env {
            name  = "POSTGRES_HOST"
            value = "localhost"
          }
        }

        container {
          name  = "product-hunting-client"
          image = "${var.ecr_registry}/product-hunting-client:prod-${var.ci_commit_short_sha}"

          port {
            container_port = 80
          }

          port {
            container_port = 443
          }
        }
      }
    }
  }
}

### Kubernetes generated Elastic Load Balancer

locals {
  elb_name = split("-", split(".", kubernetes_service.product-hunting-kube-service.status.0.load_balancer.0.ingress.0.hostname).0).0
}

data "aws_elb" "product-hunting-elb" {
  name = local.elb_name
}

### Route 53 Zone record

data "aws_route53_zone" "product-hunting-route53-zone" {
  name         = "devops-product-hunting.com."
  private_zone = false
}

resource "aws_route53_record" "product-hunting-route53-record" {
  zone_id = data.aws_route53_zone.product-hunting-route53-zone.zone_id
  name    = "devops-product-hunting.com"
  type    = "A"

  alias {
    name                   = data.aws_elb.product-hunting-elb.dns_name
    zone_id                = data.aws_elb.product-hunting-elb.zone_id
    evaluate_target_health = true
  }
}
