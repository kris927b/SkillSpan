#!/bin/bash

GPATH="data/Skills/"

for model in bert jobbert spanbert jobspanbert
do
  PPATH="data/$model"
  for method in skills knowledge multi
  do
      for site in house tech
      do
          echo "Evaluating $model $site on $method"
          python3 scripts/evaluate.py $GPATH/skillspan_"$site"_test.conll $PPATH/$method.$site.test.1.out $PPATH/$method.$site.test.2.out $PPATH/$method.$site.test.3.out $PPATH/$method.$site.test.4.out $PPATH/$method.$site.test.5.out
      done
  done
done