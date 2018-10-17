provider "azurerm" {}

resource "azurerm_storage_container" "images" {
    name = "images"
    container_access_type = "blob"
}

resource "azurerm_storage_container" "thumbnails" {
    name = "thumbnails"
    container_access_type = "blob"
}

resource "null_resource" "images_cors_rules" {
    provisioner "local-exec" {
        command = <<EOF
            az storage cors clear \
                --account-name ${azurerm_storage_account.default.name} \
                --services b
        EOF
    }
    provisioner "local-exec" {
        command = <<EOF
            az storage cors add \
                --account-name ${azurerm_storage_account.default.name} \
                --services b \
                --methods GET PUT \
                --origins "${azurerm_storage_account.default.primary_web_endpoint}" \
                --allowed-headers '*' \
                --exposed-headers '*'
        EOF
    }
}