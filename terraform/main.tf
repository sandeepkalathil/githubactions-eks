provider "aws" {
  region = "eu-north-1"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.project_name}-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["eu-north-1a", "eu-north-1b", "eu-north-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = false

  tags = var.common_tags
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = "${var.project_name}-cluster"
  cluster_version = "1.28"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true
  # Removed invalid attribute public_access_cidrs

  eks_managed_node_groups = {
    general = {
      desired_size = 2
      min_size     = 2
      max_size     = 2

      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"

      labels = {
        role = "general"
      }

      tags = var.common_tags
    }
  }

  enable_irsa = true

  node_security_group_additional_rules = {
    ecr_pull = {
      description = "ECR Pull"
      protocol    = "tcp"
      from_port   = 443
      to_port     = 443
      type        = "egress"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  create_cloudwatch_log_group = false
  create_iam_role             = true
  iam_role_use_name_prefix    = false

  attach_cluster_encryption_policy        = true
  cluster_encryption_policy_use_name_prefix = false

  tags = var.common_tags
}

data "aws_caller_identity" "current" {}

resource "aws_ecr_repository" "app_repo" {
  name = var.ecr_repository_name
  image_scanning_configuration {
    scan_on_push = true
  }
  encryption_configuration {
    encryption_type = "AES256"
  }
  tags = var.common_tags
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  }
}

resource "helm_release" "nginx_ingress" {
  name       = "nginx-ingress"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = "ingress-nginx"

  create_namespace = true

  set {
    name  = "controller.service.type"
    value = "LoadBalancer"
  }
}

resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

resource "aws_ecr_repository_policy" "app_repo_policy" {
  repository = aws_ecr_repository.app_repo.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "GitHubActionsPushPull",
        Effect    = "Allow",
        Principal = {
          AWS = aws_iam_role.github_actions_role.arn
        },
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "ecr_push_policy" {
  name        = "ECRPushPolicy"
  description = "Policy to allow GitHub Actions to push to ECR"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["ecr:GetAuthorizationToken"],
        Resource = "*"
      },
      {
        Effect   = "Allow",
        Action   = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:CompleteLayerUpload",
          "ecr:GetDownloadUrlForLayer",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart"
        ],
        Resource = aws_ecr_repository.app_repo.arn
      }
    ]
  })
}

resource "aws_iam_role" "github_actions_role" {
  name = "GitHubActionsECRRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:sandeepkalathil/githubactions-eks:*"
          },
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "eks_deploy_policy" {
  name        = "EKSDeployPolicy"
  description = "Policy to allow GitHub Actions to deploy to EKS"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "eks:DescribeCluster",
          "eks:ListClusters",
          "eks:ListNodegroups",
          "eks:DescribeNodegroup",
          "eks:ListFargateProfiles",
          "eks:DescribeFargateProfile",
          "eks:ListAddons",
          "eks:DescribeAddon",
          "eks:AccessKubernetesApi"
        ]
        Resource = "arn:aws:eks:eu-north-1:${data.aws_caller_identity.current.account_id}:cluster/${var.project_name}-cluster"
      },
      {
        Effect   = "Allow"
        Action   = [
          "iam:PassRole"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "iam:PassedToService" = "eks.amazonaws.com"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "eks_kubectl_policy" {
  name        = "EKSKubectlPolicy"
  description = "Policy to allow GitHub Actions to interact with Kubernetes via IAM"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "eks:AccessKubernetesApi"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_kubectl_attach" {
  role       = aws_iam_role.github_actions_role.name
  policy_arn = aws_iam_policy.eks_kubectl_policy.arn
}


resource "aws_iam_role_policy_attachment" "github_eks_attach" {
  role       = aws_iam_role.github_actions_role.name
  policy_arn = aws_iam_policy.eks_deploy_policy.arn
}


resource "aws_iam_role_policy_attachment" "github_ecr_attach" {
  role       = aws_iam_role.github_actions_role.name
  policy_arn = aws_iam_policy.ecr_push_policy.arn
   
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy_attachment" {
  role       = aws_iam_role.github_actions_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}


resource "aws_iam_role_policy_attachment" "node_ecr_pull" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = module.eks.eks_managed_node_groups["general"].iam_role_name
}

resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_vpc" "this" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_default_vpc" "this" {}