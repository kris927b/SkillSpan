#!/bin/bash

MODEL=$1
PARAMETERS=$2
ITER=$3

echo "Training $MODEL on $PARAMETERS"
python machamp/train.py --dataset_config configs/Skills/$PARAMETERS.json --parameters_config configs/Skills/$MODEL.$ITER.json --device 1 --name skill.$MODEL.$PARAMETERS.$ITER
