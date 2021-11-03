# SkillSpan
SKILLSPAN: Competences as Spans for Skill Extraction from Job Postings


## Cloning this repo

This repo contains a submodule which contains the source code for MaChAmp (mtp). 
To clone both repos (this + the submodule) use the following command:

```bash
$ git clone --recurse-submodules https://github/kris927b/SkillSpan.git
```

Or use these two commands:

```bash
$ git clone https://github/kris927b/SkillSpan.git 
$ git submodule update --init --recursive
```

## Data set acquisition

You can get the data set produced as part of the paper by filling out this form: https://forms.gle/PASTE_SOME_ID.

Place all the data in `data/Skills`

## Running the code

### Installing the requirements

To install all the required packagse run the following command

```
pip3 install --user -r machamp/requirements.txt
```

### Running everything

Once you have installed the required packages, you are now ready to run the experiments. 

We have provided three different scripts for running the experiments. 

To run everything in the paper, simply call:

```
bash scripts/run.all.sh
```

### Running individual experiments

If you rather than running all experiments wants to run individual experiments, we have provided two scripts. 

One for running an experiment as in JobBERT on Skills where it runs all 5 seeds:

```
bash scripts/run.experiment.sh $MODEL $EXPERIMENT
```

And another one for running individual seed numbers within an experiment. So running JobBERT on Skills seed 1:

```
bash scripts/run.individual.sh $MODEL $EXPERIMENT $SEED
```

### Predicting on dev and test set

To predict on the dev and test sets we have provided the following script for convenience

```
SET = skills | skills_doc | knowledge | knowledge_doc | multi | multi_doc

bash scripts/run.predict.sh $MODEL $EXPERIMENT $SET
```

**NOTE:** the sets named "_doc" is for running the longformer.


### Evaluate the performance

To evaluate the models performance run 

```
bash scripts/run.evalaute.sh $MODEL
```

This will generate a bunch of metric files in which you can find the results.

#### Run ASO 

To create the ASO stats for the models run

```
bash scripts/run.significance.sh
```

This will generate the ASO scores for all experiments present in the metrics folder produced by the evaluate script. 

