import * as compose from "@cloud-compose/compose";
import * as azure from "@cloud-compose/azure";
// import * as axios from "axios";
// import * as Jimp from "jimp";
// import * as storage from "azure-storage";
// import "./cloud-defaults";

// azure.httpFunction("GetImages").handle("GET", (context, documents) => {
//     context.response.end(documents);
// });

// azure.httpFunction("GetUploadUrl").handle("GET", async context => {
//     const blobService = await azure.storage.container("images").createClient();
//     const filename = context.request.query.filename;

//     const currentDate = new Date();
//     const startDate = new Date(currentDate.getTime() - 60 * 1000);
//     const expiryDate = new Date(currentDate.getTime() + 5 * 60 * 1000);

//     const permissions = 
//         storage.BlobUtilities.SharedAccessPermissions.READ +
//         storage.BlobUtilities.SharedAccessPermissions.WRITE +
//         storage.BlobUtilities.SharedAccessPermissions.CREATE;

//     const sharedAccessPolicy = {
//         AccessPolicy: {
//             Permissions: permissions,
//             Start: startDate,
//             Expiry: expiryDate
//         }
//     };

//     const sasToken = blobService.generateSharedAccessSignature(images.name, filename, sharedAccessPolicy);

//     context.response.end({
//         url: blobService.getUrl(images.name, filename, sasToken)
//     });
// });

// azure.storage.container("images").onPut({
//     parameters: [
//         { target: azure.storage.container("thumbnails") }
//     ],
//     return: { target: azure.cosmosDB.collection("imageMetadata") }
// }, async (context, thumbnail) => {
//     const image = await Jimp.read(context.blob);
//     image.cover(200, 200).quality(60).getBuffer(Jimp.MIME_JPEG, (error, stream) => {
//         if (error) {
//             context.error(error);
//             return;
//         }
//         const analyzer = await azure.cognitive.computerVision("analyzer");
//         const response = await axios.post(analyzer.endpoint + '/analyze?visualFeatures=Description&language=en', context.blob, {
//             headers: {
//                 'Ocp-Apim-Subscription-Key': analyzer.key,
//                 'Content-Type': 'application/octet-stream'
//             }
//         });
//         context.set(thumbnail, stream);
//         context.return({
//             id: context.data.name,
//             imgPath: "/" + context.container.name + "/" + context.data.name,
//             thumbnailPath: "/" + thumbnail.container.name + "/" + context.data.name,
//             description: response.data.description
//         });
//     });
// });
