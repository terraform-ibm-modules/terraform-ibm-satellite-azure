#####################################################
# IBM Cloud Satellite -  Azure
# Copyright 2022 IBM
#####################################################

output "location_id" {
  value = module.satellite-location.location_id
}

output "host_script" {
  value = module.satellite-location.host_script
}

output "network_security_group_id" {
  value = module.azurerm-network-security-group.network_security_group_id
}

output "network_security_group_name" {
  value = module.azurerm-network-security-group.network_security_group_name
}

output "vnet_id" {
  value = module.azurerm-vnet.vnet_id
}

output "vnet_name" {
  value = module.azurerm-vnet.vnet_name
}

output "control_plane_private_ips" {
  value = concat(azurerm_linux_virtual_machine.az_host_control_plane.*.private_ip_addresses, [""])[0]
}

output "control_plane_public_ips" {
  value = concat(azurerm_linux_virtual_machine.az_host_control_plane.*.public_ip_addresses, [""])[0]
}

output "cluster_private_ips" {
  value = concat(azurerm_linux_virtual_machine.az_host_cluster.*.private_ip_addresses, [""])[0]
}

output "cluster_public_ips" {
  value = concat(azurerm_linux_virtual_machine.az_host_cluster.*.public_ip_addresses, [""])[0]
}

output "cluster_id" {
  value = var.create_cluster ? module.satellite-cluster.cluster_id : ""
}

output "cluster_crn" {
  value = var.create_cluster ? module.satellite-cluster.cluster_crn : ""
}

output "server_url" {
  value = var.create_cluster ? module.satellite-cluster.server_url : ""
}

output "cluster_state" {
  value = var.create_cluster ? module.satellite-cluster.cluster_state : ""
}

output "cluster_status" {
  value = var.create_cluster ? module.satellite-cluster.cluster_status : ""
}

output "ingress_hostname" {
  value = var.create_cluster ? module.satellite-cluster.ingress_hostname : ""
}

output "cluster_worker_pool_id" {
  value = var.create_cluster_worker_pool ? module.satellite-cluster-worker-pool.worker_pool_id : ""
}

output "worker_pool_worker_count" {
  value = var.create_cluster_worker_pool ? module.satellite-cluster-worker-pool.worker_pool_worker_count : ""
}

output "worker_pool_zones" {
  value = var.create_cluster_worker_pool ? module.satellite-cluster-worker-pool.worker_pool_zones : []
}