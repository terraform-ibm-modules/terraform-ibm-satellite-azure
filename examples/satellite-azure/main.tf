#####################################################
# IBM Cloud Satellite -  Azure
# Copyright 2022 IBM
#####################################################

###################################################################
# Provision satellite location on IBM cloud with Azure host
###################################################################
module "satellite-azure" {
  source = "../.."

  ################# IBM cloud & Azure cloud authentication variables #######################
  ibm_resource_group         = var.ibm_resource_group
  az_resource_group          = var.az_resource_group
  is_az_resource_group_exist = var.is_az_resource_group_exist
  az_region                  = var.az_region
  az_resource_prefix         = var.az_resource_prefix

  ################# Azure Host variables #######################
  az_security_custom_rules   = var.az_security_custom_rules
  azure_vnet_address_space   = var.azure_vnet_address_space
  azure_vnet_subnet_prefixes = var.azure_vnet_subnet_prefixes

  ################# Satellite location resource variables #######################
  is_location_exist    = var.is_location_exist
  location             = var.location
  managed_from         = var.managed_from
  location_zones       = var.location_zones
  location_bucket      = var.location_bucket
  host_labels          = var.host_labels
  satellite_host_count = var.satellite_host_count
  addl_host_count      = var.addl_host_count

  ################# Satellite Cluster resource variables #######################
  create_cluster             = var.create_cluster
  cluster                    = var.cluster
  kube_version               = var.kube_version
  cluster_host_labels        = var.cluster_host_labels
  create_cluster_worker_pool = var.create_cluster_worker_pool
  worker_pool_name           = var.worker_pool_name
  worker_pool_host_labels    = var.worker_pool_host_labels
  create_timeout             = var.create_timeout
  update_timeout             = var.update_timeout
  delete_timeout             = var.delete_timeout
}