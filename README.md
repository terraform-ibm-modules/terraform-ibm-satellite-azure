# IBM Cloud Satellite location on Azure

Use this terrafrom automation to set up satellite location on IBM cloud with azure host.
It will provision satellite location and create 6 azure host and assign 3 host to control plane, and provision ROKS satellite cluster and auto assign 3 host to cluster,
Configure cluster worker pool to an existing ROKS satellite cluster.

This is a collection of modules that make it easier to provision a satellite on IBM Cloud.
* satellite-location
* satellite-assign-host
* satellite-cluster
* satellite-cluster-worker-pool

## Overview

IBM Cloud® Satellite helps you deploy and run applications consistently across all on-premises, edge computing and public cloud environments from any cloud vendor. It standardizes a core set of Kubernetes, data, AI and security services to be centrally managed as a service by IBM Cloud, with full visibility across all environments through a single pane of glass. The result is greater developer productivity and development velocity.

https://cloud.ibm.com/docs/satellite?topic=satellite-getting-started

## Features

- Create satellite location.
- Create 6 azure host with RHEL 7-LVM.
- Assign the 3 hosts to the location control plane.
- *Conditional creation*:
  * Create a Red Hat OpenShift on IBM Cloud cluster and assign the 3 hosts to the cluster, so that you can run OpenShift workloads in your location.
  * Configure a worker pool to an existing OpenShift Cluster.

<table cellspacing="10" border="0">
  <tr>
    <td>
      <img src="images/providers/satellite.png" />
    </td>
  </tr>
</table>

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

module "satellite-azure" {
  source = "git::git@github.com:terraform-ibm-modules/terraform-ibm-satellite-azure.git"

  ################# IBM cloud & Azure cloud variables #######################
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
| ibm_resource_group                    | Resource Group Name that has to be targeted.                      | string   | n/a     | yes      |
| is_az_resource_group_exist            | "If false, resource group (az_resource_group) will be created. If true, existing resource group (az_resource_group) will be read"| bool   | false  | no   |
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
| az_source_address_prefix              | Azure security group source address prefix                        | list(string)   | [*] | no|
| az_security_custom_rules              | Azure security group custom rules                                 | list(object)   | n/a | no|
| azure_vnet_address_space              | Azure vNet address space                                          | list(string)   | ["10.0.0.0/16"] | no|
| azure_vnet_subnet_prefixes            | Azure vNet subnet prefixes                                        | list(string)   | ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"] | no|
| az_cp_vm_os_disk                      | Azure control plane vm os disk                                    | object   | n/a | no|
| az_cp_vm_source_image_reference       | Azure control plane vm source image reference                     | object   | n/a | no|
| az_cluster_vm_os_disk                 | Azure cluster vm os disk                                          | object   | n/a | no|
| az_cluster_vm_source_image_reference  | Azure cluser vm source image reference                            | object   | n/a | no|
| resource_prefix                       | Prefix to the Names of all VSI Resources                          | string   | satellite-azure | no|
| public_key                            | Public SSH key used to provision Host/VSI                         | string   | n/a     | no       |
| location_instance_type                | Profile information of location hosts                             | string   | Standard_D4s_v3| no     |
| cluster_instance_type                 | Profile information of cluster hosts                              | string   | Standard_D4s_v3| no     || create_cluster                        | Create cluster                                                    | bool     | true    | no       |
| cluster                               | Name of the ROKS Cluster that has to be created                   | string   | n/a     | yes      |
| cluster_zones                         | Allocate your hosts across these three zones                      | set      | n/a     | yes      |
| kube_version                          | Kuber version                                                     | string   | n/a | yes |
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

## Pre-commit Hooks

Run the following command to execute the pre-commit hooks defined in `.pre-commit-config.yaml` file

  `pre-commit run -a`

We can install pre-coomit tool using

  `pip install pre-commit`

## How to input varaible values through a file

To review the plan for the configuration defined (no resources actually provisioned)

`terraform plan -var-file=./input.tfvars`

To execute and start building the configuration defined in the plan (provisions resources)

`terraform apply -var-file=./input.tfvars`

To destroy the VPC and all related resources

`terraform destroy -var-file=./input.tfvars`

All optional parameters by default will be set to null in respective example's varaible.tf file. If user wants to configure any optional paramter he has overwrite the default value.