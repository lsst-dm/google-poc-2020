#!/usr/bin/env python

import boto3, os, sys

endpoint = os.environ.get("S3_ENDPOINT_URL", 'https://storage.googleapis.com')
s3client = boto3.client("s3", endpoint_url=endpoint)

bucketName = sys.argv[1]
thisDir = sys.argv[2]

s3client.create_bucket(Bucket=bucketName)

for folder in (thisDir, thisDir+"/../../pegasus/"):
    for root, dirs, files in os.walk(folder):
        for filename in files:
            fullpath = os.path.join(root, filename)
            # Put all qgraph pickle files to the "input" subfolder
            key = "input/" + filename if fullpath.endswith("pickle") else filename
            print(f"Upload {key} from {fullpath}")
            s3client.upload_file(Bucket=bucketName, Key=key, Filename=fullpath)
