#####################################################
# IBM Cloud Satellite -  Azure
# Copyright 2022 IBM
#####################################################

###################################################################
# Create satellite location
###################################################################
module "satellite-location" {
  source  = "terraform-ibm-modules/satellite/ibm//modules/location"
  version = "1.1.9"

  is_location_exist = var.is_location_exist
  location          = var.location
  managed_from      = var.managed_from
  location_zones    = var.location_zones
  host_labels       = var.host_labels
  resource_group    = var.ibm_resource_group
  host_provider     = "azure"
}

###################################################################
# Create Azure Resource Group
###################################################################
resource "azurerm_resource_group" "resource_group" {
  count    = var.is_az_resource_group_exist == false ? 1 : 0
  name     = var.az_resource_group
  location = var.az_region
}

data "azurerm_resource_group" "resource_group" {
  name       = var.is_az_resource_group_exist == false ? azurerm_resource_group.resource_group.0.name : var.az_resource_group
  depends_on = [azurerm_resource_group.resource_group, module.satellite-location]
}

###################################################################
# Create security group and security group rules
###################################################################
module "azurerm-network-security-group" {
  source  = "Azure/network-security-group/azurerm"
  version = "3.6.0"

  resource_group_name   = data.azurerm_resource_group.resource_group.name
  location              = data.azurerm_resource_group.resource_group.location # Optional; if not provided, will use Resource Group location
  security_group_name   = "${var.az_resource_prefix}-sg"
  source_address_prefix = var.az_source_address_prefix
  custom_rules          = var.az_security_custom_rules
  tags = {
    ibm-satellite = var.az_resource_prefix
  }

  depends_on = [data.azurerm_resource_group.resource_group]
}

###################################################################
# Create vpc, subnets and attach security group to subnet
###################################################################
module "azurerm-vnet" {
  source  = "Azure/vnet/azurerm"
  version = "2.6.0"

  depends_on = [data.azurerm_resource_group.resource_group]

  resource_group_name = data.azurerm_resource_group.resource_group.name
  vnet_name           = "${var.az_resource_prefix}-vpc"
  address_space       = var.azure_vnet_address_space
  subnet_prefixes     = var.azure_vnet_subnet_prefixes
  subnet_names        = ["${var.az_resource_prefix}-subnet-1", "${var.az_resource_prefix}-subnet-2", "${var.az_resource_prefix}-subnet-3"]
  nsg_ids = {
    "${var.az_resource_prefix}-subnet-1" = module.azurerm-network-security-group.network_security_group_id
    "${var.az_resource_prefix}-subnet-2" = module.azurerm-network-security-group.network_security_group_id
    "${var.az_resource_prefix}-subnet-3" = module.azurerm-network-security-group.network_security_group_id
  }

  tags = {
    ibm-satellite = var.az_resource_prefix
  }
}

###################################################################
# Create network interface for the subnets that are been created
###################################################################
resource "azurerm_network_interface" "az_nic" {
  depends_on          = [data.azurerm_resource_group.resource_group]
  count               = var.satellite_host_count + var.addl_host_count
  name                = "${var.az_resource_prefix}-nic-${count.index}"
  resource_group_name = data.azurerm_resource_group.resource_group.name
  location            = data.azurerm_resource_group.resource_group.location

  ip_configuration {
    name                          = "${var.az_resource_prefix}-nic-internal"
    subnet_id                     = element(module.azurerm-vnet.vnet_subnets, count.index)
    private_ip_address_allocation = "Dynamic"
    primary                       = true
  }
  tags = {
    ibm-satellite = var.az_resource_prefix
  }
}

###################################################################
# provision SSH private key
###################################################################
resource "tls_private_key" "rsa_key" {
  count     = (var.ssh_public_key == null ? 1 : 0)
  algorithm = "RSA"
  rsa_bits  = 4096
}

###################################################################
# Creates Azure Linux Virtual Machines
###################################################################
resource "azurerm_linux_virtual_machine" "az_host_control_plane" {
  count                 = var.satellite_host_count
  name                  = "${var.az_resource_prefix}-cp-vm-${count.index}"
  resource_group_name   = data.azurerm_resource_group.resource_group.name
  location              = data.azurerm_resource_group.resource_group.location
  size                  = var.location_instance_type
  admin_username        = "adminuser"
  custom_data           = base64encode(module.satellite-location.host_script)
  network_interface_ids = [azurerm_network_interface.az_nic[count.index].id]

  zone = element(local.zones, count.index)
  admin_ssh_key {
    username   = "adminuser"
    public_key = var.ssh_public_key != null ? var.ssh_public_key : tls_private_key.rsa_key.0.public_key_openssh
  }

  dynamic "os_disk" {
    for_each = var.az_cp_vm_os_disk[*]
    content {
      caching              = os_disk.value.caching
      storage_account_type = os_disk.value.storage_account_type
      disk_size_gb         = os_disk.value.disk_size_gb
    }
  }

  dynamic "source_image_reference" {
    for_each = var.az_cp_vm_source_image_reference[*]
    content {
      publisher = source_image_reference.value.publisher
      offer     = source_image_reference.value.offer
      sku       = source_image_reference.value.sku
      version   = source_image_reference.value.version
    }
  }

  depends_on = [data.azurerm_resource_group.resource_group, module.satellite-location]
}

