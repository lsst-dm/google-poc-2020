#!/usr/bin/env sh

COLLECTION=testrun/output_2
INPUTCOLL=HSC/calib,HSC/raw/all,HSC/masks,refcats,skymaps
QGRAPH_FILE=small
INDIV=individual
BPATH="$1"

pipetask qgraph -d "exposure = 903334 and detector = 22" -b $BPATH \
    -i "$INPUTCOLL" -o "$COLLECTION" \
    -p "$PIPE_TASKS_DIR"/pipelines/DRP.yaml:processCcd --instrument lsst.obs.subaru.HyperSuprimeCam \
    --save-qgraph "$QGRAPH_FILE.pickle"

# All dataset types need to be registered before the next command
pipetask run -b $BPATH \
   --output-run "$COLLECTION" \
   --init-only --register-dataset-types --qgraph "$QGRAPH_FILE.pickle"

if [ ! -d "$INDIV" ]; then
  mkdir $INDIV
fi

pipetask qgraph --qgraph "$QGRAPH_FILE.pickle" --show workflow -b $BPATH \
  -i "$INPUTCOLL" \
  --save-single-quanta "$INDIV"/quantum-{:06d}.pickle  >& wf 

export DIR=`dirname "${BASH_SOURCE[0]}"`
python $DIR/../python/pegasusize.py --initPickle "$QGRAPH_FILE.pickle" -i wf -o small.dax
