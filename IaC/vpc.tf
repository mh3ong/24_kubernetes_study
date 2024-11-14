module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.prefix}-k8s-vpc"
  cidr = "192.168.0.0/16"

  azs             = ["${var.region}a", "${var.region}c"]
  public_subnets  = ["192.168.10.0/24", "192.168.20.0/24"]
  map_public_ip_on_launch = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.prefix}-k8s-cluster" = "shared"
    "kubernetes.io/role/elb" = "1"
  }
}