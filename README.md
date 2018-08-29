# Build your first serverless web app

Code for first serverless web application tutorial

## How to Build
- `./build`

## Azure Compose
- `az extension add -n storage-preview`
- `source .az-compose/install`
- `az-compose up -g myResourceGroup -l myLocation`
- `az-compose down -g myResourceGroup --delete-group`

## Azure Compose Walkthrough
### Create a web app in Azure Blob storage
```
$ az compose static-website add -n frontend -c www/dist -i index.html
Added static website 'frontend'
$ az compose endpoint add -n frontend -v frontend:primaryEndpoint
Added endpoint 'frontend' as value of 'frontend:primaryEndpoint'
```
```
$ cat azure-compose.yaml
services:
  frontend:
    staticWebsite:
      content: www/dist
      index: index.html
endpoints:
  frontend: $(frontend:primaryEndpoint)
```
```
$ az compose up -g gallery-app -l westus
Creating resource group 'gallery-app' in location 'westus'...
Creating default storage account 'defaultbb87108a1cf2656a'...
Created default storage account 'defaultbb87108a1cf2656a' in 22s
Creating 'frontend' as static website in storage account 'defaultbb87108a1cf2656a'...
Created 'frontend' as static website in storage account 'defaultbb87108a1cf2656a' in 6s
Pushing 'frontend' content to static website in storage account 'defaultbb87108a1cf2656a'...
Pushed 'frontend' content to static website in storage account 'defaultbb87108a1cf2656a' in 6s

endpoints:
  frontend: https://defaultbb87108a1cf2656a.z20.web.core.windows.net

Compose completed in 32s
```

### Upload images to Blob storage with Azure Functions
```
$ az compose storage-container add -n images --public-access blob
Added storage container 'images'
$ az compose function add -n GetUploadUrl -s csharp/GetUploadUrl
Added function 'GetUploadUrl'
$ az compose ref add --from GetUploadUrl --to images -s
Added reference from 'GetUploadUrl' to 'images' with sensitive properties
$ az compose ref add --from frontend --to GetUploadUrl --to images
Added reference from 'frontend' to 'GetUploadUrl'
Added reference from 'frontend' to 'images'
```
```
$ cat azure-compose.yaml
services:
  frontend:
    requires: [GetUploadUrl, images]
    staticWebsite:
      content: www/dist
      index: index.html
  GetUploadUrl:
    requires: images!
    function:
      source: csharp/GetUploadUrl
  images:
    storageContainer:
      publicAccess: blob
endpoints:
  frontend: $(frontend:primaryEndpoint)
```
```
$ az compose up -g photos-app
Using existing resource group 'photos-app' and location 'westus'
Creating default storage account 'defaultbb87108a1cf2656a'...
Created default storage account 'defaultbb87108a1cf2656a' in 5s
Creating default function app 'default-dc3b02b9f8b0f3b1'...
Creating 'frontend' as static website in storage account 'defaultbb87108a1cf2656a'...
Creating 'images' as container 'images' in storage account 'defaultbb87108a1cf2656a'...
Created 'images' as container 'images' in storage account 'defaultbb87108a1cf2656a' in 3s
Created 'frontend' as static website in storage account 'defaultbb87108a1cf2656a' in 5s
Created default function app 'default-dc3b02b9f8b0f3b1' in 24s
Creating 'GetUploadUrl' as function 'GetUploadUrl' in function app 'default-dc3b02b9f8b0f3b1'...
Created 'GetUploadUrl' as function 'GetUploadUrl' in function app 'default-dc3b02b9f8b0f3b1' in <1s
Configuring default function app...
Configuring default storage account...
Configured default storage account in 4s
Configured default function app in 7s
Binding 'GetUploadUrl' function to 'images' storage container...
Binding 'frontend' static website to default function app...
Binding 'frontend' static website to 'images' storage container...
Bound 'frontend' static website to default function app in <1s
Bound 'frontend' static website to 'images' storage container in <1s
Bound 'GetUploadUrl' function to 'images' storage container in 3s
Pushing 'GetUploadUrl' source to function app 'default-dc3b02b9f8b0f3b1'...
Pushing 'frontend' content to static website in storage account 'defaultbb87108a1cf2656a'...
Pushed 'frontend' content to static website in storage account 'defaultbb87108a1cf2656a' in 6s
Pushed 'GetUploadurl' source to function app 'default-dc3b02b9f8b0f3b1' in 32s

endpoints:
  frontend: https://defaultbb87108a1cf2656a.z20.web.core.windows.net

Compose completed in 1m 17s
```

