# main.tf

# 1. Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "storage-secops-rg"
  location = "East US"
}

# 2. Azure Storage Account (Vulnerable by Design: Public Access is ON)
resource "azurerm_storage_account" "storage" {
  name                     = "secopslabstorage002" # ต้องไม่ซ้ำใครทั่วโลก!
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  
  # ช่องโหว่: อนุญาตการเข้าถึง Public Blob - Terrascan ต้องจับได้!
  allow_blob_public_access = true 
}