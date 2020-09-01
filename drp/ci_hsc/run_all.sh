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

export DIR=`dirname "${BASH_SOURCE[0]}"`
python $DIR/create_repo.py $BUCKET $USERNAME $DB
source $DIR/setup_repo.sh $BUCKET
source $DIR/make_workflow.sh  s3://$BUCKET
