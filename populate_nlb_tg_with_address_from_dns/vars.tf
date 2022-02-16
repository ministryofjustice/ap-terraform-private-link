variable "service_hostname" {
  type        = string
  description = "the DNS name of the target servcice"
}

variable "nlb_tg_arn" {
  type        = string
  description = "Network Log Balancer Target Group arn"
}

variable "max_lookup_per_invocation" {
  type        = string
  default     = "10"
  description = "Maximum number of invocations of DNS lookup"
}

variable "schedule_expression" {
  default     = "cron(5 * * * ? *)"
  description = "the aws cloudwatch event rule scheule expression that specifies when the scheduler runs. Default is 5 minuts past the hour. for debugging use 'rate(5 minutes)'. See https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/ScheduledEvents.html"
}

variable "resource_name_prefix" {
  description = "a prefix to apply to resource names created by this module"
}

variable "tags" {
  description = "The tags to add to the resources"
  type        = map(string)
  default     = {}
}
