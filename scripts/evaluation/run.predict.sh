#!/bin/bash

MODEL=$1 # e.g., jobbert
TYPE=$2 # skills knowledge multi
SET=$3 # dev test

mkdir -p data/preds/$MODEL

for seed in 3477689 4213916 8749520 6828303 9364029
do
    python3 ~/SkillSpan/machamp/predict.py logs/skill.$MODEL.$TYPE.$seed/*/model.pt data/conll/skillspan_house_$SET.conll data/preds/$MODEL/$TYPE.house.$SET.$seed.out \
    --dataset house

    python3 ~/SkillSpan/machamp/predict.py logs/skill.$MODEL.$TYPE.$seed/*/model.pt data/conll/skillspan_tech_$SET.conll data/preds/$MODEL/$TYPE.tech.$SET.$seed.out \
    --dataset tech
    
done