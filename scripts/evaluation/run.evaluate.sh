#!/bin/bash

GOLD_PATH="data/conll/"
# 3477689 4213916 8749520 6828303 9364029

for model in bert jobbert spanbert jobspanbert longformer
do
  PRED_PATH="data/$model"
  for method in skills knowledge multi
  do
      for site in house tech
      do
          echo "Evaluating $model $site on $method"
          python3 ~/SkillSpan/scripts/evaluate.py $GOLD_PATH/skillspan_"$site"_test.conll $PRED_PATH/$method.$site.test.3477689.out $PRED_PATH/$method.$site.test.4213916.out $PRED_PATH/$method.$site.test.8749520.out $PRED_PATH/$method.$site.test.4.out $PRED_PATH/$method.$site.test.9364029.out
      done
  done
done