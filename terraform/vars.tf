# variable "AWS_ACCESS_KEY_ID" {
#   type = string
# }

# variable "AWS_SECRET_ACCESS_KEY" {
#   type = string
# }

variable "REGION" {
  type    = string
  default = "eu-west-2"
}

variable "DB_NAME" {
  type    = string
  default = "wpdatabase"
}

variable "DB_USER" {
  type    = string
  default = "dbadmin"
}

variable "WP_USER" {
  type    = string
  default = "wpadmin"
}

variable "EFS_TOKEN" {
  type    = string
  default = "aws23stream-efs-token"
}

variable "az_list" {
  description = "AZs in this region"
  default     = ["eu-west-2a", "eu-west-2b"]
  type        = list(any)
}

variable "subnet_cidrs" {
  description = "Subnet CIDRs for public subnets"
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
  type        = list(any)
}

variable "private_subnet_cidrs" {
  description = "Subnet CIDRs for private subnets"
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
  type        = list(any)
}

