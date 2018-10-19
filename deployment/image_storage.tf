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
#     origins = ["${azurerm_storage_static_website.frontend.primary_endpoint}"]
#     services = "b"
#     methods = ["GET", "PUT"]
#     # allowed_headers = ["*"]
#     # exposed_headers = ["*"]
#   }
# }

