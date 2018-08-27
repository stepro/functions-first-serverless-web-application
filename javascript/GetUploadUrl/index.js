const azure = require('azure-storage');

module.exports = function (context, req) {
    const filename = req.query.filename;
    const container = 'images';

    const blobService = azure.createBlobService(process.env.IMAGES_ACCOUNT_CONNECTION_STRING);

    const currentDate = new Date();
    const startDate = new Date(currentDate.getTime() - 60 * 1000);
    const expiryDate = new Date(currentDate.getTime() + 5 * 60 * 1000);

    const permissions = 
        azure.BlobUtilities.SharedAccessPermissions.READ +
        azure.BlobUtilities.SharedAccessPermissions.WRITE +
        azure.BlobUtilities.SharedAccessPermissions.CREATE;

    const sharedAccessPolicy = {
        AccessPolicy: {
            Permissions: permissions,
            Start: startDate,
            Expiry: expiryDate
        }
    };

    const sasToken = blobService.generateSharedAccessSignature(container, filename, sharedAccessPolicy);

    context.res = {
        url: blobService.getUrl(container, filename, sasToken)
    };
    context.done();
};