#!/bin/bash

MODEL=$1
EXTRA=$2

GPATH="data/Skills/"
PPATH="data/$MODEL"

for method in skills knowledge multi
do
    for site in house tech
    do
        echo "Evaluating $MODEL $site on $method"
        python3 scripts/evaluate.py $GPATH/skillspan_"$site"_test"$EXTRA".conll $PPATH/$method.$site.test.1.out $PPATH/$method.$site.test.2.out $PPATH/$method.$site.test.3.out $PPATH/$method.$site.test.4.out $PPATH/$method.$site.test.5.out
    done
done