### Resize images with Azure Functions
```
$ az compose storage-container add -n thumbnails --public-access blob
Added storage container 'thumbnails'
$ az compose function add -n ResizeImage -s csharp/ResizeImage -r images! -r thumbnails!
Added function 'ResizeImage'
Added reference from 'ResizeImage' to 'images' with sensitive properties
Added reference from 'ResizeImage' to 'thumbnails' with sensitive properties
```
```
$ cat azure-compose.yaml
services:
  frontend:
    requires: images
    staticWebsite:
      content: www/dist
      index: index.html
  GetUploadUrl:
    requires: images!
    function:
      source: csharp/GetUploadUrl
  images:
    storageContainer:
      publicAccess: blob
  ResizeImage:
    requires: [images!, thumbnails!]
    function:
      source: csharp/ResizeImage
  thumbnails:
    storageContainer:
      publicAccess: blob
endpoints:
  frontend: $(frontend:primaryEndpoint)
```
```
$ az compose up -g photos-app
Using existing resource group 'photos-app' and location 'westus'
Creating default storage account 'defaultbb87108a1cf2656a'...
Created default storage account 'defaultbb87108a1cf2656a' in 5s
Creating default function app 'default-dc3b02b9f8b0f3b1'...
Creating 'frontend' as static website in storage account 'defaultbb87108a1cf2656a'...
Creating 'images' as container 'images' in storage account 'defaultbb87108a1cf2656a'...
Creating 'thumbnails' as container 'thumbnails' in storage account 'defaultbb87108a1cf2656a'...
Created 'thumbnails' as container 'thumbnails' in storage account 'defaultbb87108a1cf2656a' in 3s
Created 'images' as container 'images' in storage account 'defaultbb87108a1cf2656a' in 3s
Created 'frontend' as static website in storage account 'defaultbb87108a1cf2656a' in 5s
Created default function app 'default-dc3b02b9f8b0f3b1' in 5s
Creating 'GetUploadUrl' as function 'GetUploadUrl' in function app 'default-dc3b02b9f8b0f3b1'...
Created 'GetUploadUrl' as function 'GetUploadUrl' in function app 'default-dc3b02b9f8b0f3b1' in <1s
Creating 'ResizeImage' as function 'ResizeImage' in function app 'default-dc3b02b9f8b0f3b1'...
Created 'ResizeImage' as function 'ResizeImage' in function app 'default-dc3b02b9f8b0f3b1' in <1s
Configuring default function app...
Configuring default storage account...
Configured default storage account in 5s
Configured default function app in 6s
Binding 'GetUploadUrl' function to 'images' storage container...
Binding 'ResizeImage' function to 'images' storage container...
Binding 'ResizeImage' function to 'thumbnails' storage container...
Binding 'frontend' static website to default function app...
Binding 'frontend' static website to 'images' storage container...
Bound 'frontend' static website to default function app in <1s
Bound 'frontend' static website to 'images' storage container in <1s
Bound 'GetUploadUrl' function to 'images' storage container in 3s
Bound 'ResizeImage' function to 'images' storage container in 3s
Bound 'ResizeImage' function to 'thumbnails' storage container in 3s
Pushing 'GetUploadUrl' source to function app 'default-dc3b02b9f8b0f3b1'...
Pushing 'ResizeImage' source to function app 'default-dc3b02b9f8b0f3b1'...
Pushing 'frontend' content to static website in storage account 'defaultbb87108a1cf2656a'...
Pushed 'frontend' content to static website in storage account 'defaultbb87108a1cf2656a' in 6s
Pushed 'GetUploadUrl' source to function app 'default-dc3b02b9f8b0f3b1' in 28s
Pushed 'ResizeImage' source to function app 'default-dc3b02b9f8b0f3b1' in 28s

endpoints:
  frontend: https://defaultbb87108a1cf2656a.z20.web.core.windows.net

Compose completed in 1m 19s
```

