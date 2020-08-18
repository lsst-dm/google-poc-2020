#!/bin/bash

cd /root
source ./miniforge3/bin/activate base
./harness.py "$@"
