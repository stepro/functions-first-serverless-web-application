import * as compose from "@cloud-compose/compose";
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

if (compose.env.STAMP == "production") {
    azure.storage.account.for("*").default(account => ({
        performance: azure.storage.Performance.premium
    }));
}
