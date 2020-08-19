#!/bin/bash
export S3_ENDPOINT_URL=https://storage.googleapis.com
export HOME=/tmp

pegasus-plan \
        --verbose \
        --conf pegasus.properties \
        --dax wf.dax \
        --dir submit \
        --cleanup none \
        --sites gcp \
        --input-dir input \
        --output-dir output 2>&1 \
        --submit| tee pegasus-plan.out
