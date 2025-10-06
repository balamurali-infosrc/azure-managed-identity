terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0"
    }
  }
  required_version = ">= 1.3.0"
}

provider "azurerm" {
  features {}
  subscription_id = "02a44fee-b200-4cf9-b042-9bd4aa3bebe6"
tenant_id = "63b9a1c1-375c-42cf-9c63-dc3798c7ae5e"
}

# Get current subscription info (optional but handy)
data "azurerm_client_config" "current" {}

# 1) Create a resource group (example scope)
resource "azurerm_resource_group" "rg" {
  name     = "rg-demo-identity"
  location = "eastus"
}

# 2) Create a User Assigned Managed Identity
resource "azurerm_user_assigned_identity" "uai" {
  name                = "uai-demo"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
}

# 3) Lookup the built-in 'Contributor' role
data "azurerm_role_definition" "contributor" {
  name = "Contributor"
  # optional: scope = data.azurerm_subscription.primary.id
}

# 4) Assign that role to the managed identity at the resource group scope
resource "azurerm_role_assignment" "uai_contributor" {
  scope              = azurerm_resource_group.rg.id
  role_definition_id = data.azurerm_role_definition.contributor.id
  principal_id       = azurerm_user_assigned_identity.uai.principal_id

  # Create a stable GUID name for the role assignment
  name = guid(azurerm_resource_group.rg.id,
              azurerm_user_assigned_identity.uai.principal_id,
              data.azurerm_role_definition.contributor.id)
}
