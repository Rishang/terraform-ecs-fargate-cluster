variable "cluster_name" {
  type        = string
  description = "The name of the ECS cluster"
}

variable "enable_container_insights" {
  type        = bool
  description = "`enabled` or `disable` container insights"
  default     = false
}

variable "vpc_id" {
  type        = string
  description = "The VPC ID"
}

variable "subnets" {
  type        = list(string)
  description = "A list of subnet IDs"
}

variable "services" {
  type        = map(any)
  default     = {}
  description = "A map of services to create"
}

variable "environment" {
  type        = string
  description = "The environment name eg: dev, stage, prod"
}

variable "enable_discovery" {
  type        = bool
  default     = false
  description = "Enable service discovery"
}

variable "security_groups" {
  type        = list(string)
  default     = []
  description = "A map of security groups"
}

variable "cloudwatch_log_retention_days" {
  type        = number
  default     = 0
  description = "The number of days to retain log events"
}

variable "use_cloudwatch_logs" {
  type        = bool
  default     = false
  description = "Enable cloudwatch log."
}

variable "custom_log_configuration" {
  type        = map(any)
  default     = null
  description = "Custom log configuration. Keep `null` if `use_cloudwatch_logs` is `true`"
}