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
Added static website 'frontend' to 'azure-compose.yaml'
$ cat azure-compose.yaml
services:
  frontend:
    staticWebsite:
      content: www/dist
      index: index.html
```

### Upload images to Blob storage with Azure Functions
```
$ az compose storage-container add -n images --public-access blob
Added storage container 'images' to 'azure-compose.yaml'
$ az compose function add -n GetUploadUrl -s csharp/GetUploadUrl
Added function 'GetUploadUrl' to 'azure-compose.yaml'
$ az compose ref add --from GetUploadUrl --to images -s
Added reference from 'GetUploadUrl' to 'images' with sensitive properties
$ az compose ref add --from frontend --to-default function-app --to images
Added reference from 'frontend' to default function app
Added reference from 'frontend' to 'images'
$ cat azure-compose.yaml
services:
  frontend:
    staticWebsite:
      requires: [+functionApp, images]
      content: www/dist
      index: index.html
  GetUploadUrl:
    function:
      requires: images!
      source: csharp/GetUploadUrl
  images:
    storageContainer:
      publicAccess: blob
```

### Resize images with Azure Functions
```
$ az compose storage-container add -n thumbnails --public-access blob
Added storage container 'thumbnails' to 'azure-compose.yaml'
$ az compose function add -n ResizeImage -s csharp/ResizeImage -r images! -r thumbnails!
Added function 'ResizeImage' to 'azure-compose.yaml'
Added reference from 'ResizeImage' to 'images' with sensitive properties
Added reference from 'ResizeImage' to 'thumbnails' with sensitive properties
$ cat azure-compose.yaml
services:
  frontend:
    staticWebsite:
      requires: [+functionApp, images]
      content: www/dist
      index: index.html
  GetUploadUrl:
    function:
      requires: images!
      source: csharp/GetUploadUrl
  images:
    storageContainer:
      publicAccess: blob
  ResizeImage:
    function:
      requires: [images!, thumbnails!]
      source: csharp/ResizeImage
  thumbnails:
    storageContainer:
      publicAccess: blob
```

### Store image metadata with Azure Cosmos DB
```
$ az compose cosmosdb-collection add -n imageMetadata --collection-name images --database-name imagesdb --throughput 400
Added Cosmos DB collection 'imageMetadata'
$ az compose ref add --from ResizeImage --to imageMetadata -s
Added reference from 'ResizeImage' to 'imageMetadata' with sensitive properties
$ az compose function add -n GetImages -s csharp/GetImages -r imageMetadata!
Added function 'GetImages' to 'azure-compose.yaml'
Added reference from 'GetImages' to 'imageMetadata' with sensitive properties
$ cat azure-compose.yaml
services:
  frontend:
    staticWebsite:
      requires: [+functionApp, images]
      content: www/dist
      index: index.html
  GetImages:
    function:
      requires: imageMetadata!
      source: csharp/GetImages
  GetUploadUrl:
    function:
      requires: images!
      source: csharp/GetUploadUrl
  imageMetadata:
    cosmosDBCollection:
      name: images
      database:
      - name: imagesdb
      throughput: 400
  images:
    storageContainer:
      publicAccess: blob
  ResizeImage:
    function:
      requires: [imageMetadata!, images!, thumbnails!]
      source: csharp/ResizeImage
  thumbnails:
    storageContainer:
      publicAccess: blob
```

### Add image captions with Computer Vision
```
$ az compose computer-vision add -n analyzer
Added cognitive services account 'analyzer' to 'azure-compose.yaml'
$ az compose ref add --from ResizeImage --to analyzer -s
Added reference from 'ResizeImage' to 'analyzer' with sensitive properties
$ cat azure-compose.yaml
services:
  analyzer:
    computerVision:
  frontend:
    staticWebsite:
      requires: [+functionApp, images]
      content: www/dist
      index: index.html
  GetImages:
    function:
      requires: imageMetadata!
      source: csharp/GetImages
  GetUploadUrl:
    function:
      requires: images!
      source: csharp/GetUploadUrl
  imageMetadata:
    cosmosDBCollection:
      name: images
      database:
      - name: imagesdb
      throughput: 400
  images:
    storageContainer:
      publicAccess: blob
  ResizeImage:
    function:
      requires: [imageMetadata!, images!, thumbnails!, analyzer!]
      source: csharp/ResizeImage
  thumbnails:
    storageContainer:
      publicAccess: blob
```

### Add authentication
```
$ code azure-compose.yaml # edit manually
$ cat azure-compose.yaml
services:
  analyzer:
    computerVision:
  frontend:
    staticWebsite:
      requires:
        +functionApp:
        images:
          methods: [GET, PUT]
      content: www/dist
      index: index.html
  GetImages:
    function:
      requires: imageMetadata!
      source: csharp/GetImages
  GetUploadUrl:
    function:
      requires: images!
      source: csharp/GetUploadUrl
  imageMetadata:
    cosmosDBCollection:
      name: images
      database:
      - name: imagesdb
      throughput: 400
  images:
    storageContainer:
      publicAccess: blob
  ResizeImage:
    function:
      requires: [imageMetadata!, images!, thumbnails!, analyzer!]
      source: csharp/ResizeImage
  thumbnails:
    storageContainer:
      publicAccess: blob
```
