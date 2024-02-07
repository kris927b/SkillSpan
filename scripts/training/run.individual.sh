#!/bin/bash

MODEL=$1 # e.g., jobbert
PARAMETERS=$2 # skills | knowledge | multi
SEED=$3 # e.g., we used one of the following 3477689 4213916 8749520 6828303 9364029

echo "Training $MODEL on $PARAMETERS"
python3 ~/SkillSpan/machamp/train.py \
    --dataset_configs configs/$PARAMETERS.json \
    --parameters_config configs/$MODEL.json \
    --name skill.$MODEL.$PARAMETERS.$SEED \
    --seed $SEED
    