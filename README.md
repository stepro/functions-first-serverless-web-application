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
$ az compose up -g photos-app -l westus
Creating resource group 'photos-app' in location 'westus'...
Creating default storage account 'default4e32ac3fd65ee42b'...
Created default storage account  'default4e32ac3fd65ee42b' in 11s
Creating 'frontend' as static website in storage account 'default4e32ac3fd65ee42b'...
Created 'frontend' as static website in storage account 'default4e32ac3fd65ee42b' in 5s
Pushing 'frontend' content to static website in storage account 'default4e32ac3fd65ee42b'...
Pushed 'frontend' content to static website in storage account 'default4e32ac3fd65ee42b' in 4s

endpoints:
  frontend: https://defaultdefault4e32ac3fd65ee42b.z16.web.core.windows.net

Compose completed in 21s
```

### Upload images to Blob storage with Azure Functions
```
$ az compose storage-container add -n images --public-access blob
Added storage container 'images'
$ az compose function add -n GetUploadUrl -s csharp/GetUploadUrl
Added function 'GetUploadUrl'
$ az compose ref add --from GetUploadUrl --to images -s
Added reference from 'GetUploadUrl' to 'images' with sensitive properties
$ az compose ref add --from frontend --to images
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
endpoints:
  frontend: $(frontend:primaryEndpoint)
```
```
$ az compose up -g photos-app
Using existing resource group 'photos-app' and location 'westus'
Creating default function app 'default-03ed2b5799216a74'...
Creating default storage account 'default4e32ac3fd65ee42b'...
Created default storage account  'default4e32ac3fd65ee42b' in 6s
Creating 'frontend' as static website in storage account 'default4e32ac3fd65ee42b'...
Created default function app 'default-03ed2b5799216a74' in 7s
Created 'frontend' as static website in storage account 'default4e32ac3fd65ee42b' in 2s
Creating 'images' as container 'images' in storage account 'default4e32ac3fd65ee42b'...
Created 'images' as container 'images' in storage account 'default4e32ac3fd65ee42b' in 1s
Creating 'GetUploadUrl' as function 'GetUploadUrl' in function app 'default-03ed2b5799216a74'...
Created 'GetUploadUrl' as function 'GetUploadUrl' in function app 'default-03ed2b5799216a74' in <1s
Binding 'frontend' static website to 'images' storage container...
Binding 'GetUploadUrl' function to 'images' storage container...
Pushing 'frontend' content to static website in storage account 'default4e32ac3fd65ee42b'...
Pushing 'GetUploadUrl' source to function app 'default-03ed2b5799216a74'...
Pushed 'frontend' content to static website in storage account 'default4e32ac3fd65ee42b' in 4s
Pushed 'GetUploadUrl' source to function app 'default-03ed2b5799216a74' in 20s

endpoints:
  frontend: https://defaultdefault4e32ac3fd65ee42b.z16.web.core.windows.net

