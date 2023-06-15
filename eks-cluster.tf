provider "kubernetes" {
    load_config_file = "false"
    host = data.aws_eks_cluster.myapp-cluster.endpoint
    token = data.aws_eks_cluster_auth.myapp-cluster.token
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.myapp-cluster.certificate_authority.0.data)
}

data "aws_eks_cluster" "myapp-cluster" {
    name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "myapp-cluster" {
    name = module.eks.cluster_id
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.15.3"

  cluster = "my-cluster"
  cluster_version = 1.27

  subnet_ids = module.my-app.private_subnets
  vpc_ids = module.my-app.vpc_ids

  tags = {
    environment = "development"
    application = "myapp"
  }

  worker_groups = [
    {
        instance_type = "t2.small"
        name = "worker-group-1"
        asg_desired_capacity = 2
    },
    {
        instance_type = "t2.medium"
        name = "worker-group-2"
        asg_desired_capacity = 1
    }
  ]
}