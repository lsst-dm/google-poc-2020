#!/usr/bin/env sh

export BUCKET=bucket_w_2020_30
export S3_ENDPOINT_URL=https://storage.googleapis.com
# Need a configured butler.yaml 
butler create s3://$BUCKET --seed-config  butler.yaml --override
butler register-instrument s3://$BUCKET lsst.obs.subaru.HyperSuprimeCam
butler write-curated-calibrations s3://$BUCKET  -i HSC

makeGen3Skymap.py s3://$BUCKET -C $CI_HSC_GEN3_DIR/configs/skymap.py skymaps
butler ingest-raws s3://$BUCKET $TESTDATA_CI_HSC_DIR/raw

butler define-visits s3://$BUCKET -i HSC --collections HSC/raw/all
butler import s3://$BUCKET $TESTDATA_CI_HSC_DIR --export-file $CI_HSC_GEN3_DIR/resources/external.yaml
