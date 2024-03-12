resource "azurerm_private_dns_a_record" "this" {
  count               = var.enable_private_endpoint ? 1 : 0
  name                = "keyvault.${var.dns_region}.${var.environment}"
  zone_name           = var.private_dns_zone_name
  resource_group_name = var.dns_zone_resource_group
  ttl                 = 300
  records             = [data.azurerm_private_endpoint_connection.private-ip1.0.private_service_connection.0.private_ip_address]
}
