#!/usr/bin/env python

import sys
from lsst.daf.butler import Butler, Config

bucket = sys.argv[1]
username = sys.argv[2]
db = sys.argv[3]
print(f"Creating repo at s3://{bucket} and {username}@{db}")

config = Config()
config[".datastore.cls"] = "lsst.daf.butler.datastores.s3Datastore.S3Datastore"
config[".datastore.root"] = f"s3://{bucket}"  # TODO
config[".registry.db"] = f"postgresql://{username}@{db}:5432"

# equiv to `butler create s3://$BUCKET --seed-config  butler.yaml --override`
# with a configured butler.yaml
Butler.makeRepo(f"s3://{bucket}", config=config, forceConfigRoot=True)
