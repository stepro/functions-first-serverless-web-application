// This script-behind would be registered with the compose service

import * as compose from "@cloud-compose/compose";
import * as azure from "@cloud-compose/azure";

if (compose.env.STAMP != "production") {
    azure.storage.account.for("*").enforce(() => ({
        performance: azure.storage.Performance.standard
    }));
}
