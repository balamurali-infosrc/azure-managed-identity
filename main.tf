provider "azurerm" {
  features {}
  subscription_id = "02a44fee-b200-4cf9-b042-9bd4aa3bebe6"
tenant_id = "63b9a1c1-375c-42cf-9c63-dc3798c7ae5e"
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "rg" {
  name     = "rg-managed-identity-demo"
  location = "eastus"
}

resource "azurerm_user_assigned_identity" "uai" {
  name                = "uai-demo"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

data "azurerm_role_definition" "contributor" {
  name = "Contributor"
}

resource "azurerm_role_assignment" "assign_contributor" {
  scope              = azurerm_resource_group.rg.id
  role_definition_id = data.azurerm_role_definition.contributor.id
  principal_id       = azurerm_user_assigned_identity.uai.principal_id

  # deterministic UUIDv5 so Terraform won't try to recreate the assignment every run
  name = uuidv5("url", "${azurerm_resource_group.rg.id}-${azurerm_user_assigned_identity.uai.principal_id}-${data.azurerm_role_definition.contributor.id}")
}
