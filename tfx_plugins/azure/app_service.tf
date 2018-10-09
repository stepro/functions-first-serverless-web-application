style "azurerm_app_service_plan" "" {
  resource_group_name = "${azurerm_resource_group.default.name}"
  location            = "${azurerm_resource_group.default.location}"

  sku {
    tier = "Free"
    size = "F1"
  }
}

style "azurerm_app_service_plan" ".linux" {
  kind = "Linux"

  sku {
    tier = "Basic"
    size = "B1"
  }
}

style "azurerm_app_service_plan" ".consumption" {
  sku {
    tier = "Dynamic"
    size = "Y1"
  }
}

@ambient
@class default
resource "azurerm_app_service_plan" "default" {
  name = "${azurerm_resource_group.default.name}"
}

@ambient
@class default linux
resource "azurerm_app_service_plan" "default_linux" {
  name = "${azurerm_resource_group.default.name}-linux"
}

@ambient
@class default consumption
resource "azurerm_app_service_plan" "default_consumption" {
  name = "${azurerm_resource_group.default.name}-consumption"
}

@ambient
@class default linux consumption
resource "azurerm_app_service_plan" "default_linux_consumption" {
  name = "${azurerm_resource_group.default.name}-linux-consumption"
}

style "azurerm_function_app" "" {
  resource_group_name       = "${azurerm_resource_group.default.name}"
  location                  = "${azurerm_resource_group.default.location}"
  app_service_plan_id       = "${azurerm_app_service_plan.default_consumption.id}"
  storage_connection_string = "${azurerm_storage_account.default.primary_connection_string}"
}

macro "azurerm_function_app_auth_aad" {
  return {
    authentication {
      active_directory {
        app_display_name = "${arg.app_display_name}"
      }
      token_store = true
      redirect_to = "${arg.redirect_to}"
    }
  }
}

reference "azurerm_function_app" "azurerm_cognitive_service" {
  source {
    app_settings {
      "${upper(target_name)}_ENDPOINT" = "${target.endpoint}"
      "${upper(target_name)}_KEY" = "${target.key1}"
    }
  }
}

reference "azurerm_function_app" "azurerm_cosmosdb_collection" {
  source {
    app_settings {
      "${upper(target_name)}_DATABASE_ACCOUNT_CONNECTION_STRING" = "${...}"
    }
  }
}

reference "azurerm_function_app" "azurerm_storage_container" {
  source {
    app_settings {
      "${upper(target_name)}_ACCOUNT_CONNECTION_STRING" = "${...}"
    }
  }
}