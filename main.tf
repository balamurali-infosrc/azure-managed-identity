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

variable "has_permissions" {
  type    = bool
  default = false   # Set to true if the Terraform principal can create role assignments
  description = "Whether the Terraform principal has permissions to create role assignments."
}


resource "azurerm_user_assigned_identity" "uai" {
  name                = "uai-demo"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

data "azurerm_role_definition" "contributor" {
  name = "Contributor"
}

resource "azurerm_role_assignment" "uai_contributor" {
  count              = var.has_permissions ? 1 : 0
  scope              = azurerm_resource_group.rg.id
  role_definition_id = data.azurerm_role_definition.contributor.id
  principal_id       = azurerm_user_assigned_identity.uai.principal_id

  name = uuidv5(
    "url",
    "${azurerm_resource_group.rg.id}-${azurerm_user_assigned_identity.uai.principal_id}-${data.azurerm_role_definition.contributor.id}"
  )
}
