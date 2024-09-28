module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.24.2"

  cluster_name    = "my-eks-cluster"
  cluster_version = "1.22"

  subnet_ids = module.my-vpc.private_subnets
  vpc_id     = module.my-vpc.vpc_id

  tags = {
    environment = "development"
  }

  eks_managed_node_groups = {
    dev = {
      min_size     = 1
      max_size     = 3
      desired_size = 3

      instance_types = ["t2.small"]
    }
  }
}
