#!/bin/bash

for model in bert spanbert jobbert jobspanbert longformer
do
        for exp in skills knowledge multi
        do
                scripts/run.experiment.sh $model $exp
        done
done