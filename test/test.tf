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
  use_msi         = true
  subscription_id = "fae73dff-ca04-4eed-905f-5d064a6f25b5"
  tenant_id       = "2021092b-a5fe-4a9a-8b16-1876d8d5ccdf"
}

provider "azuread" {}

locals {
  environment                   = "dev1"
  subscription_id               = "fae73dff-ca04-4eed-905f-5d064a6f25b5"
  postfix                       = "sgc-project-test-germanywestcentral"
  resource_group_name           = "rg-sgc-project-test-germanywestcentral"
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
  access_policies               = []
}