### Store image metadata with Azure Cosmos DB
```
$ az compose cosmosdb-collection add -n imageMetadata --collection-name images --database-name imagesdb --throughput 400
Added cosmos db collection 'imageMetadata'
$ az compose ref add --from ResizeImage --to imageMetadata -s
Added reference from 'ResizeImage' to 'imageMetadata' with sensitive properties
$ az compose function add -n GetImages -s csharp/GetImages -r imageMetadata!
Added function 'GetImages'
Added reference from 'GetImages' to 'imageMetadata' with sensitive properties
```
```
$ cat azure-compose.yaml
services:
  frontend:
    requires: images
    staticWebsite:
      content: www/dist
      index: index.html
  GetUploadUrl:
    requires: images!
    function:
      source: csharp/GetUploadUrl
  imageMetadata:
    cosmosdbCollection:
      name: images
      database:
      - name: imagesdb
      throughput: 400
  images:
    storageContainer:
      publicAccess: blob
  ResizeImage:
    requires: [imageMetadata!, images!, thumbnails!]
    function:
      source: csharp/ResizeImage
  thumbnails:
    storageContainer:
      publicAccess: blob
endpoints:
  frontend: $(frontend:primaryEndpoint)
```
```
$ az compose up -g photos-app
Using existing resource group 'photos-app' and location 'westus'
Creating default cosmos db account 'default-79ac7f4131b25692'...
Creating default storage account 'defaultbb87108a1cf2656a'...
Created default storage account 'defaultbb87108a1cf2656a' in 5s
Creating default function app 'default-dc3b02b9f8b0f3b1'...
Creating 'frontend' as static website in storage account 'defaultbb87108a1cf2656a'...
Creating 'images' as container 'images' in storage account 'defaultbb87108a1cf2656a'...
Creating 'thumbnails' as container 'thumbnails' in storage account 'defaultbb87108a1cf2656a'...
Created 'thumbnails' as container 'thumbnails' in storage account 'defaultbb87108a1cf2656a' in 3s
Created 'images' as container 'images' in storage account 'defaultbb87108a1cf2656a' in 3s
Created 'frontend' as static website in storage account 'defaultbb87108a1cf2656a' in 5s
Created default function app 'default-dc3b02b9f8b0f3b1' in 5s
Creating 'GetImages' as function 'GetImages' in function app 'default-dc3b02b9f8b0f3b1'...
Created 'GetImages' as function 'GetImages' in function app 'default-dc3b02b9f8b0f3b1' in <1s
Creating 'GetUploadUrl' as function 'GetUploadUrl' in function app 'default-dc3b02b9f8b0f3b1'...
Created 'GetUploadUrl' as function 'GetUploadUrl' in function app 'default-dc3b02b9f8b0f3b1' in <1s
Creating 'ResizeImage' as function 'ResizeImage' in function app 'default-dc3b02b9f8b0f3b1'...
Created 'ResizeImage' as function 'ResizeImage' in function app 'default-dc3b02b9f8b0f3b1' in <1s
Created default cosmos db account 'default-79ac7f4131b25692' in 3m 9s
Creating 'imageMetadata' as collection 'images' in cosmos db database 'imagesdb' account 'default-79ac7f4131b25692'...
Created 'imageMetadata' as collection 'images' in cosmos db database 'imagesdb' account 'default-79ac7f4131b25692' in 10s
Configuring default function app...
Configuring default storage account...
Configured default storage account in 5s
Configured default function app in 6s
Binding 'GetImages' function to 'imageMetadata' cosmos db collection...
Binding 'GetUploadUrl' function to 'images' storage container...
Binding 'ResizeImage' function to 'imageMetadata' cosmos db collection...
Binding 'ResizeImage' function to 'images' storage container...
Binding 'ResizeImage' function to 'thumbnails' storage container...
Binding 'frontend' static website to default function app...
Binding 'frontend' static website to 'images' storage container...
Bound 'frontend' static website to default function app in <1s
Bound 'frontend' static website to 'images' storage container in <1s
Bound 'GetImages' function to 'imageMetadata' cosmos db collection in 3s
Bound 'GetUploadUrl' function to 'images' storage container in 3s
Bound 'ResizeImage' function to 'imageMetadata' cosmos db collection in 3s
Bound 'ResizeImage' function to 'images' storage container in 3s
Bound 'ResizeImage' function to 'thumbnails' storage container in 3s
Pushing 'GetImages' source to function app 'default-dc3b02b9f8b0f3b1'...
Pushing 'GetUploadUrl' source to function app 'default-dc3b02b9f8b0f3b1'...
Pushing 'ResizeImage' source to function app 'default-dc3b02b9f8b0f3b1'...
Pushing 'frontend' content to static website in storage account 'defaultbb87108a1cf2656a'...
Pushed 'frontend' content to static website in storage account 'defaultbb87108a1cf2656a' in 6s
Pushed 'GetImages' source to function app 'default-dc3b02b9f8b0f3b1' in 32s
Pushed 'GetUploadUrl' source to function app 'default-dc3b02b9f8b0f3b1' in 32s
Pushed 'ResizeImage' source to function app 'default-dc3b02b9f8b0f3b1' in 32s

endpoints:
  frontend: https://defaultbb87108a1cf2656a.z20.web.core.windows.net

Compose completed in 4m 2s
```

