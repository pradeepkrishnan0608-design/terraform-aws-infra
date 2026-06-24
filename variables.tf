variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "instance_type" {
  description = "EC2 Instance Type"
  type        = string
}

variable "ami_id" {
  description = "Ubuntu AMI"
  type        = string
}

variable "key_name" {
  description = "EC2 Key Pair"
  type        = string
}

variable "public_server_count" {
  description = "Number of public EC2 instances"
  type        = number
}
