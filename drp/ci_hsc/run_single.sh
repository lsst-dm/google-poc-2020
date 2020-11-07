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

cat << EOF > butler.yaml
datastore:
  cls: lsst.daf.butler.datastores.s3Datastore.S3Datastore
  records:
    table: s3_datastore_records
  root: s3://$BUCKET
registry:
  db: postgresql://$USERNAME@$DB:5432
EOF

export BPATH=`realpath butler.yaml`
scons --directory=$CI_HSC_GEN3_DIR --repo-root=s3://$BUCKET --butler-config=$BPATH --config-override >& log_scons