### Add image captions with Computer Vision
```
$ az compose cognitiveservices-account add -n analyzer --kind ComputerVision --sku F0
Added cognitive services account 'analyzer'
$ az compose ref add --from ResizeImage --to analyzer -s
Added reference from 'ResizeImage' to 'analyzer' with sensitive properties
```
```
$ cat azure-compose.yaml
services:
  analyzer:
    cognitiveservicesAccount:
      kind: ComputerVision
      sku: F0
  frontend:
    requires: images
    staticWebsite:
      content: www/dist
      index: index.html
  GetUploadUrl:
    requires: images!
    function:
      source: csharp/GetUploadUrl
  imageMetadata:
    cosmosdbCollection:
      name: images
      database:
      - name: imagesdb
      throughput: 400
  images:
    storageContainer:
      publicAccess: blob
  ResizeImage:
    requires: [analyzer!, imageMetadata!, images!, thumbnails!]
    function:
      source: csharp/ResizeImage
  thumbnails:
    storageContainer:
      publicAccess: blob
endpoints:
  frontend: $(frontend:primaryEndpoint)
```
```
$ az compose up -g photos-app
Using existing resource group 'photos-app' and location 'westus'
Creating 'analyzer' as cognitive services account 'analyzer-e4a759dc8a6001e2'...
Creating default cosmos db account 'default-79ac7f4131b25692'...
Creating default storage account 'defaultbb87108a1cf2656a'...
Created default cosmos db account 'default-79ac7f4131b25692' in 3s
Created 'analyzer' as cognitive services account 'analyzer-e4a759dc8a6001e2' in 5s
Created default storage account 'defaultbb87108a1cf2656a' in 5s
Creating default function app 'default-dc3b02b9f8b0f3b1'...
Creating 'frontend' as static website in storage account 'defaultbb87108a1cf2656a'...
Creating 'images' as container 'images' in storage account 'defaultbb87108a1cf2656a'...
Creating 'thumbnails' as container 'thumbnails' in storage account 'defaultbb87108a1cf2656a'...
Created 'thumbnails' as container 'thumbnails' in storage account 'defaultbb87108a1cf2656a' in 3s
Created 'images' as container 'images' in storage account 'defaultbb87108a1cf2656a' in 3s
Created 'frontend' as static website in storage account 'defaultbb87108a1cf2656a' in 5s
Created default function app 'default-dc3b02b9f8b0f3b1' in 5s
Creating 'GetImages' as function 'GetImages' in function app 'default-dc3b02b9f8b0f3b1'...
Created 'GetImages' as function 'GetImages' in function app 'default-dc3b02b9f8b0f3b1' in <1s
Creating 'GetUploadUrl' as function 'GetUploadUrl' in function app 'default-dc3b02b9f8b0f3b1'...
Created 'GetUploadUrl' as function 'GetUploadUrl' in function app 'default-dc3b02b9f8b0f3b1' in <1s
Creating 'ResizeImage' as function 'ResizeImage' in function app 'default-dc3b02b9f8b0f3b1'...
Created 'ResizeImage' as function 'ResizeImage' in function app 'default-dc3b02b9f8b0f3b1' in <1s
Creating 'imageMetadata' as collection 'images' in cosmos db database 'imagesdb' account 'default-79ac7f4131b25692'...
Created 'imageMetadata' as collection 'images' in cosmos db database 'imagesdb' account 'default-79ac7f4131b25692' in 5s
Configuring default function app...
Configuring default storage account...
Configured default storage account in 5s
Configured default function app in 6s
Binding 'GetImages' function to 'imageMetadata' cosmos db collection...
Binding 'GetUploadUrl' function to 'images' storage container...
Binding 'ResizeImage' function to 'analyzer' cognitive services account...
Binding 'ResizeImage' function to 'imageMetadata' cosmos db collection...
Binding 'ResizeImage' function to 'images' storage container...
Binding 'ResizeImage' function to 'thumbnails' storage container...
Binding 'frontend' static website to default function app...
Binding 'frontend' static website to 'images' storage container...
Bound 'frontend' static website to default function app in <1s
Bound 'frontend' static website to 'images' storage container in <1s
Bound 'GetImages' function to 'imageMetadata' cosmos db collection in 3s
Bound 'GetUploadUrl' function to 'images' storage container in 3s
Bound 'ResizeImage' function to 'analyzer' cognitive services account in 3s
Bound 'ResizeImage' function to 'imageMetadata' cosmos db collection in 3s
Bound 'ResizeImage' function to 'images' storage container in 3s
Bound 'ResizeImage' function to 'thumbnails' storage container in 3s
Pushing 'GetImages' source to function app 'default-dc3b02b9f8b0f3b1'...
Pushing 'GetUploadUrl' source to function app 'default-dc3b02b9f8b0f3b1'...
Pushing 'ResizeImage' source to function app 'default-dc3b02b9f8b0f3b1'...
Pushing 'frontend' content to static website in storage account 'defaultbb87108a1cf2656a'...
Pushed 'frontend' content to static website in storage account 'defaultbb87108a1cf2656a' in 6s
Pushed 'GetImages' source to function app 'default-dc3b02b9f8b0f3b1' in 32s
Pushed 'GetUploadUrl' source to function app 'default-dc3b02b9f8b0f3b1' in 32s
Pushed 'ResizeImage' source to function app 'default-dc3b02b9f8b0f3b1' in 32s

endpoints:
  frontend: https://defaultbb87108a1cf2656a.z20.web.core.windows.net

Compose completed in 1m 9s
```

