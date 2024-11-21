module "efs" {
  count = var.enable_efs_csi_driver ? 1 : 0
  source = "terraform-aws-modules/efs/aws"

  name           = "${var.prefix}-efs"
  encrypted      = true

  # File system policy
  attach_policy                      = true
  bypass_policy_lockout_safety_check = false

  # Mount targets / security group
  mount_targets = {
    "${var.region}a" = {
      subnet_id = module.vpc.public_subnets[0]
    }
    "${var.region}c" = {
      subnet_id = module.vpc.public_subnets[1]
    }
  }
  security_group_description = "Example EFS security group"
  security_group_vpc_id      = module.vpc.vpc_id
  security_group_rules = {
    vpc = {
      # relying on the defaults provdied for EFS/NFS (2049/TCP + ingress)
      description = "NFS ingress from VPC private subnets"
      cidr_blocks = [module.vpc.vpc_cidr_block]
    }
  }
}