# resource "azurerm_cosmosdb_database" "imagesdb" {
#   name = "imagesdb"
# }

# resource "azurerm_cosmosdb_collection" "images" {
#   name = "images"
#   database_name = "${azurerm_cosmosdb_database.imagesdb.name}"
# }