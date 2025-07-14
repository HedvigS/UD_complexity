# Using annotated cross-linguistic corpora to explore morphological information

R project for exploring informational load of morphology in different langauges using Universal Depedencies.

## Project overview
We are using the Universal Dependencies (UD) dataset to explore different facets of information in morphology.
We use morphology features annotated in UD to calculate information-theoretic metrics across datasets in different languages, and compare these to related measures such as grammatical features from [Grambank](https://grambank.clld.org/) and estimated population sizes from [Google](https://github.com/google-research/url-nlp/tree/e2adf5c9e2af5108d7e5d2a920ce9936d9867cc2/linguameta).

## Install
R's packaging conventions make it difficult to consistently install specific requirements across platforms.
We have tested the following installation procedure on several MacOS and Windows machines; however, complex interdependencies make the infrastructure somewhat fragile.
Following these instructions *should* be sufficient in *most* cases, using R version 4.4.3 on a MacOS or Windows machine.
If installation fails for you, required packages are listed in `01_requirements.R` and `requirements.tsv`.
Another method of installing them (e.g. directly via binaries from [CRAN](https://cran.r-project.org/)) may work.

### MacOS

1. Download this repository as a ZIP file and extract it.
2. Install R 4.4.3.
3. ??? Install Rtools 4.4.
4. If running from a terminal:
    1. ??? ensure Rscript is on PATH
    2. Open a terminal in the `code/` directory.
    3. Run `Rscript 01_requirements.R`.
5. If running from RStudio:
    1. Ensure the working directory is `code/`.
    2. Run `source("01_requirements.R")`.

### Windows

1. Download this repository as a ZIP file and extract it.
2. Install [R 4.4.3](https://cran.r-project.org/bin/windows/base/old/4.4.3/).
3. Install [Rtools 4.4](https://cran.r-project.org/bin/windows/Rtools/).
4. If running from a terminal:
    1. Make sure `Rscript` from the 4.4.3 version of R is available on your `PATH`. See for example [this guide](https://www.architectryan.com/2018/03/17/add-to-the-path-on-windows-10/).
    2. Open a terminal in the `code/` directory.
    3. Run `Rscript 01_requirements.R`.
5. If running from RStudio:
    1. Ensure the working directory is `code/`.
    2. Run `source("01_requirements.R")`.

R will then install the required packages.
On Windows this can take a long time because installing specific versions of packages requires compiling them from source.

### Installation: technical details
Required packages and versions are listed in `requirements.tsv`, in the order in which they should be installed and loaded.
Special requirements have been provided as binaries in `utility/packages_binary/` and are installed by `01_requirements.R`.

We install all packages into a custom directory `utility/packages/`.
R's virtual environment system `renv` does not fully shield the environment from global packages, which can lead to dependency conflicts.
We thus avoid `renv` and set the library path in all our scripts exclusively to the custom directory.
This ensures that the versions of the packages we use are controlled by the installation script and the requirements file.

## Run

### Run all
In the terminal, make sure the working directory is `code/` and then run:
```
Rscript 00_run_all.R
```

In Rstudio, make sure the working directory is `code/` and run:
```
source("00_run_all.R")
```

For comprehensiveness this script includes the installation script `01_requirements.R`, in case required packages have not yet been installed.
We encourage the user to run `01_requirements.R` first, to ensure all packages install correctly.

See the section **Output** below for details on where and how results are stored.

### Run scripts individually

To run the analysis scripts individually, they **must** be run in the order they appear in `00_run_all.R`.
Scripts at each step depend on outputs produced by scripts at the previous step.
The steps are:
1. Installation
2. Obtain datasets
3. Calculate metrics on datasets
4. Summarise and plot

The correct order of scripts and function calls as listed in `00_run_all.R` is:
```
source("01_requirements.R")

source("02_get_glottolog_language_table.R")
source("02_get_grambank_data.R")
source("02_google_pop.R")

source("02_get_UD.R")
source("02_collapse_UD_dirs.R")

source("03_process_data_per_UD_proj.R")
process_data_per_UD_proj(directory = "output", agg_level = "upos", core_features = "core_features_only")
process_data_per_UD_proj(directory = "output", agg_level = "lemma", core_features = "core_features_only")
process_data_per_UD_proj(directory = "output", agg_level = "upos", core_features = "all_features")
process_data_per_UD_proj(directory = "output", agg_level = "lemma", core_features = "all_features")

source("04_stack_summaries.R")
source("04_plot_SPLOM.R")
```

The following subsections break down and explain each step.

#### 1. Installation

See section **Install** above.

#### 2. Obtain datasets

The project relies on external data.
The following scripts fetch necessary data from online resources:
```
02_get_glottolog_language_table.R
02_get_grambank_data.R
02_google_pop.R
02_get_UD.R
```

As a fallback, each of these scripts can be replaced with manual data acquisition:
+ `Glottolog 5.0` https://zenodo.org/records/10804582 or https://github.com/glottolog/glottolog-cldf/tree/v5.0
    + TODO explain how to download and where to put it
+ `Grambank v1.0` https://zenodo.org/records/7740140
    + TODO explain how to download and where to put it
+ `google-research/url-nlp` https://github.com/google-research/url-nlp/tree/e2adf5c9e2af5108d7e5d2a920ce9936d9867cc2
    + TODO explain how to download and where to put it
+ `UD v2.14` https://lindat.mff.cuni.cz/repository/items/e22c28af-deba-4411-a49d-d7a99e28d205/download/zip
    + The downloaded UD must be unzipped twice: unzipping the initial file produces three further compressed files, of which you should unzip `ud-treebanks-v2.14.tgz`. This in turn produces 283 directories, one for each treebank, with names like "UD_Abaza-ATB" and "UD_English-EWT". All of these should be copied into `data/ud-treebanks-v2.14/`.

The UD data must then be preprocessed (to remove tokens such as `X`, `PUNCT` and `SYM` that are not part of the analysis; see the manuscript for details) and reformatted (into `.tsv` files):
```
02_collapse_UD_dirs.R
```

#### 3. Calculate metrics on datasets

The method to calculate metrics on each dataset is in:

```
03_process_data_per_UD_proj.R
```

To actually calculate the metrics, call the method defined in that script with the desired parameters.
In the manuscript we report the results of running this method four times, with the following parameter combinations:
```
process_data_per_UD_proj(directory = "output", agg_level = "upos", core_features = "core_features_only")
process_data_per_UD_proj(directory = "output", agg_level = "lemma", core_features = "core_features_only")
process_data_per_UD_proj(directory = "output", agg_level = "upos", core_features = "all_features")
process_data_per_UD_proj(directory = "output", agg_level = "lemma", core_features = "all_features")
```

See section **Metrics** for details of this function.

#### 4. Summarise and plot

To summarise the results and generate the plots found in the manuscript, use the following scripts:
```
04_stack_summaries.R
04_plot_SPLOM.R
```

## Output
The output folders are structured as follows:
+ `processed_data`: Data processed by steps earlier than `03_process_data_per_UD_proj.R`, and used by that script to generate further output files.
+ `summarised`: Summary data at the level of the whole dataset (e.g. number of types, number of tokens, ratios and surprisals)
+ `surprisal_per_feat`: counts, proportions and sum of surprisals for individual feature values
+ `surprisal_per_feat_lookup`: counts, proportions and surprisals for individual feature values
+ `surprisal_per_featstring`: counts, proportions and surprisals for full feature strings for each token (where the counts and proportions are determined per `agg_level`, either UPOS, lemma or token)
+ `surprisal_per_featstring_lookup`: counts, proportions and surprisals per feature string, per `agg_level` (UPOS, lemma or token)
+ `surprisal_per_token`: counts, proportions and surprisals for each token regardless of morphological features. Ignores UPOS, so "marks" (English verb) and "marks" (English plural noun) would be counted as two instances of the same token.
+ `TTR`: Type-token ratios of individual tokens

## Metrics

We describe our metrics in the manuscript under the headings "Detailed technical procedure" and "Additional metrics".
For detail on the calculation of the metrics, please see the script `03_process_data_per_UD_proj.R`.
This is the "meat" of the project, where morphological features are split and pruned if necessary, "dummy"-features are inserted, and surprisal is calculated. 
It is a relatively complex script which defines a function that runs through all of the UD-datasets. 
It takes three arguments:
+ `directory`: a path to a directory in which there is a folder called `processed_data` that is produced by `02_collapse_UD_dirs.R`.
+ `agg_level`: must be `"upos"` or `"lemma"`.
+ `core_features`: a boolean. If `TRUE`, uses only the "core" UD features. See the manuscript for details.

In `00_run_all.R` we run this function four times, varying the last two binary arguments so that we get all the combinations of metrics that we are after. 
The code in  `03_process_data_per_UD_proj.R` matches the steps described in the article sections "Detailed technical procedure" and "Additional metrics". 
This function produces a rich output of information per token and (mean) summaries.

As the token-level information is too large for plotting, we use `04_stack_summaries.R` to stack the summaries that are produced for each dataset on each function call.
These are combined into one table which is then written to `output/all_summaries_stacked.tsv`, which is then used by the plotting script `04_plot_SPLOM.R`.

## Test

We provide a script that tests the method of calculating informational metrics using dummy data.
To run the tests, navigate to the directory `tests/` and call `Rscript test_03_process_data_per_UD_proj.R` (from the terminal) or `source("test_03_process_data_per_UD_proj")` (from Rstudio).
Because the tests rely on fewer packages, whose dependencies are not version-specific, these are installed into the default package location at runtime (see `requirements_tests.R`).
