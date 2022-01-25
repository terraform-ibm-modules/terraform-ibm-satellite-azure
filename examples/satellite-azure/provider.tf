#####################################################
# IBM Cloud Satellite -  Azure Example
# Copyright 2022 IBM
#####################################################

provider "azurerm" {
  features {}
  subscription_id = var.az_subscription_id
  client_id       = var.az_client_id
  tenant_id       = var.az_tenant_id
  client_secret   = var.az_client_secret
}

provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
}