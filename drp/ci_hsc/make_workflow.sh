#!/usr/bin/env sh

COLLECTION=testrun/output_1
INPUTCOLL=HSC/calib,HSC/raw/all,HSC/masks,refcats,skymaps
QGRAPH_FILE=hsc22
INDIV=individual
BPATH=$CI_HSC_GEN3_DIR/DATA/butler.yaml

pipetask qgraph -d "patch = 69" -b $BPATH \
    -i "$INPUTCOLL" -o "$COLLECTION" \
    -p "$CI_HSC_GEN3_DIR"/pipelines/CiHsc.yaml \
    --save-qgraph "$QGRAPH_FILE.pickle"

# All dataset types need to be registered before the next command
pipetask run -b $BPATH \
   --output-run "$COLLECTION" \
   --init-only --register-dataset-types --qgraph "$QGRAPH_FILE.pickle"

if [ ! -d "$INDIV" ]; then
  mkdir $INDIV
fi

# NOTE: this needs ctrl_mpexec 7a50aba62 or newer
pipetask qgraph --qgraph "$QGRAPH_FILE.pickle" --show workflow -b $BPATH \
  -i "$INPUTCOLL" \
  --save-single-quanta "$INDIV"/quantum-{:06d}.pickle  >& wf 

python pegasusize.py --initPickle "$QGRAPH_FILE.pickle" -i wf -o ciHsc.dax 
