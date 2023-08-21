locals {
  name        = "mongo"
  region      = "eastus"
  environment = "prod"
  additional_tags = {
    Owner      = "organization_name"
    Expires    = "Never"
    Department = "Engineering"
  }
  store_password_to_secret_manager = false
  azure_storage_account_name       = "skaftest"
  azure_container_name             = "mongodb-backup-conatiner"
}

module "mongodb" {
  source                  = "squareops/mongodb/kubernetes"
  cluster_name            = "dev-cluster"
  resource_group_name     = "prod-skaf-rg"
  resource_group_location = "eastus"
  mongodb_config = {
    name                             = local.name
    values_yaml                      = file("./helm/values.yaml")
    environment                      = local.environment
    volume_size                      = "10Gi"
    architecture                     = "replicaset"
    replica_count                    = 1
    storage_class_name               = "infra-service-sc"
    store_password_to_secret_manager = local.store_password_to_secret_manager
  }
  mongodb_custom_credentials_enabled = true
  mongodb_custom_credentials_config = {
    root_user                = "root"
    root_password            = "NCPFUKEMd7rrWuvMAa73"
    metric_exporter_user     = "mongodb_exporter"
    metric_exporter_password = "nvAHhm1uGQNYWVw6ZyAH"
  }
  bucket_provider_type   = "azure"
  mongodb_backup_enabled = true
  mongodb_backup_config = {
    bucket_uri                 = "https://${local.azure_storage_account_name}.blob.core.windows.net/${local.azure_container_name}"
    azure_storage_account_name = local.azure_storage_account_name
    azure_container_name       = local.azure_container_name
    cron_for_full_backup       = "5 * * * *"
  }
  mongodb_restore_enabled = true
  mongodb_restore_config = {
    bucket_uri                 = "https://${local.azure_storage_account_name}.blob.core.windows.net/${local.azure_container_name}"
    azure_storage_account_name = local.azure_storage_account_name
    azure_container_name       = local.azure_container_name
    file_name                  = "mongodumpfull_20230710_132301.gz"
  }
  mongodb_exporter_enabled = true
}
