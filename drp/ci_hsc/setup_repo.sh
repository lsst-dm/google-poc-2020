#!/usr/bin/env sh

if [ "$1" != "" ]; then
    export BUCKET=$1
else
    echo "Need the datastore bucket name"
fi

export S3_ENDPOINT_URL=https://storage.googleapis.com

butler register-instrument s3://$BUCKET lsst.obs.subaru.HyperSuprimeCam
butler write-curated-calibrations s3://$BUCKET  HSC

butler register-skymap s3://$BUCKET -C $CI_HSC_GEN3_DIR/configs/skymap.py
butler ingest-raws s3://$BUCKET $TESTDATA_CI_HSC_DIR/raw

butler define-visits s3://$BUCKET HSC --collections HSC/raw/all
butler import s3://$BUCKET $TESTDATA_CI_HSC_DIR --export-file $CI_HSC_GEN3_DIR/resources/external.yaml
