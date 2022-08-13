#!/bin/bash

MODEL=$1 # e.g., jobbert
PARAMETERS=$2 # skills | knowledge | multi
ITER=$3 # e.g., 1-5

echo "Training $MODEL on $PARAMETERS"
python3 machamp/train.py --dataset_config configs/Skills/$PARAMETERS.json --parameters_config configs/Skills/$MODEL.$ITER.json --name skill.$MODEL.$PARAMETERS.$ITER
