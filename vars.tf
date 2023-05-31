variable "tags" {}
variable "env" {}
variable "subnets" {}
variable "name" {
  default = "elasticache"
}
variable "vpc_id" {}
variable "allow_db_cidr" {}
variable "engine_version" {}
# variable engine {}
variable "kms_arn" {}
variable "port_number" {
  default = 6379
}
variable "num_node_groups" {}
variable "replicas_per_node_group" {}
variable "node_type" {}

