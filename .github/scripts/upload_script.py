
import firebase_admin
from firebase_admin import credentials, storage
from os import environ
import os
import sys

# optional: Import UUID4 to create access token
from uuid import uuid4

# base64 decoded key file will be stored in temporary directory on runner machine
# https://github.com/marketplace/actions/base64-to-file
githubSecretPath = './secrets/'

# google cloud's service account key file absolute path on github's machine directory
# note that the file name must be matched with the file name created from timheuer/base64-to-file@v1 action on the workflow
keyFilePath = githubSecretPath + 'firebase_secret_key.json'

# apply the bucket domain to the credentials
cred = credentials.Certificate(keyFilePath)
firebase_admin.initialize_app(cred, {
    'storageBucket' : 'energym-9f022.appspot.com'
})

# refer to the storage bucket
bucket = storage.bucket()

# get the upload file's path in repository's directory
# the file to upload in this scenario (a zip file) is in the same directory with the script
fileName = f"{environ.get('FILE_NAME')}.apk"
dirname = "build/app/outputs/flutter-apk"
fileFullPath = os.path.join(dirname, fileName)

# if the file name contains file path, the bucket will create folders corresponding to the path.
blob = bucket.blob(f"gym_app_builds/{fileName}")

# optional: Create new token, this one only used for downloading directly from firebase console page
accessToken = uuid4()

# optional: Create new dictionary with the metadata
metadata = { "firebaseStorageDownloadTokens": accessToken }

# optional: Set meta data for the blob wich contains the access token
blob.metadata = metadata

#upload to firebase storage
blob.upload_from_filename(fileFullPath)

# optional: make the file public
# blob.make_public()

print("Your file url - ", blob.public_url)