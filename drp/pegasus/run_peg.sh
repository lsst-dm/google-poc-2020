#!/bin/bash
export S3_ENDPOINT_URL=https://storage.googleapis.com
export HOME=/tmp
export COL=`date +%y%m%d%H%M`
export REP=s/OUTCOL/hfc\\/$COL/
sed $REP wf.dax > wfx.dax

pegasus-plan \
        --verbose \
        --conf pegasus.properties \
        --dax wfx.dax \
        --dir submit \
        --cleanup none \
        --sites gcp \
        --input-dir input \
        --output-dir output 2>&1 \
        --submit| tee pegasus-plan.out
