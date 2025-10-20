# main.tf

provider "azurerm" {
  features {} // นี่คือ Block "features" ที่ถูกบังคับใน v3.x
}
# 1. Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "storage-secops-rg"
  location = "East US"
}

# 2. Azure Storage Account (Vulnerable by Design: Public Access is ON)
resource "azurerm_storage_account" "storage" {
  name                     = "secopslabstage03102" # ต้องไม่ซ้ำใครทั่วโลก!
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  
  # ช่องโหว่: อนุญาตการเข้าถึง Public Blob - Terrascan ต้องจับได้!
 allow_nested_items_to_be_public = true
}