resource "azurerm_linux_virtual_machine" "az_host_cluster" {
  count                 = var.addl_host_count
  name                  = "${var.az_resource_prefix}-cluster-vm-${count.index}"
  resource_group_name   = data.azurerm_resource_group.resource_group.name
  location              = data.azurerm_resource_group.resource_group.location
  size                  = var.cluster_instance_type
  admin_username        = "adminuser"
  custom_data           = base64encode(module.satellite-location.host_script)
  network_interface_ids = [azurerm_network_interface.az_nic[count.index].id]

  zone = element(local.zones, count.index)
  admin_ssh_key {
    username   = "adminuser"
    public_key = var.ssh_public_key != null ? var.ssh_public_key : tls_private_key.rsa_key.0.public_key_openssh
  }

  dynamic "os_disk" {
    for_each = var.az_cluster_vm_os_disk[*]
    content {
      caching              = os_disk.value.caching
      storage_account_type = os_disk.value.storage_account_type
      disk_size_gb         = os_disk.value.disk_size_gb
    }
  }

  dynamic "source_image_reference" {
    for_each = var.az_cluster_vm_source_image_reference[*]
    content {
      publisher = source_image_reference.value.publisher
      offer     = source_image_reference.value.offer
      sku       = source_image_reference.value.sku
      version   = source_image_reference.value.version
    }
  }

  depends_on = [data.azurerm_resource_group.resource_group, module.satellite-location]
}

resource "azurerm_managed_disk" "control_plane_data_disk" {
  count                = var.satellite_host_count
  name                 = "${var.az_resource_prefix}-cp-disk-${count.index}"
  location             = data.azurerm_resource_group.resource_group.location
  resource_group_name  = data.azurerm_resource_group.resource_group.name
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = 128
  zones                = [element(local.zones, count.index)]
}

resource "azurerm_managed_disk" "cluster_data_disk" {
  count                = var.addl_host_count
  name                 = "${var.az_resource_prefix}-cluster-disk-${count.index}"
  location             = data.azurerm_resource_group.resource_group.location
  resource_group_name  = data.azurerm_resource_group.resource_group.name
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = 128
  zones                = [element(local.zones, count.index)]
}

resource "azurerm_virtual_machine_data_disk_attachment" "control_plane_disk_attach" {
  count              = var.satellite_host_count
  managed_disk_id    = azurerm_managed_disk.control_plane_data_disk[count.index].id
  virtual_machine_id = azurerm_linux_virtual_machine.az_host_control_plane[count.index].id
  lun                = "10"
  caching            = "ReadWrite"
}

resource "azurerm_virtual_machine_data_disk_attachment" "cluster_disk_attach" {
  count              = var.addl_host_count
  managed_disk_id    = azurerm_managed_disk.cluster_data_disk[count.index].id
  virtual_machine_id = azurerm_linux_virtual_machine.az_host_cluster[count.index].id
  lun                = "10"
  caching            = "ReadWrite"
}

###################################################################
# Assign host to satellite location control plane
###################################################################
module "satellite-host" {
  source  = "terraform-ibm-modules/satellite/ibm//modules/host"
  version = "1.1.9"

  host_count     = var.satellite_host_count
  location       = module.satellite-location.location_id
  host_vms       = azurerm_linux_virtual_machine.az_host_control_plane.*.name
  location_zones = var.location_zones
  host_labels    = var.host_labels
  host_provider  = "azure"

  depends_on = [azurerm_virtual_machine_data_disk_attachment.control_plane_disk_attach]
}

###################################################################
# Create satellite ROKS cluster
###################################################################
module "satellite-cluster" {
  source  = "terraform-ibm-modules/satellite/ibm//modules/cluster"
  version = "1.1.9"

  create_cluster             = var.create_cluster
  cluster                    = var.cluster
  zones                      = var.location_zones
  location                   = module.satellite-location.location_id
  resource_group             = var.ibm_resource_group
  kube_version               = var.kube_version
  worker_count               = var.worker_count
  host_labels                = var.cluster_host_labels
  tags                       = var.tags
  default_worker_pool_labels = var.default_worker_pool_labels
  create_timeout             = var.create_timeout
  update_timeout             = var.update_timeout
  delete_timeout             = var.delete_timeout

  depends_on = [module.satellite-host]
}

###################################################################
# Create worker pool on existing ROKS cluster
###################################################################
module "satellite-cluster-worker-pool" {
  source  = "terraform-ibm-modules/satellite/ibm//modules/configure-cluster-worker-pool"
  version = "1.1.9"

  create_cluster_worker_pool = var.create_cluster_worker_pool
  worker_pool_name           = var.worker_pool_name
  cluster                    = var.cluster
  zones                      = var.location_zones
  resource_group             = var.ibm_resource_group
  kube_version               = var.kube_version
  worker_count               = var.worker_count
  host_labels                = var.worker_pool_host_labels
  create_timeout             = var.create_timeout
  delete_timeout             = var.delete_timeout

  depends_on = [module.satellite-cluster]
}