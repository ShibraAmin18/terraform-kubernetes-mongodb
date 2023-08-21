variable "resource_group_name" {
  description = "Azure Resource Group name"
  type        = string
  default     = ""
}

variable "resource_group_location" {
  description = "Azure region"
  type        = string
  default     = "East US"
}

variable "environment" {
  description = "Environment in which the infrastructure is being deployed (e.g., production, staging, development)"
  type        = string
  default     = "test"
}

variable "azure_uai_backup_name" {
  description = "Azure User Assigned Identity name for backup"
  type        = string
  default     = "mongo-backup"
}

variable "azure_uai_pod_identity_backup_name" {
  description = "Azure User Assigned Identity name for pod identity backup"
  type        = string
  default     = "pod-identity-backup"
}

variable "azure_uai_restore_name" {
  description = "Azure User Assigned Identity name for restore"
  type        = string
  default     = "mongo-restore"
}

variable "azure_uai_pod_identity_restore_name" {
  description = "Azure User Assigned Identity name for pod identity restore"
  type        = string
  default     = "pod-identity-restore"
}

variable "root_password" {
  description = "Root user password for MongoDB"
  type        = string
}

variable "metric_exporter_pasword" {
  description = "Password for the MongoDB exporter user"
  type        = string
}

variable "mongodb_config" {
  type = any
  default = {
    name               = ""
    environment        = ""
    volume_size        = ""
    architecture       = ""
    replica_count      = 2
    values_yaml        = ""
    storage_class_name = ""
  }
  description = "Specify the configuration settings for Mongodb, including the name, environment, storage options, replication settings, and custom YAML values."
}

variable "mongodb_custom_credentials_enabled" {
  type        = bool
  default     = false
  description = "Specifies whether to enable custom credentials for MongoDB database."
}

variable "mongodb_custom_credentials_config" {
  type = any
  default = {
    root_user                = ""
    root_password            = ""
    metric_exporter_user     = ""
    metric_exporter_password = ""
  }
  description = "Specify the configuration settings for Mongodb to pass custom credentials during creation."
}