Compose completed in 54s
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
Creating default function app 'default-03ed2b5799216a74'...
Creating default storage account 'default4e32ac3fd65ee42b'...
Created default storage account  'default4e32ac3fd65ee42b' in 6s
Creating 'frontend' as static website in storage account 'default4e32ac3fd65ee42b'...
Created default function app 'default-03ed2b5799216a74' in 7s
Created 'frontend' as static website in storage account 'default4e32ac3fd65ee42b' in 2s
Creating 'images' as container 'images' in storage account 'default4e32ac3fd65ee42b'...
Creating 'thumbnails' as container 'thumbnails' in storage account 'default4e32ac3fd65ee42b'...
Created 'images' as container 'images' in storage account 'default4e32ac3fd65ee42b' in 1s
Created 'thumbnails' as container 'thumbnails' in storage account 'default4e32ac3fd65ee42b' in 5s
Creating 'GetUploadUrl' as function 'GetUploadUrl' in function app 'default-03ed2b5799216a74'...
Creating 'ResizeImage' as function 'ResizeImage' in function app 'default-03ed2b5799216a74'...
Created 'GetUploadUrl' as function 'GetUploadUrl' in function app 'default-03ed2b5799216a74' in <1s
Created 'ResizeImage' as function 'ResizeImage' in function app 'default-03ed2b5799216a74' in <1s
Binding 'frontend' static website to 'images' storage container...
Binding 'GetUploadUrl' function to 'images' storage container...
Binding 'ResizeImage' function to 'images' storage container...
Binding 'ResizeImage' function to 'thumbnails' storage container...
Pushing 'frontend' content to static website in storage account 'default4e32ac3fd65ee42b'...
Pushing 'GetUploadUrl' source to function app 'default-03ed2b5799216a74'...
Pushing 'ResizeImage' source to function app 'default-03ed2b5799216a74'...
Pushed 'frontend' content to static website in storage account 'default4e32ac3fd65ee42b' in 4s
Pushed 'GetUploadUrl' source to function app 'default-03ed2b5799216a74' in 20s
Pushed 'ResizeImage' source to function app 'default-03ed2b5799216a74' in 20s

endpoints:
  frontend: https://defaultdefault4e32ac3fd65ee42b.z16.web.core.windows.net

Compose completed in 1m 6s
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
Creating default cosmos db account 'default-7c883fccea648894'...
Creating default function app 'default-03ed2b5799216a74'...
Creating default storage account 'default4e32ac3fd65ee42b'...
Created default storage account  'default4e32ac3fd65ee42b' in 6s
Creating 'frontend' as static website in storage account 'default4e32ac3fd65ee42b'...
Created 'frontend' as static website in storage account 'default4e32ac3fd65ee42b' in 5s
Creating 'images' as container 'images' in storage account 'default4e32ac3fd65ee42b'...
Creating 'thumbnails' as container 'thumbnails' in storage account 'default4e32ac3fd65ee42b'...
Created 'images' as container 'images' in storage account 'default4e32ac3fd65ee42b' in 2s
Created 'thumbnails' as container 'thumbnails' in storage account 'default4e32ac3fd65ee42b' in 2s
Creating default cosmos db account 'default-7c883fccea648894' in 16s
Creating 'imageMetadata' as collection 'images' in cosmos db database 'imagesdb' account 'default-7c883fccea648894'...
Created default function app 'default-03ed2b5799216a74' in 31s
Creating 'GetUploadUrl' as function 'GetUploadUrl' in function app 'default-03ed2b5799216a74'...
Created 'GetUploadUrl' as function 'GetUploadUrl' in function app 'default-03ed2b5799216a74' in <1s
Creating 'ResizeImage' as function 'ResizeImage' in function app 'default-03ed2b5799216a74'...
Created 'ResizeImage' as function 'ResizeImage' in function app 'default-03ed2b5799216a74' in <1s
Created 'imageMetadata' as collection 'images' in cosmos db database 'imagesdb' account 'default-7c883fccea648894' in 4m 24s
Binding 'frontend' static website to 'images' storage container...
Binding 'GetUploadUrl' function to 'images' storage container...
Binding 'ResizeImage' function to 'imageMetadata' storage container...
Binding 'ResizeImage' function to 'images' storage container...
Binding 'ResizeImage' function to 'thumbnails' storage container...
Pushing 'frontend' content to static website in storage account 'default4e32ac3fd65ee42b'...
Pushing 'GetUploadUrl' source to function app 'default-03ed2b5799216a74'...
Pushing 'ResizeImage' source to function app 'default-03ed2b5799216a74'...
Pushed 'frontend' content to static website in storage account 'default4e32ac3fd65ee42b' in 4s
Pushed 'GetUploadUrl' source to function app 'default-03ed2b5799216a74' in 20s
Pushed 'ResizeImage' source to function app 'default-03ed2b5799216a74' in 20s

endpoints:
  frontend: https://defaultdefault4e32ac3fd65ee42b.z16.web.core.windows.net

Compose completed in 4m 46s
```
