#!/bin/bash


MODEL=$1
PARAMETERS=$2

for c in 1 2 3 4 5
do

echo "Training $MODEL on $PARAMETERS"
python3 machamp/train.py --dataset_config configs/Skills/$PARAMETERS.json --parameters_config configs/Skills/$MODEL.$c.json --name skill.$MODEL.$PARAMETERS.$c

done

deactivate