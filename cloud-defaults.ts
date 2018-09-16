import * as azure from "@cloud-compose/azure";

azure.httpFunction.for(".requiresAuth").default(f => {
    (f.app || (f.app = {})).authentication = {
        activeDirectory: {
            appDisplayName: "First Serverless Web Application"
        },
        tokenStore: true,
        redirectTo: azure.storage.website("frontend")
    };
});

azure.storage.account.for("*").default(account => {
    if (process.env.STAMP == "production") {
        account.pricingTier = azure.storage.PricingTier.Premium;
    }
});
