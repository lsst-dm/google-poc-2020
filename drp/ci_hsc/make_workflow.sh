#!/usr/bin/env sh

COLLECTION=testrun/output_1
INPUTCOLL=HSC/defaults
QGRAPH_FILE=hsc48
INDIV=individual
BPATH="$1"
OUTDIR="$2"

if [ ! -d $OUTDIR/$INDIV ]; then
  mkdir -p $OUTDIR/$INDIV
fi

pipetask qgraph -d "skymap='discrete/ci_hsc' AND tract=0 AND patch = 69" -b $BPATH \
    -i "$INPUTCOLL" -o "$COLLECTION" \
    -p "$OBS_SUBARU_DIR"/pipelines/DRP.yaml \
    --save-qgraph $OUTDIR/$QGRAPH_FILE.pickle

# All dataset types need to be registered before the next command
pipetask run -b $BPATH \
   --output-run "$COLLECTION" \
   --init-only --register-dataset-types --qgraph $OUTDIR/$QGRAPH_FILE.pickle

pipetask qgraph --qgraph $OUTDIR/$QGRAPH_FILE.pickle --show workflow -b $BPATH \
  -i "$INPUTCOLL" \
  --save-single-quanta $OUTDIR/$INDIV/quantum-{:06d}.pickle  >& $OUTDIR/wf

export DIR=`dirname "${BASH_SOURCE[0]}"`
python $DIR/../python/pegasusize.py --initPickle $QGRAPH_FILE.pickle -i $OUTDIR/wf -o $OUTDIR/wf.dax
