#!/bin/bash

# args=("$@")
cd /root
source ./miniforge3/bin/activate base
./harness.py "$@"
# ./harness.py "${args[@]}"
