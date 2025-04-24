R-code project for exploring informational load of morphology in different langauges using Universal Depedencies.

# Project overview
 We are using the Universal Dependencies dataset to explore different facets of information in morphology. We are using the morphology features in UD and calculating different metrics. We have described the metrics in prose in our article under the headings "Detailed technical procedure" and "Additional metrics".

#Requirements
The code for this project is all written in R (4.4.3, but nearby versions should also work) and relies on a number of external packages, most importantly udpipe, reshape2 and tidyverse (mainly dplyr, ggplot and tidyr). We use the package groundhog to tie CRAN packages to a particular date and remotes::install_github with a particular commit as ref to version the GitHub packages. The script `code/01_requirements.R` sets up all of this for you.

The working directory should be `code`. The output folder will also be located in this directory.

The project also relies on external data, there are scripts for fetching the precise data from UD (v2.14), Grambank, Glottolog and the Google project url-nlp. All data is referenced to particular versions, either by Zenodo records or Git commit refs.

 ```
 code/02_get_grambank_data.R
 code/02_google_pop.R
 code/02_get_glottolog_language_table.R
 code/02_get_UD.R
 ```
 
For more detail on the calculation of the metrics, please see the script `code/03_process_data_per_UD_proj.R`. This is the "meat" of the project, this is where the morphological features are split and pruned if necessary, "dummy"-features are inserted, surprisal is calculated etc. It is a relatively complex script which defines a function that runs through all of the UD-datasets. It takes three arguments, directory (where it expects there to be a folder called `processed_data` that is produced by `code/02_collapse_UD_dirs.R`), agg_level (wether the aggregation of the analysis based on upos or lemma) and core_features (wether it is pruning to only "core" features or considering all feature categories which are found). In `code/00_run_all.R` we run this function four times, varying the last two binary arguments so that we get all the combinations of metrics that we are after. The code in  `code/03_process_data_per_UD_proj.R` matches the steps described in the LaTeX sections "Detailed technical procedure" and "Additional metrics". This function produces a rich output of information per token and (mean) summaries. Unfortunately, the token-level information is too large for plotting. Instead, we use `code/03_stack_summaries.R` to stack the summaries that are produced for each dataset on each function call and correctly combine them into one table which is then written to `code/output/all_summaries_stacked.tsv`. This table is then read into plotting scripts.

## Overview of scripts
 ```
 #setting up packages, output directories etc
 code/01_requirements.R
 ```
 ```
 #fetching external data (non-UD)
 code/02_get_grambank_data.R
 code/02_google_pop.R
 code/02_get_glottolog_language_table.R
 ```

 ```
 #fetching UD, reading in the conllu-formatted files with udpipe::udpipe_read_conllu, removing tokens with upos=X|PUNCT|SYM and combining them into tsv-files (one per dataset)
 code/02_get_UD.R
 code/02_collapse_UD_dirs.R
 ```
 ```
 #define a function that calculates the metrics and writes to file
 code/03_process_data_per_UD_proj.R
 #run said function for the different variations of analysis
 process_data_per_UD_proj(directory = "output", agg_level = "upos", core_features = "core_features_only`
 process_data_per_UD_proj(directory = "output", agg_level = "lemma", core_features = "core_features_only`
 process_data_per_UD_proj(directory = "output", agg_level = "upos", core_features = "all_features`
 process_data_per_UD_proj(directory = "output", agg_level = "lemma", core_features = "all_features`
 ```

 ```
 #stack summaried information and combine it correctly for plotting
 code/03_stack_summaries.R
 ```

 ```


 #plotting
 code/04_plot_SPLOM.R
 ```

# Tests
 Unit tests for `03_process_data_per_UD_proj.R` can be found in `tests/test_03_process_data_per_UD_proj.R`.
 These check the calculation of key values for test data defined within the test script.

# Data
## Universal Dependencies
To run the scripts in this repository you will need to download the raw data from [version 2.14 of the Universal Dependencies database](https://lindat.mff.cuni.cz/repository/xmlui/handle/11234/1-5502/allzip).

The downloaded file must be unzipped twice: unzipping the initial file produces three further compressed files, of which you should unzip `ud-treebanks-v2.14.tgz`. This in turn produces 283 directories, one for each treebank, with names like "UD_Abaza-ATB" and "UD_English-EWT".

All of these should be copied into `UD_complexity/data/ud-treebanks-v2.14/`.

You can also run the script `code/02_get_UD.R` to set everything up.

## Language populations
Google NLP-reserach team: <https://raw.githubusercontent.com/google-research/url-nlp/refs/heads/main/linguameta/linguameta.tsv>

## Grambank v1
<https://zenodo.org/records/7844558>
<https://zenodo.org/records/7740140/files/g>

## Output folder details

+ `processed_data`: Data processed by steps earlier than `03_process_data_per_UD_proj.R`, and used by that script to generate further output files.
+ `summarised`: Summary data at the level of the whole dataset (e.g. number of types, number of tokens, ratios and surprisals)
+ `surprisal_per_feat`: counts, proportions and sum of surprisals for individual feature values
+ `surprisal_per_feat_lookup`: counts, proportions and surprisals for individual feature values
+ `surprisal_per_featstring`: counts, proportions and surprisals for full feature strings for each token (where the counts and proportions are determined per `agg_level`, either UPOS, lemma or token)
+ `surprisal_per_featstring_lookup`: counts, proportions and surprisals per feature string, per `agg_level` (UPOS, lemma or token)
+ `surprisal_per_token`: counts, proportions and surprisals for each token regardless of morphological features. Ignores UPOS, so "marks" (English verb) and "marks" (English plural noun) would be counted as two instances of the same token.
+ `TTR`: Type-token ratios of individual tokens