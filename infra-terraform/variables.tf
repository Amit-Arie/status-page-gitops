variable "aws_region" {
	description	= "AWS region to deploy into"
	type		= string
	default		= "us-east-1"
}

variable "project_name" {
	description	= "Prefix used for naming/tagging all resources"
	type		= string
	default		= "team-project"
}

variable "vpc_cidr" {
	description	= "CIDR block for the VPC"
	type		= string
	default		= "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
	description	= "CIDR blocks for public subnets (one per AZ)"
	type		= list(string)
	default		= ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
	description	= "CIDR blocks for private subnets (one per AZ)"
	type		= list(string)
	default		= ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "availability_zones" {
	description	= "AZs to spread subnets across"
	type		= list(string)
	default		= ["us-east-1a", "us-east-1b"]
}

variable "whitelisted_ips" {
	description	= "CIDR blocks allowed to reach SSH / K8s API / NodePorts"
	type		= list(string)
	default		= ["5.29.181.138/32", "176.229.245.171/32"]
}

variable "key_pair_name" {
	description	= "Existing EC2 key pair name for SSH access to the K3s node"
	type		= string
}

variable "instance_type" {
	description	= "Instance type for the K3s and Jenkins nodes"
	type		= string
	default		= "t3.large"
}

variable "domain_name" {
	description	= "Root domain already registered/hosted in Route53"
	type		= string
  default = ""
}

variable "subdomain" {
	description 	= "Subdomain to point at the K3s ingress"
	type		= string
	default		= "app"
}

variable "ecr_repo_name" {
	description	= "Name of the ECR repository Jenkins will push images to"
	type		= string
	default		= "team-project-app"
}
