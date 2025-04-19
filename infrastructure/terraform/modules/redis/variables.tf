variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region to deploy resources"
  type        = string
}

variable "zone" {
  description = "The primary zone for the Redis instance"
  type        = string
}

variable "alternative_zone" {
  description = "The alternative zone for the Redis instance (for HA)"
  type        = string
  default     = ""
}

variable "instance_name" {
  description = "The name of the Redis instance"
  type        = string
}

variable "tier" {
  description = "The service tier of the Redis instance (BASIC or STANDARD_HA)"
  type        = string
  default     = "STANDARD_HA"
}

variable "memory_size_gb" {
  description = "The memory size of the Redis instance in GB"
  type        = number
  default     = 5
}

variable "network_id" {
  description = "The VPC network ID to connect the Redis instance"
  type        = string
}

variable "redis_version" {
  description = "The Redis version to use"
  type        = string
  default     = "REDIS_6_X"
}

variable "redis_configs" {
  description = "The Redis configuration parameters"
  type        = map(string)
  default     = {
    maxmemory-policy = "allkeys-lru"
    notify-keyspace-events = "Kgx"
  }
}

variable "environment" {
  description = "The environment (dev, staging, prod)"
  type        = string
}
