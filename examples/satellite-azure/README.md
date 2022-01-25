# satellite-azure

This example cover end-to-end functionality of IBM cloud satellite by creating satellite location on specified region.
It will provision satellite location and create 6 azure host and assign 3 host to control plane, and provision ROKS satellite cluster and auto assign 3 host to cluster,
Configure cluster worker pool to an existing ROKS satellite cluster.

## Compatibility

This module is meant for use with Terraform 0.13 or later.

## Requirements

### Terraform plugins

- [Terraform](https://www.terraform.io/downloads.html) 0.13 or later.
- [terraform-provider-ibm](https://github.com/IBM-Cloud/terraform-provider-ibm)

## Install

### Terraform

Be sure you have the correct Terraform version ( 0.13 or later), you can choose the binary here:
- https://releases.hashicorp.com/terraform/

### Terraform provider plugins

Be sure you have the compiled plugins on $HOME/.terraform.d/plugins/

- [terraform-provider-ibm](https://github.com/IBM-Cloud/terraform-provider-ibm)

## Usage

```
terraform init
```
```
terraform plan
```
```
terraform apply
```
```
terraform destroy
```

## Example Usage
``` hcl

provider "azurerm" {
  features {}
  subscription_id = var.az_subscription_id
  client_id       = var.az_client_id
  tenant_id       = var.az_tenant_id
  client_secret   = var.az_client_secret  #pragma: allowlist secret
}

provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key #pragma: allowlist secret
}

module "satellite-azure" {
  source = "git::git@github.com:terraform-ibm-modules/terraform-ibm-satellite-azure.git"

  ################# IBM cloud & Azure cloud authentication variables #######################
  ibm_resource_group         = var.ibm_resource_group
  az_resource_group          = var.az_resource_group
  is_az_resource_group_exist = var.is_az_resource_group_exist
  az_region                  = var.az_region
  az_resource_prefix         = var.az_resource_prefix

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
  cluster_host_labels        = var.cluster_host_labels
  create_cluster_worker_pool = var.create_cluster_worker_pool
  worker_pool_name           = var.worker_pool_name
  worker_pool_host_labels    = var.worker_pool_host_labels
  create_timeout             = var.create_timeout
  update_timeout             = var.update_timeout
  delete_timeout             = var.delete_timeout
}

```

## Note

* `satellite-location` module creates new location or use existing location ID/name to process. If user pass the location which is already exist,   satellite-location module will error out and exit the module. In such cases user has to set `is_location_exist` value to true. So that module will use existing location for processing.
* `satellite-location` module download attach host script to the $HOME directory and appends respective permissions to the script.
* `satellite-location` module will update the attach host script and will be used in the `custom_data` attribute of `azurerm_linux_virtual_machine` resource.


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name                                  | Description                                                       | Type     | Default | Required |
|---------------------------------------|-------------------------------------------------------------------|----------|---------|----------|
| ibmcloud_api_key                      | IBM Cloud API key                                                 | string   | n/a     | yes      |
| ibm_resource_group                    | Resource Group Name that has to be targeted.                      | string   | n/a     | yes      |
| az_subscription_id                    | Subscription id of Azure Account                                  | string   | n/a     | yes      |
| az_client_id                          | Client id of Azure Account                                        | string   | n/a     | yes      |
| az_tenant_id                          | Tenent id of Azure Account                                        | string   | n/a     | yes      |
| az_client_secret                      | Client Secret of Azure Account                                    | string   | n/a     | yes      |
| is_az_resource_group_exist            | "If false, resource group (az_resource_group) will be created. If true, existing resource group (az_resource_group) will be read"| bool   | true  | no   |
| az_resource_group                     | Azure Resource Group                                              | string  | satellite-azure  | no   |
| az_region                             | Azure Region                                                      | string   | eastus  | yes   |
| location                              | Name of the Location that has to be created                       | string   | n/a     | satellite-azure  |
| is_location_exist                     | Determines if the location has to be created or not               | bool     | false   | no       |
| managed_from                          | The IBM Cloud region to manage your Satellite location from.      | string   | wdc     | no      |
| location_zones                        | Allocate your hosts across three zones for higher availablity     | list     | []     | no  |
| host_labels                           | Add labels to attach host script                                  | list     | [env:prod]  | no   |
| location_bucket                       | COS bucket name                                                   | string   | n/a     | no       |
| host_count                            | The total number of host to create for control plane. host_count value should always be in multiples of 3, such as 3, 6, 9, or 12 hosts | number | 3 |  yes |
| addl_host_count                       | The total number of additional host                               | number   | 3       | no       |
| host_provider                         | The cloud provider of host/vms.                                   | string   | azure     | no       |
| resource_prefix                       | Prefix to the Names of all VSI Resources                          | string   | satellite-azure | no|
| public_key                            | Public SSH key used to provision Host/VSI                         | string   | n/a     | no       |
| location_instance_type                | Profile information of location hosts                             | string   | Standard_D4s_v3| no     |
| cluster_instance_type                 | Profile information of cluster hosts                              | string   | Standard_D4s_v3| no     |
| create_cluster                        | Create cluster                                                    | bool     | true    | no       |
| cluster                               | Name of the ROKS Cluster that has to be created                   | string   | n/a     | yes      |
| cluster_zones                         | Allocate your hosts across these three zones                      | set      | n/a     | yes      |
| kube_version                          | Kuber version                                                     | string   | 4.7_openshift | no |
| default_wp_labels                     | Labels on the default worker pool                                 | map      | n/a     | no       |
| workerpool_labels                     | Labels on the worker pool                                         | map      | n/a     | no       |
| cluster_tags                          | List of tags for the cluster resource                             | list     | n/a     | no       |
| create_cluster_worker_pool            | Create Cluster worker pool                                        | bool     | false   | no       |
| worker_pool_name                      | Worker pool name                                                  | string   | satellite-worker-pool  | no |
| workerpool_labels                     | Labels on the worker pool                                         | map      | n/a     | no       |
| create_timeout                        | Timeout duration for creation                                     | string   | n/a     | no       |
| update_timeout                        | Timeout duration for updation                                     | string   | n/a     | no       |
| delete_timeout                        | Timeout duration for deletion                                     | string   | n/a     | no       |


## Outputs

| Name                        | Description                           |
|-----------------------------|---------------------------------------|
| location_id                 | Location id                           |
| host_script                 | Host registartion script content      |
| network_security_group_id   | Network security group Id             |
| network_security_group_name | Network security group name           |
| floating_ip_addresses       | Floating IP Addresses                 |
| vnet_id                     | The Id of the newly created vNet      |
| vnet_name                   | The Name of the newly created vNet    |
| control_plane_private_ips   | The Primary Private IP Address assigned to control plane VMs|
| control_plane_public_ips    | The Primary Public IP Address assigned to control plane VMs|
| cluster_private_ips         | The Primary Private IP Address assigned to cluster VMs|
| cluster_public_ips          | The Primary Public IP Address assigned to cluster VMs|
| cluster_worker_pool_id      | Cluster worker pool id                |
| worker_pool_worker_count    | worker count deatails                 |
| worker_pool_zones           | workerpool zones                      |