style "azurerm_cosmosdb_account" "" {
  resource_group_name = "${azurerm_resource_group.default.name}"
  location            = "${azurerm_resource_group.default.location}"
  offer_type          = "Standard"

  consistency_policy {
    consistency_level = "BoundedStaleness"
  }

  geo_location {
    location          = "${self.location}"
    failover_priority = 0
  }
}

function "azurerm_cosmosdb_account_name" {
  lowered    = "${lower(args[0])}"
  replaced   = "${replace(self.lowered, "/[^a-z0-9-]/", "")}"
  max_length = "${30 - length(random_string.instance.result)}"
  truncated  = "${substr(self.replaced, 0, self.max_length)}"
  return     = "${self.truncated}-{random_string.instance.result}"
}

@ambient
@class default
resource "azurerm_cosmosdb_account" "default" {
  name = "${azurerm_cosmosdb_account_name(azurerm_resource_group.default.name)}"
}

@ambient
@class default
resource "azurerm_cosmosdb_database" "default" {
  name                  = "defaultdb"
  cosmosdb_account_name = "${azurerm_cosmosdb_account.default.name}"
}

style "azurerm_cosmosdb_collection" "" {
  cosmosdb_account_name  = "${azurerm_cosmosdb_account.default.name}"
  cosmosdb_database_name = "${azurerm_cosmosdb_database.default.name}"
  throughput             = 400
}
