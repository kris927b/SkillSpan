#!/bin/bash


MODEL=$1
TYPE=$2
SET=$3

for i in 1 2 3 4 5
do
    mkdir -p data/$MODEL
    python3 machamp/predict.py machamp/logs/skill.$MODEL.${TYPE,,}.$i/*/model.tar.gz data/Skills/corpus_big_$SET.conll data/$MODEL/$TYPE.big.$SET.$i.out --dataset big --device 0
    python3 machamp/predict.py machamp/logs/skill.$MODEL.${TYPE,,}.$i/*/model.tar.gz data/Skills/corpus_house_$SET.conll data/$MODEL/$TYPE.house.$SET.$i.out --dataset house --device 0
    python3 machamp/predict.py machamp/logs/skill.$MODEL.${TYPE,,}.$i/*/model.tar.gz data/Skills/corpus_tech_$SET.conll data/$MODEL/$TYPE.tech.$SET.$i.out --dataset tech --device 0
done