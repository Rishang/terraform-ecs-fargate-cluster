variable "cluster_name" {
  type        = string
  description = "The name of the ECS cluster"
}

variable "enable_container_insights" {
  type        = bool
  description = "`enabled` or `disable` container insights"
  default     = false
}

variable "services" {
  type        = map(any)
  default     = {}
  description = "A map of services to create"
}