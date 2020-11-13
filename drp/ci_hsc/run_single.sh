#!/usr/bin/env sh

export BUCKET=$1
export USERNAME=$2
export DB=$3
export S3_ENDPOINT_URL=https://storage.googleapis.com

source /opt/lsst/software/stack/loadLSST.bash
setup lsst_distrib
setup -j -r ~/ci_hsc_gen3
setup -j -r ~/testdata_ci_hsc

psql postgresql://$USERNAME@$DB -c "CREATE EXTENSION btree_gist;"

mkdir $CI_HSC_GEN3_DIR/DATA
cat << EOF > $CI_HSC_GEN3_DIR/DATA/butler.yaml
datastore:
  cls: lsst.daf.butler.datastores.fileDatastore.FileDatastore
  root: s3://$BUCKET
registry:
  db: postgresql://$USERNAME@$DB:5432
EOF

scons --directory=$CI_HSC_GEN3_DIR --repo-root=s3://$BUCKET --butler-config=$CI_HSC_GEN3_DIR/DATA/butler.yaml --config-override >& log_scons
