#!/usr/bin/env sh

export S3_ENDPOINT_URL=https://storage.googleapis.com

COLLECTION=testrun/output_1
INPUTCOLL=HSC/defaults
QGRAPH_FILE=rc49
INDIV=individual
BPATH=$1

pipetask \
    --log-level pipe.base=DEBUG --long-log \
    qgraph -b $BPATH \
    -d "(tract=9615 or tract=9697 or (tract=9813 and patch not in (0, 8, 9, 63, 72, 73, 80))) \
        and detector IN (0..103) and detector != 9 and instrument='HSC' and skymap='hsc_rings_v1'" \
    -i $INPUTCOLL -o "$COLLECTION" \
    -p HSC-RC2.yaml \
    --save-qgraph "$QGRAPH_FILE.qgraph"

# All dataset types need to be registered before the next command
# Only need it once for a repo
pipetask run -b $BPATH \
   --output-run "$COLLECTION" \
   --init-only --register-dataset-types --qgraph "$QGRAPH_FILE.qgraph"

if [ ! -d "$INDIV" ]; then
  mkdir $INDIV
fi

pipetask qgraph --qgraph "$QGRAPH_FILE.qgraph" --show workflow -b $BPATH \
  -i "$INPUTCOLL" \
  --save-single-quanta "$INDIV"/quantum-{:06d}.qgraph  >& "wf_$QGRAPH_FILE"

python pegasusize.py --initPickle "$QGRAPH_FILE.qgraph" -i "wf_$QGRAPH_FILE" -o "wf_$QGRAPH_FILE.dax"
