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
  default = "AdministratorAccess-899363120725"
}
variable "cluster_version" {
  description = "value"
  type = string
}