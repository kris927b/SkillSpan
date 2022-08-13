#!/bin/bash

MODEL=$1 # e.g., jobbert
TYPE=$2 # Skills Knowledge Multi
SET=$3 # dev test

for i in 1 2 3 4 5
do
    mkdir -p data/$MODEL
    python3 machamp/predict.py logs/skill.$MODEL.${TYPE,,}.$i/*/model.tar.gz data/Skills/corpus_house_$SET.conll data/$MODEL/$TYPE.house.$SET.$i.out --dataset house
    python3 machamp/predict.py logs/skill.$MODEL.${TYPE,,}.$i/*/model.tar.gz data/Skills/corpus_tech_$SET.conll data/$MODEL/$TYPE.tech.$SET.$i.out --dataset tech
done