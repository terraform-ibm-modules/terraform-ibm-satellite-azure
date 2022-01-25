#####################################################
# IBM Cloud Satellite -  Azure
# Copyright 2022 IBM
#####################################################

output "location_id" {
  value = module.satellite-azure.location_id
}

output "host_script" {
  value = module.satellite-azure.host_script
}

output "network_security_group_id" {
  value = module.satellite-azure.network_security_group_id
}

output "network_security_group_name" {
  value = module.satellite-azure.network_security_group_name
}

output "vnet_id" {
  description = "The Id of the newly created vNet"
  value       = module.satellite-azure.vnet_id
}

output "vnet_name" {
  value = module.satellite-azure.vnet_name
}

output "control_plane_private_ips" {
  value = module.satellite-azure.control_plane_private_ips
}

output "control_plane_public_ips" {
  value = module.satellite-azure.control_plane_public_ips
}

output "cluster_private_ips" {
  value = module.satellite-azure.cluster_private_ips
}

output "cluster_public_ips" {
  value = module.satellite-azure.cluster_public_ips
}

output "cluster_id" {
  value = module.satellite-azure.cluster_id
}

output "cluster_crn" {
  value = module.satellite-azure.cluster_crn
}

output "server_url" {
  value = module.satellite-azure.server_url
}

output "cluster_state" {
  value = module.satellite-azure.cluster_state
}

output "cluster_status" {
  value = module.satellite-azure.cluster_status
}

output "ingress_hostname" {
  value = module.satellite-azure.ingress_hostname
}

output "cluster_worker_pool_id" {
  value = module.satellite-azure.cluster_worker_pool_id
}

output "worker_pool_worker_count" {
  value = module.satellite-azure.worker_pool_worker_count
}

output "worker_pool_zones" {
  value = module.satellite-azure.worker_pool_zones
}