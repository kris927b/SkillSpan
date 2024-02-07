#!/bin/bash

MODEL=$1 # e.g., bert
PARAMETERS=$2 # e.g., skill knowledge multi

for c in 3477689 4213916 8749520 6828303 9364029
do

    echo "Training $MODEL on $PARAMETERS using seed $c"
    python3 machamp/train.py \
        --dataset_configs configs/$PARAMETERS.json \
        --parameters_config configs/$MODEL.json \
        --name skill.$MODEL.$PARAMETERS.$c \
        --seed $c \

done