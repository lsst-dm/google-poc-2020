#!/usr/bin/env sh

export S3_ENDPOINT_URL=https://storage.googleapis.com

COLLECTION=testrun/output_1
INPUTCOLL=HSC/calib,HSC/raw/all,refcats,HSC/masks,skymaps
QGRAPH_FILE=run220
INDIV=individual
BPATH=butler.yaml


pipetask qgraph -b $BPATH \
    -d "(tract=9615 or tract=9697 or (tract=9813 and patch not in (0, 8, 9, 63, 72, 73, 80))) and detector IN (0..103) and detector != 9" \
    -i $INPUTCOLL -o "$COLLECTION" \
    -p HSC-RC2.yaml \
    --loglevel pipe.base=DEBUG --longlog\
    --save-qgraph "$QGRAPH_FILE.pickle"

# All dataset types need to be registered before the next command
# Only need it once for a repo
pipetask run -b $BPATH \
   --output-run "$COLLECTION" \
   --init-only --register-dataset-types --qgraph "$QGRAPH_FILE.pickle"

if [ ! -d "$INDIV" ]; then
  mkdir $INDIV
fi

pipetask qgraph --qgraph "$QGRAPH_FILE.pickle" --show workflow -b $BPATH \
  -i "$INPUTCOLL" \
  --save-single-quanta "$INDIV"/quantum-{:06d}.pickle  >& "wf_$QGRAPH_FILE"

python pegasusize.py --initPickle "$QGRAPH_FILE.pickle" -i "wf_$QGRAPH_FILE" -o "wf_$QGRAPH_FILE.dax" 