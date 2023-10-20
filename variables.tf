variable "aws_region" {
  description = "value"
  type     = string
}
variable "project_name" {
  description = "value"
  type = string
}
variable "node_size" {
  description = "value"
  type = string
}
variable "node_number" {
  description = "value"
  type = number
}
variable "ami_type" {
  description = "value"
  type = string
}
variable "node_type" {
  description = "value"
  type = string
}
variable "disk_size" {
  description = "value"
  type = number
}
variable "settings" {
  default     = {}
  description = "Additional settings which will be passed to the Helm chart values."
}
variable "profile" {
  description = "value"
  type = string
  default = "default"
}
variable "cluster_version" {
  description = "value"
  type = string
}
variable "vpc_cidr" {
  description = "value"
  type = string
}
variable "private_subnets" {
  description = "value"
  type = list(string)
}
variable "public_subnets" {
  description = "value"
  type = list(string)
}
variable "is_single_nat_across_az" {
  description = "value"
  default = false
  type = bool
}
variable "is_nat_enabled" {
  description = "value"
  default = true
  type = bool
}