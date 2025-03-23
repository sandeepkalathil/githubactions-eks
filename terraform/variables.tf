variable "project_name" {
  description = "Project name to be used as prefix for resources"
  type        = string
  default = "Freshfarm"
}

variable "region" {
  description = "AWS region where resources will be deployed"
  type        = string
  default     = "eu-north-1"
}

variable "ecr_repository_name" {
  description = "Name of the ECR repository"
  type        = string
  default     = "freshfarm-repo"  # Ensure this value is at least 2 characters long
}


variable "github_repo" {
  description = "GitHub repository in the format 'owner/repo' for OIDC trust policy"
  type        = string
  default     = "sandeepkalathil/githubactions-eks"
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {
    Environment = "production"
    Project     = "stylish-threads"
    Terraform   = "true"
  }
}

output "eks_cluster_id" {
  description = "ID of the created EKS cluster"
  value       = module.eks.cluster_id
}

output "eks_cluster_endpoint" {
  description = "Endpoint for the EKS cluster"
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "eks_cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = module.eks.cluster_certificate_authority_data
}

output "eks_cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = module.eks.cluster_security_group_id
}

output "vpc_id" {
  description = "ID of the created VPC"
  value       = module.vpc.vpc_id
}

output "private_subnets" {
  description = "List of private subnet IDs"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "List of public subnet IDs"
  value       = module.vpc.public_subnets
}

output "ecr_repository_url" {
  description = "URL of the created ECR repository"
  value       = aws_ecr_repository.app_repo.repository_url
}

output "eks_cluster_role_name" {
  description = "IAM Role name used for the EKS cluster"
  value       = module.eks.cluster_iam_role_name
}


output "github_actions_role_name" {
  description = "IAM Role name used for GitHub Actions"
  value       = aws_iam_role.github_actions_role.name
}

output "github_actions_role_arn" {
  description = "IAM Role ARN used for GitHub Actions"
  value       = aws_iam_role.github_actions_role.arn
}
