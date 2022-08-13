#!/bin/bash

for MODEL in bert spanbert jobbert jobspanbert
do
  for TYPE in skills knowledge multi
  do
    for SET in dev test
    do
      for i in 1 2 3 4 5
      do
        mkdir -p data/$MODEL
        python3 machamp/predict.py logs/skill.$MODEL.${TYPE,,}.$i/*/model.tar.gz data/Skills/skillspan_house_$SET.conll data/$MODEL/$TYPE.house.$SET.$i.out --dataset house
        python3 machamp/predict.py logs/skill.$MODEL.${TYPE,,}.$i/*/model.tar.gz data/Skills/skillspan_tech_$SET.conll data/$MODEL/$TYPE.tech.$SET.$i.out --dataset tech
      done
    done
  done
done