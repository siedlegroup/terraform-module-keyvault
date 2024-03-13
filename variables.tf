variable "environment" {
  type        = string
  description = "Environment (stage) name for this Key Vault"
}

variable "subscription_id" {
  type        = string
  description = "Subscription ID for this account in the resource group"
}

variable "postfix" {
  type        = string
  description = "Suffix definition providing predictable resource names"
}

variable "resource_group_name" {
  type        = string
  description = "A logical container that holds related resources for an Azure solution"
}

variable "dns_zone_resource_group" {
  type        = string
  description = "Resource group name of DNS zone to create record in (usually in shared env)"
}

variable "location" {
  type        = string
  description = "The location/region to keep all your network resources. To get the list of all locations with table format from azure cli, run 'az account list-locations -o table'"
}

variable "dns_region" {
  type        = string
  description = "The region part of the DNS name, example: resources in locations germanywestcentral and germanynort will have a DNS name with .de."
}

variable "key_vault_name" {
  type        = string
  description = "The Name for this Key Vault"
}

variable "key_vault_sku_pricing_tier" {
  type        = string
  description = "The name of the SKU used for the Key Vault. The options are: `standard`, `premium`."
  default     = "standard"
}

variable "enabled_for_deployment" {
  type        = bool
  description = "Allow Virtual Machines to retrieve certificates stored as secrets from the key vault."
  default     = true
}

variable "enabled_for_disk_encryption" {
  type        = bool
  description = "Allow Disk Encryption to retrieve secrets from the vault and unwrap keys."
  default     = true
}

variable "enabled_for_template_deployment" {
  type        = bool
  description = "Allow Resource Manager to retrieve secrets from the key vault."
  default     = true
}

variable "enable_rbac_authorization" {
  type        = bool
  description = "Specify whether Azure Key Vault uses Role Based Access Control (RBAC) for authorization of data actions"
  default     = false
}

variable "enable_purge_protection" {
  type        = bool
  description = "Is Purge Protection enabled for this Key Vault? Careful: this will prevent deletion/replacement for the length of the retention period"
  default     = false
}

variable "soft_delete_retention_days" {
  type        = number
  description = "The number of days that items should be retained for once soft-deleted. The valid value can be between 7 and 90 days"
  default     = 7
}

variable "access_policies" {
  description = "List of access policies for the Key Vault."
  default     = []
}

variable "public_network_access_enabled" {
  type        = bool
  description = "Whether public network access is allowed for this Key Vault. Defaults to true"
}

variable "network_acls" {
  description = "Network rules to apply to key vault."
  type = object({
    bypass                     = string
    default_action             = string
    ip_rules                   = list(string)
    virtual_network_subnet_ids = list(string)
  })
  default = null
}

variable "secrets" {
  type        = map(string)
  description = "A map of secrets for the Key Vault."
  default     = {}
}

variable "random_password_length" {
  type        = number
  description = "The desired length of random password created by this module"
  default     = 32
}

variable "certificate_contacts" {
  description = "Contact information to send notifications triggered by certificate lifetime events"
  type = list(object({
    email = string
    name  = optional(string)
    phone = optional(string)
  }))
  default = []
}

variable "enable_private_endpoint" {
  type        = bool
  description = "Manages a Private Endpoint to Azure Container Registry"
  default     = false
}

variable "existing_subnet_id" {
  type        = string
  description = "The resource id of existing subnet to be reused here"
  default     = null
}

variable "private_dns_zone_name" {
  type        = string
  description = "Name of the existing private DNS zone"
  default     = null
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "Specifies the ID of a Log Analytics Workspace where diagnostics data will be sent to"
  default     = null
}

variable "storage_account_id" {
  type        = string
  description = "The name of the storage account to store the all monitoring logs"
  default     = null
}

variable "kv_diag_logs" {
  type        = list(string)
  description = "Keyvault Monitoring Category details for Azure Diagnostic setting"
  default = [
    "AuditEvent",
    "AzurePolicyEvaluationDetails"
  ]
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
