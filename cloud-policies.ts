// This script-behind would be registered with the compose service

import * as azure from "@cloud-compose/azure";

azure.storage.account.for("*").enforce(account => {
    if (process.env.STAMP != "production") {
        account.pricingTier = azure.storage.PricingTier.Standard;
    }
});
