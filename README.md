R-code project for exploring informational load of morphology in different langauges using Universal Depedencies.

# Project overview
 We are using the Universal Dependencies dataset to explore different facets of information in morphology. We are using the morphology features in UD and calculating different metrics. We have described the metrics in prose in our article under the headings "Detailed technical procedure" and "Additional metrics".

# Requirements
The code for this project is all written in R (4.4.3, but nearby versions should also work) and relies on a number of external packages, most importantly `udpipe`, `reshape2` and `tidyverse` (mainly `dplyr`, `ggplot` and `tidyr`). For package-versioning,we use the R-package `groundhog` to tie CRAN packages to a particular date and `remotes::install_github` with a particular commit as ref to version the GitHub packages. The script `code/01_requirements.R` sets up all of this for you. 

Some users have reported problems with the R-package `groundhog`. As a temporary solution, we have therefore modified the `code/01_requirements.R` such that there is one variable named `using_groundhog`. If this is set to any other value than `yes`, the script will not use `groundhog` but instead simple install and load packages using a simple function (defined in `code/fun_def_h_load.R`) that checks if the package is installed, installs if not and then loads. The versions used by the authors will still be retreviable from the article appendix, but the script `code/01_requirements.R` will not load the specfic package versions if `using_groundhog` is set to anything other than `yes`.

The working directory should be `code`. The output folder will also be located in this directory.

The project relies on external data. These can be fetched from online sources either via scripts in the project or via the user clicking through web-pages. The data from from UD (v2.14), Grambank (v1), Glottolog (v5.0) and the Google project url-nlp (git commit ref=`e2adf5c9e2af5108d7e5d2a920ce9936d9867cc2`). These are the scripts that fetch the data:

 ```
 code/02_get_glottolog_language_table.R
 code/02_get_grambank_data.R
 code/02_google_pop.R
 code/02_get_UD.R
 ```
 
 websites
 * `Glottolog 5.0` https://zenodo.org/records/10804582 or https://github.com/glottolog/glottolog-cldf/tree/v5.0
 * `Grambank v1.0` https://zenodo.org/records/7740140
 * `google-research/url-nlp` https://github.com/google-research/url-nlp/tree/e2adf5c9e2af5108d7e5d2a920ce9936d9867cc2
 * `UD v2.14` https://lindat.mff.cuni.cz/repository/xmlui/handle/11234/1-5502#show-files
    - The downloaded UD file lindat from  must be unzipped twice: unzipping the initial file produces three further compressed files, of which you should unzip `ud-treebanks-v2.14.tgz`. This in turn produces 283 directories, one for each treebank, with names like "UD_Abaza-ATB" and "UD_English-EWT". All of these should be copied into `data/ud-treebanks-v2.14/`.
    
    Please note that the Glottolog, Grambank and google-research/url-nlp's data is further wrangled in the scripts above (ValueTable and LanguageTable are combined, dialects are merged etc). Therefore, we recommend executing the scripts for fetching and wrangling.
 
## Overview of scripts
All scripts are found in the directory `code`, which should also be set as the working directory for executing the code. Below is a brief description of the scripts organised by steps in the analysis workflow. We expect that you are working within one R-session, be that via a terminal or Rstudio, and start each session by executing ` code/01_requirements.R` so that all packages are set up. You can also run all the necessary code by sourcing the script `00_run_all.R`.

 ```
 #setting up packages, output directories etc
 code/01_requirements.R
 ```
 ```
 #fetching external data (non-UD)
 code/02_get_glottolog_language_table.R
 code/02_get_grambank_data.R
 code/02_google_pop.R
 ```

 ```
 #fetching UD, reading in the conllu-formatted files with udpipe::udpipe_read_conllu, removing tokens with upos=X|PUNCT|SYM and combining them into tsv-files (one per dataset)
 code/02_get_UD.R
 code/02_collapse_UD_dirs.R
 ```
 ```
 #define a function that calculates the metrics and writes to file
 code/03_process_data_per_UD_proj.R

# the execution of the function defined in code/03_process_data_per_UD_proj.R to get all possible permutations is:
process_data_per_UD_proj(directory = "output", agg_level = "upos", core_features = "core_features_only")
process_data_per_UD_proj(directory = "output", agg_level = "lemma", core_features = "core_features_only")
process_data_per_UD_proj(directory = "output", agg_level = "upos", core_features = "all_features")
process_data_per_UD_proj(directory = "output", agg_level = "lemma", core_features = "all_features")
 ```

 ```
 #stack summaried information and combine it correctly for plotting
 code/03_stack_summaries.R
 ```

 ```
 #plotting
 code/04_plot_SPLOM.R
 code/04_maps.R
 ```

# Metrics
For detail on the calculation of the metrics, please see the script `code/03_process_data_per_UD_proj.R`. This is the "meat" of the project, this is where the morphological features are split and pruned if necessary, "dummy"-features are inserted, surprisal is calculated etc. It is a relatively complex script which defines a function that runs through all of the UD-datasets. It takes three arguments, directory (where it expects there to be a folder called `processed_data` that is produced by `code/02_collapse_UD_dirs.R`), agg_level (wether the aggregation of the analysis based on upos or lemma) and core_features (wether it is pruning to only "core" features or considering all feature categories which are found). In `code/00_run_all.R` we run this function four times, varying the last two binary arguments so that we get all the combinations of metrics that we are after. The code in  `code/03_process_data_per_UD_proj.R` matches the steps described in the article sections "Detailed technical procedure" and "Additional metrics". This function produces a rich output of information per token and (mean) summaries. Unfortunately, the token-level information is too large for plotting. Instead, we use `code/03_stack_summaries.R` to stack the summaries that are produced for each dataset on each function call and correctly combine them into one table which is then written to `code/output/all_summaries_stacked.tsv`. This table is then read into plotting scripts.

# Tests
 Unit tests for `03_process_data_per_UD_proj.R` can be found in `tests/test_03_process_data_per_UD_proj.R`.
 These check the calculation of key values for test data defined within the test script.


# Output folder details

+ `processed_data`: Data processed by steps earlier than `03_process_data_per_UD_proj.R`, and used by that script to generate further output files.
+ `summarised`: Summary data at the level of the whole dataset (e.g. number of types, number of tokens, ratios and surprisals)
+ `surprisal_per_feat`: counts, proportions and sum of surprisals for individual feature values
+ `surprisal_per_feat_lookup`: counts, proportions and surprisals for individual feature values
+ `surprisal_per_featstring`: counts, proportions and surprisals for full feature strings for each token (where the counts and proportions are determined per `agg_level`, either UPOS, lemma or token)
+ `surprisal_per_featstring_lookup`: counts, proportions and surprisals per feature string, per `agg_level` (UPOS, lemma or token)
+ `surprisal_per_token`: counts, proportions and surprisals for each token regardless of morphological features. Ignores UPOS, so "marks" (English verb) and "marks" (English plural noun) would be counted as two instances of the same token.
+ `TTR`: Type-token ratios of individual tokens