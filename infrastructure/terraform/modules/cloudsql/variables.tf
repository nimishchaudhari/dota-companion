variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region to deploy resources"
  type        = string
}

variable "instance_name" {
  description = "The name of the CloudSQL instance"
  type        = string
}

variable "database_name" {
  description = "The name of the database to create"
  type        = string
}

variable "database_user" {
  description = "The name of the database user to create"
  type        = string
}

variable "database_password" {
  description = "The password for the database user"
  type        = string
  sensitive   = true
}

variable "tier" {
  description = "The machine type for the CloudSQL instance"
  type        = string
  default     = "db-custom-2-7680"
}

variable "availability_type" {
  description = "The availability type for the CloudSQL instance (REGIONAL for HA)"
  type        = string
  default     = "REGIONAL"
}

variable "disk_size" {
  description = "The disk size for the CloudSQL instance in GB"
  type        = number
  default     = 100
}

variable "disk_type" {
  description = "The disk type for the CloudSQL instance (PD_SSD or PD_HDD)"
  type        = string
  default     = "PD_SSD"
}

variable "network_id" {
  description = "The VPC network ID to connect the CloudSQL instance"
  type        = string
}

variable "deletion_protection" {
  description = "Whether to enable deletion protection on the CloudSQL instance"
  type        = bool
  default     = true
}

variable "enable_timescale" {
  description = "Whether to enable TimescaleDB extension"
  type        = bool
  default     = false
}
