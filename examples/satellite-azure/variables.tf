#####################################################
# IBM Cloud Satellite -  Azure
# Copyright 2022 IBM
#####################################################

# ##################################################
# # Azure and IBM Authentication Variables
# ##################################################

variable "TF_VERSION" {
  description = "terraform version"
  type        = string
  default     = "0.13"
}

variable "ibmcloud_api_key" {
  description = "IBM Cloud API Key"
  type        = string
}

variable "ibm_resource_group" {
  description = "Resource group name of the IBM Cloud account."
  type        = string
}

variable "az_subscription_id" {
  type        = string
  description = "Subscription id of Azure Account"
}

variable "az_client_id" {
  type        = string
  description = "Client id of Azure Account"
}

variable "az_tenant_id" {
  type        = string
  description = "Tenent id of Azure Account"
}

variable "az_client_secret" {
  type        = string
  description = "Client Secret of Azure Account"
}

variable "az_resource_group" {
  description = "Name of the resource Group"
  type        = string
  default     = "satellite-azure"
}

variable "is_az_resource_group_exist" {
  description = "If false, resource group (az_resource_group) will be created. If true, existing resource group (az_resource_group) will be read"
  type        = bool
  default     = true
}

variable "az_region" {
  description = "Azure Region"
  type        = string
  default     = "eastus"
}

# ##################################################
# # Azure Resources Variables
# ##################################################

variable "az_resource_prefix" {
  description = "Name to be used on all azure resources as prefix"
  type        = string
  default     = "satellite-azure"
}

variable "ssh_public_key" {
  description = "SSH Public Key. Get your ssh key by running `ssh-key-gen` command"
  type        = string
  default     = null
}

variable "location_instance_type" {
  description = "The type of azure instance to create"
  type        = string
  default     = "Standard_D4s_v3"
}

variable "cluster_instance_type" {
  description = "The type of azure instance to create"
  type        = string
  default     = "Standard_D4s_v3"
}

variable "satellite_host_count" {
  description = "The total number of Azure host to create for control plane. "
  type        = number
  default     = 3
  validation {
    condition     = (var.satellite_host_count % 3) == 0 && var.satellite_host_count > 0
    error_message = "Sorry, host_count value should always be in multiples of 3, such as 6, 9, or 12 hosts."
  }
}

variable "addl_host_count" {
  description = "The total number of additional azure vm's"
  type        = number
  default     = 0
}

variable "az_source_address_prefix" {
  description = "Azure security group source address prefix"
  type        = list(string)
  default     = ["*"]
}

variable "az_security_custom_rules" {
  description = "Azure security group custom rules"
  type = list(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
    description                = string
  }))
  default = [
    {
      name                       = "ssh"
      priority                   = 110
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
      description                = "description-myssh"
    },
    {
      name                       = "satellite"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "80,443,30000-32767"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
      description                = "description-http"
    },
  ]
}

variable "azure_vnet_address_space" {
  description = "Azure vNet address space"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "azure_vnet_subnet_prefixes" {
  description = "Azure vNet subnet prefixes"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

# ##################################################
# # IBMCLOUD Satellite Location Variables
# ##################################################

variable "location" {
  description = "Location Name"
  default     = "satellite-azure"

  validation {
    condition     = var.location != "" && length(var.location) <= 32
    error_message = "Sorry, please provide value for location_name variable or check the length of name it should be less than 32 chars."
  }
}
variable "is_location_exist" {
  description = "Determines if the location has to be created or not"
  type        = bool
  default     = false
}

variable "managed_from" {
  description = "The IBM Cloud region to manage your Satellite location from. Choose a region close to your on-prem data center for better performance."
  type        = string
  default     = "wdc"
}

variable "location_zones" {
  description = "Allocate your hosts across these three zones"
  type        = list(string)
  default     = ["eastus-1", "eastus-2", "eastus-3"]
}

variable "location_bucket" {
  description = "COS bucket name"
  default     = ""
}

variable "host_labels" {
  description = "Labels to add to attach host script"
  type        = list(string)
  default     = ["env:prod"]

  validation {
    condition     = can([for s in var.host_labels : regex("^[a-zA-Z0-9:]+$", s)])
    error_message = "Label must be of the form `key:value`."
  }
}

##################################################
# IBMCLOUD ROKS Cluster Variables
##################################################

variable "create_cluster" {
  description = "Create Cluster"
  type        = bool
  default     = false
}

variable "cluster" {
  description = "Cluster name"
  type        = string
  default     = "satellite-ibm-cluster"

  validation {
    error_message = "Cluster name must begin and end with a letter and contain only letters, numbers, and - characters."
    condition     = can(regex("^([a-z]|[a-z][-a-z0-9]*[a-z0-9])$", var.cluster))
  }
}

variable "kube_version" {
  description = "Satellite Kube Version"
  default     = "4.7_openshift"
}

variable "cluster_host_labels" {
  description = "Labels to add to attach host script"
  type        = list(string)
  default     = ["env:prod"]

  validation {
    condition     = can([for s in var.cluster_host_labels : regex("^[a-zA-Z0-9:]+$", s)])
    error_message = "Label must be of the form `key:value`."
  }
}

variable "worker_count" {
  description = "Worker Count for default pool"
  type        = number
  default     = 1
}

variable "wait_for_worker_update" {
  description = "Wait for worker update"
  type        = bool
  default     = true
}

variable "default_worker_pool_labels" {
  description = "Label to add default worker pool"
  type        = map(any)
  default     = null
}

variable "tags" {
  description = "List of tags associated with cluster."
  type        = list(string)
  default     = null
}

variable "create_timeout" {
  type        = string
  description = "Timeout duration for create."
  default     = null
}

variable "update_timeout" {
  type        = string
  description = "Timeout duration for update."
  default     = null
}

variable "delete_timeout" {
  type        = string
  description = "Timeout duration for delete."
  default     = null
}

##################################################
# IBMCLOUD ROKS Cluster Worker Pool Variables
##################################################
variable "create_cluster_worker_pool" {
  description = "Create Cluster worker pool"
  type        = bool
  default     = false
}

variable "worker_pool_name" {
  description = "Satellite Location Name"
  type        = string
  default     = "satellite-worker-pool"

  validation {
    error_message = "Cluster name must begin and end with a letter and contain only letters, numbers, and - characters."
    condition     = can(regex("^([a-z]|[a-z][-a-z0-9]*[a-z0-9])$", var.worker_pool_name))
  }

}

variable "worker_pool_host_labels" {
  description = "Labels to add to attach host script"
  type        = list(string)
  default     = ["env:prod"]

  validation {
    condition     = can([for s in var.worker_pool_host_labels : regex("^[a-zA-Z0-9:]+$", s)])
    error_message = "Label must be of the form `key:value`."
  }
}