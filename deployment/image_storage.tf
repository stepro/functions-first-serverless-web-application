resource "azurerm_storage_container" "images" {
  name                  = "images"
  container_access_type = "blob"
}

resource "azurerm_storage_container" "thumbnails" {
  name                  = "thumbnails"
  container_access_type = "blob"
}

# resource "azurerm_storage_cors" "default" {
#   rule {
#     origins = ["${substr(azurerm_storage_static_website.frontend.primary_endpoint, 0, length(azurerm_storage_static_website.frontend.primary_endpoint)-1)}"]
#     services = "b"
#     methods = ["GET", "PUT"]
#     allowed_headers = ["*"]
#     exposed_headers = ["*"]
#   }
# }

output "image_storage" {
  value = "${substr(azurerm_storage_account.default.primary_blob_endpoint, 0, length(azurerm_storage_account.default.primary_blob_endpoint)-1)}"
}
