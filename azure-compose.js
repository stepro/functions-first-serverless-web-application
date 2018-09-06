import * as azure from "azure-compose";

var services = {};

services.images = azure.storage.container({
    publicAccess: blob
});
services.thumbnails = azure.storage.container({
    publicAccess: blob
});

services.analyzer = azure.cognitiveServices.computerVision();

services.imageMetadata = azure.cosmosDB.collection({
    name: "images",
    database: {
        name: "imagedb"
    },
    throughput: 400
});

azure.functionApp.default({
    authentication: {
        activeDirectory: {
            appDisplayName: "First Serverless Web Application"
        },
        tokenStore: true,
        redirectTo: frontend
    }
});
services.GetImages = azure.function({
    requires: services.imageMetadata.allProperties(),
    source: "csharp/GetImages"
});
services.GetUploadUrl = azure.function({
    requires: services.images.allProperties(),
    source: "csharp/GetUploadUrl"
});
services.ResizeImage = azure.function({
    requires: [
        services.images.allProperties(),
        services.thumbnails.allProperties(),
        services.analyzer.allProperties(),
        services.imageMetadata.allProperties()
    ],
    source: "csharp/ResizeImage"
});

services.frontend = azure.staticWebsite({
    requires: [
        azure.functionApp.default,
        images.withMethods(["GET", "PUT"])
    ],
    content: "www/dist",
    settings: {
        authEnabled: true
    },
    index: index.html
});

exports.services = services;