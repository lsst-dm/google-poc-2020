#!/usr/bin/env sh

# Need a configured butler.yaml 
butler create s3://bucket_w_2020_22 -C butler.yaml --override
butler register-instrument s3://bucket_w_2020_22 -i lsst.obs.subaru.HyperSuprimeCam
butler write-curated-calibrations s3://bucket_w_2020_22  -i lsst.obs.subaru.HyperSuprimeCam --output-run calib/hsc

makeGen3Skymap.py s3://bucket_w_2020_22 -C $CI_HSC_GEN3_DIR/configs/skymap.py skymaps
butler ingest-raws s3://bucket_w_2020_22 -d $TESTDATA_CI_HSC_DIR/raw --output-run raw/hsc

# These will be replaced by butler command lines since w_2020_23
$CI_HSC_GEN3_DIR/bin.src/defineVisits.py . 
$CI_HSC_GEN3_DIR/bin.src/ingestExternalData.py . $CI_HSC_GEN3_DIR/resources/external.yaml
