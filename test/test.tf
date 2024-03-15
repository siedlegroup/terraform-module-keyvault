terraform {
  required_version = "> 1.6.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.89.0, < 4.0.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.47.0"
    }
  }
}

provider "azurerm" {
  skip_provider_registration = true
  features {}
}

provider "azuread" {}

locals {
  environment                   = "dev1"
  subscription_id               = "aaaaaaaa-bbbb-cccc-dddd-111111111111"
  postfix                       = "sgc-project-dev-germanywestcentral"
  resource_group_name           = "rg-sgc-project-dev-germanywestcentral"
  dns_zone_resource_group       = "rg-sgc-project-shared-germanywestcentral"
  dns_region                    = "de"
  private_dns_zone_name         = "project.cloud.siedle.com"
  location                      = "germanywestcentral"
  key_vault_name                = "kv-sgc-project-name"
  public_network_access_enabled = false
}

module "keyvault" {
  source                        = "../."
  resource_group_name           = local.resource_group_name
  environment                   = "Platform"
  subscription_id               = local.subscription_id
  location                      = local.location
  key_vault_name                = substr("kv-${local.postfix}", 0, 24)
  public_network_access_enabled = true
  postfix                       = local.postfix
  dns_region                    = "de"
  dns_zone_resource_group       = "sgc-dns"
  private_dns_zone_name         = "cloud.siedle.com"
  key_vault_sku_pricing_tier    = "standard"
}