### Add authentication
```
$ code azure-compose.yaml # edit manually
$ cat azure-compose.yaml
services:
  analyzer:
    cognitiveservicesAccount:
      kind: ComputerVision
      sku: F0
  +functionapp:
    authentication:
      enabled: true
      action: azureActiveDirectoryLogin
      appDisplayName: First Serverless Web Application
      tokenStore: true
      redirectUris:
      - $(frontend:primaryEndpoint)
  frontend:
    requires: images
    staticWebsite:
      content: www/dist
      settings:
        authEnabled: true
      index: index.html
  GetUploadUrl:
    requires: images!
    function:
      source: csharp/GetUploadUrl
  imageMetadata:
    cosmosdbCollection:
      name: images
      database:
      - name: imagesdb
      throughput: 400
  images:
    storageContainer:
      publicAccess: blob
  ResizeImage:
    requires: [analyzer!, imageMetadata!, images!, thumbnails!]
    function:
      source: csharp/ResizeImage
  thumbnails:
    storageContainer:
      publicAccess: blob
endpoints:
  frontend: $(frontend:primaryEndpoint)
```
```
$ az compose up -g photos-app
Using existing resource group 'photos-app' and location 'westus'
Creating 'analyzer' as cognitive services account 'analyzer-e4a759dc8a6001e2'...
Creating default cosmos db account 'default-79ac7f4131b25692'...
Creating default storage account 'defaultbb87108a1cf2656a'...
Created 'analyzer' as cognitive services account 'analyzer-e4a759dc8a6001e2' in 3s
Created default cosmos db account 'default-79ac7f4131b25692' in 3s
Created default storage account 'defaultbb87108a1cf2656a' in 5s
Creating default function app 'default-dc3b02b9f8b0f3b1'...
Creating 'frontend' as static website in storage account 'defaultbb87108a1cf2656a'...
Creating 'images' as container 'images' in storage account 'defaultbb87108a1cf2656a'...
Creating 'thumbnails' as container 'thumbnails' in storage account 'defaultbb87108a1cf2656a'...
Created 'thumbnails' as container 'thumbnails' in storage account 'defaultbb87108a1cf2656a' in 3s
Created 'images' as container 'images' in storage account 'defaultbb87108a1cf2656a' in 3s
Created 'frontend' as static website in storage account 'defaultbb87108a1cf2656a' in 5s
Created default function app 'default-dc3b02b9f8b0f3b1' in 5s
Creating 'GetImages' as function 'GetImages' in function app 'default-dc3b02b9f8b0f3b1'...
Created 'GetImages' as function 'GetImages' in function app 'default-dc3b02b9f8b0f3b1' in <1s
Creating 'GetUploadUrl' as function 'GetUploadUrl' in function app 'default-dc3b02b9f8b0f3b1'...
Created 'GetUploadUrl' as function 'GetUploadUrl' in function app 'default-dc3b02b9f8b0f3b1' in <1s
Creating 'ResizeImage' as function 'ResizeImage' in function app 'default-dc3b02b9f8b0f3b1'...
Created 'ResizeImage' as function 'ResizeImage' in function app 'default-dc3b02b9f8b0f3b1' in <1s
Creating 'imageMetadata' as collection 'images' in cosmos db database 'imagesdb' account 'default-79ac7f4131b25692'...
Created 'imageMetadata' as collection 'images' in cosmos db database 'imagesdb' account 'default-79ac7f4131b25692' in 5s
Configuring default function app...
Configuring default storage account...
Configuring 'frontend' static website...
Configured 'frontend' static website in <1s
Configured default storage account in 5s
Configured default function app in 12s
Binding 'GetImages' function to 'imageMetadata' cosmos db collection...
Binding 'GetUploadUrl' function to 'images' storage container...
Binding 'ResizeImage' function to 'analyzer' cognitive services account...
Binding 'ResizeImage' function to 'imageMetadata' cosmos db collection...
Binding 'ResizeImage' function to 'images' storage container...
Binding 'ResizeImage' function to 'thumbnails' storage container...
Binding 'frontend' static website to default function app...
Binding 'frontend' static website to 'images' storage container...
Bound 'frontend' static website to default function app in <1s
Bound 'frontend' static website to 'images' storage container in <1s
Bound 'GetImages' function to 'imageMetadata' cosmos db collection in 3s
Bound 'GetUploadUrl' function to 'images' storage container in 3s
Bound 'ResizeImage' function to 'analyzer' cognitive services account in 3s
Bound 'ResizeImage' function to 'imageMetadata' cosmos db collection in 3s
Bound 'ResizeImage' function to 'images' storage container in 3s
Bound 'ResizeImage' function to 'thumbnails' storage container in 3s
Pushing 'GetImages' source to function app 'default-dc3b02b9f8b0f3b1'...
Pushing 'GetUploadUrl' source to function app 'default-dc3b02b9f8b0f3b1'...
Pushing 'ResizeImage' source to function app 'default-dc3b02b9f8b0f3b1'...
Pushing 'frontend' content to static website in storage account 'defaultbb87108a1cf2656a'...
Pushed 'frontend' content to static website in storage account 'defaultbb87108a1cf2656a' in 6s
Pushed 'GetImages' source to function app 'default-dc3b02b9f8b0f3b1' in 39s
Pushed 'GetUploadUrl' source to function app 'default-dc3b02b9f8b0f3b1' in 39s
Pushed 'ResizeImage' source to function app 'default-dc3b02b9f8b0f3b1' in 39s

endpoints:
  frontend: https://defaultbb87108a1cf2656a.z20.web.core.windows.net

Compose completed in 1m 17s
```
