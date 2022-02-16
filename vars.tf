variable "client_port" {
  description = "The port which the client should use"
  type        = string
}
variable "client_security_group_ids" {
  description = "The security groups to attach to the client side endpoint"
  type        = list(string)
}
variable "client_subnets" {
  description = "The subnets to connect the client side endpoint to"
  type        = list(string)
}
variable "client_vpc_id" {
  description = "The client side VPC"
  type        = string
}

variable "service_hostname" {
  description = "The hostname of the service that is the target of this private link"
  type        = string
}
variable "service_port" {
  description = "The port on which the service runs"
  type        = string
}
variable "service_subnets" {
  description = "The subnets the service side load balancer should connect to"
  type        = list(string)
}
variable "service_vpc_id" {
  description = "The service side VPC"
  type        = string
}

variable "name_prefix" {
  description = "The prefix to add to all resources created"
  type        = string
}

variable "tags" {
  description = "The tags to add to the resources"
  type        = map(string)
  default     = {}
}
