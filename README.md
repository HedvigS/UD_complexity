# Using annotated cross-linguistic corpora to explore morphological information

R project for exploring informational load of morphology using the Universal Dependencies data-sets of corpora from multiple languages.

## Project overview

We are using the [Universal Dependencies (UD)](https://universaldependencies.org/) data-set ([version 2.14](https://lindat.mff.cuni.cz/repository/items/e22c28af-deba-4411-a49d-d7a99e28d205)) to explore different facets of information in morphology.
We use morphology features annotated in UD to calculate information-theoretic metrics across data-sets in different languages, and compare these to related measures such as grammatical features from [Grambank](https://grambank.clld.org/) and Çöltekin & Rama's 2023 mfh-measure.

## Installing necessary prerequisites

Unfortunately, R's packaging conventions make it difficult to consistently install specific requirements across platforms.
We have tested the following installation procedures on several MacOS and Windows machines; however, complex inter-dependencies and platform-specific procedure make the infrastructure somewhat fragile.
Following these instructions *should* be sufficient in *most* cases, using `R` version 4.5.0 on a MacOS or Windows machine.
If the installation guides fail for you, required packages are listed in the following section.
Another method of installing them (e.g. directly via binaries from [CRAN](https://cran.r-project.org/)) may work if you encounter issues.

### Versioning

We have documented the versions of the software used (`R`, `Rtools` and R packages) and data (Universal Dependencies, Grambank and Glottolog) in this README.md document and in the `R` scripts of this project.
For perfect replication, please use the versions specified.
For the software, we anticipate that related versions will generally be compatible with the analysis; however, this cannot be guaranteed.
Likewise, we expect that future versions of the data-sets yield very similar outcomes as they are not expected to change dramatically in content, but this can also not be guaranteeed.

### Required software

-   R version 4.5.0. We expect other versions of R 4 to work, but for perfect replication the version we used was 4.5.0.
-   (For some Windows users it may be necessary to also install Rtools 45)
-   R packages: see `requirements.tsv`
-   Python version 3.10-3.13.

#### R versions and packages

All required R packages are installed for the user with R the script `code/01_requirements_install.R` which features some accommodations to platform-specific situations.
All required R packages, with the exception of `data.table` and `Matrix`, are listed in the file `requirements.tsv` in a particular order that is optimally constructed in terms of package depencies. 
The other packages need to be installed from binary files (provided in `utility/packages_binary/`), this is specified in `code/01_requirements_install.R`.

We install all packages into a custom directory `utility/packages/`.
R's virtual environment system `renv` does not fully shield the environment from global packages, which can lead to dependency conflicts.
We thus avoid `renv` and set the library path in all our scripts exclusively to the custom directory when installing and loading packages.
This ensures that the versions of the packages used througout the project are correct.
If `code/01_requirements_install.R` fails for you in the installation guides below and you install packages by another route, please make sure to set the library directory to `utility/packages/` (i.e. create dir and set the argument `lib` in `install.packages()` to `utility/packages/`), otherwise the loading of packages in the subsequent scripts will break.
If `code/01_requirements_install.R` fails but you succeed in installing packages by another route, please run `code/01_requirements_dirs.R` in order to set-up folders (this is otherwise called by `code/00_run_all.R`).

#### Python versions and packages

We have tested on python version 3.10 on Windows and TODO on MacOS.
We expect other recent versions of python to work similarly.
Earlier versions of python are unlikely to work due to incompatibility with the package `polars`.
See below for instructions on installing the python virtual environment and package requirements, all of which are listed in `pyproject.toml`.

### MacOS software installation guide

1.  Clone this Git repository or [download this repository as a ZIP file and extract it](https://docs.github.com/en/repositories/working-with-files/using-files/downloading-source-code-archives#downloading-source-code-archives-from-the-repository-view).
2.  Install `R` 4.5.0. [macos arm64](https://mirror.accum.se/mirror/CRAN/bin/macosx/big-sur-arm64/base/R-4.5.0-arm64.pkg) [macos x86_64](https://cran.r-project.org/bin/macosx/big-sur-x86_64/base/R-4.5.0-x86_64.pkg)\
3. Install python version 3.10-3.13, create a virtual environment, and install the project:
    1. **Install Python**: Python can be downloaded from the [official website](https://www.python.org/downloads/macos/) or installed directly via your system's package manager.
    2. **Create virtual environment**: From the top-level directory `UD_complexity` create a virtual environment with `python3 -m venv .venv_ud_complexity`.
    3. **Activate virtual environment**: Run `source .venv_ud_complexity/bin/activate`
    4. **Upgrade pip**: Run `python -m pip install --upgrade pip`
    5. **Install project**: Run `pip install -e .` to install the project as an editable package.
    6. **Run tests**: Run `pytest` to run basic checks ensuring the python scripts run as expected.
4.  If running from terminal:
    1.  ensure `Rscript` is in your `$PATH` environment variable (i.e run `which Rscript` and confirm that you don't get `command not found`. If `Rscript` command is not found, please add the relevant file-path in your `$PATH` environment variable in your shell profile, e.g. `.zshrc`, `.profile` or `.bash_profile` depending on your machine)
    2.  navigate to the `code/` directory inside this project.
    3.  Run `Rscript 01_requirements_install.R`.
5.  If running from RStudio:
    1.  Ensure the working directory is `code/` directory inside this project.
    2.  Run `source("01_requirements_install.R")` in the Rstudio console.

MacOS users may experience issues due to incompatabile/non-existent versions of non-`R` software such as `Xcode`, `gettext`, `clang/clang++` or `V8`. 
We have tried our best to mitigate this by supplying the user with binary versions of certain packages in `utility/packages_binary/` and setting up `code/01_requirements_install.R` to install from there instead of compiling from source. 
If problems pesists, users are recommended to seek support for installing/updating this infrastrucutre.

### Windows software installation guide

1.  Clone this Git repository or [download this repository as a ZIP file and extract it](https://docs.github.com/en/repositories/working-with-files/using-files/downloading-source-code-archives#downloading-source-code-archives-from-the-repository-view).
2.  Install [R 4.5.0](https://cran.r-project.org/bin/windows/base/old/4.5.0/).
3. Install python version 3.10-3.13, create a virtual environment, and install the project:
    1. **Install Python**: Python can be downloaded from the [official website](https://www.python.org/downloads/windows/) or installed directly via your system's package manager.
    2. **Create virtual environment**: From the top-level directory `UD_complexity` create a virtual environment with `python -m venv .venv_ud_complexity`.
    3. **Activate virtual environment**: Run `.venv_ud_complexity/Scripts/activate`
    4. **Upgrade pip**: Run `python.exe -m pip install --upgrade pip`
    5. **Install project**: Run `pip install -e .` to install the project as an editable package.
    6. **Run tests**: Run `pytest` to run basic checks ensuring the python scripts run as expected.
4.  If running from a terminal:
    1.  Make sure `Rscript` from the 4.5.0 version of R is available on your `PATH`. See for example [this guide](https://www.architectryan.com/2018/03/17/add-to-the-path-on-windows-10/).
    2.  Open a terminal in the `code/` directory.
    3.  Run `Rscript 01_requirements_install.R`.
5.  If running from RStudio:
    1.  Ensure the working directory is `code/`.
    2.  Run `source("01_requirements_install.R")`.

R will then install the required packages. On Windows this can take a long time because installing specific versions of packages requires compiling them from source.

5.  When executing `code/01_requirements_install.R`, if the process terminates due to not finding `Rtools`, please install `Rtools` version 45 separately outside of R and then return to the guide above.
    -   `Rtools`: <https://cran.r-project.org/bin/windows/Rtools/>
    -   `Rtools` installation instructions: <https://ucdavisdatalab.github.io/install_guides/r-and-r-tools.html#r-tools>

## Run

Be aware that running the entire pipeline end-to-end will create results in the `output/` directory totalling around **70GB**.

### Run all

In the terminal, make sure the working directory is `code/` and then run:

```         
Rscript 00_run_all.R
```

In Rstudio, make sure the working directory is `code/` and run:

```         
source("00_run_all.R")
```

For comprehensiveness this script includes the installation script `01_requirements_install.R`, in case required packages have not yet been installed. 
We encourage the user to run `01_requirements_install.R` first, to ensure all packages install correctly. 
If the packages are already installed in the correct location (`utility/packages/`) and with the correct version, the script will not install the package again.

See the section **Output** below for details on where and how results are stored.

### Run scripts individually

To run the analysis scripts individually, they **must** be run in the order they appear in `00_run_all.R`. Scripts at each step depend on outputs produced by scripts at the previous step. The steps are:

1.  R package installation (requires internet)
2.  Obtain data-sets (requires internet)
3.  Calculate metrics on data-sets
4.  Summarise and plot

The correct order of scripts and function calls can be found in `00_run_all.R`.
The following subsections break down and explain each step.

#### 1. Installation and set-up

```         
01_requirements_install.R
01_requirements_load.R
```   
For more on software installation,  see section **Installing necessary prerequisites** above.

Setting up folder structure
```         
01_requirements_dirs.R
```         

#### 2. Obtain datasets

The project relies on external data. The following scripts fetch necessary data from online resources:

```         
02_get_glottolog_language_table.R
02_get_grambank_data.R
02_google_pop.R
02_get_UD.R
```

As a fallback, each of these scripts can be replaced with manual data acquisition in case there are issues with the scripts listed above:

-   `Glottolog 5.0`. This dataset is available in identical archived form both on Zenodo and GitHub. You can fetch the data from either location.
    -   Zenodo location: <https://zenodo.org/records/10804582> - click `download`/`download all`, extract file, extract contents of file and open the directory `glottolog/glottolog-glottolog-cldf-4dbf0787/cldf`. Move the two files `languages.csv` and `values.csv` to the folder `data/glottolog` in this project.
    -   GitHub location <https://github.com/glottolog/glottolog-cldf/tree/v5.0> - Clone this Git repository or [download this repository as a ZIP file and extract it](https://docs.github.com/en/repositories/working-with-files/using-files/downloading-source-code-archives#downloading-source-code-archives-from-the-repository-view). Navigate to the directory `glottolog-cldf` and move the two files `languages.csv` and `values.csv` to the folder `data/glottolog` in this project.
    -   once the files are in place, run `02_get_glottolog_language_table.R` which derives specific tables for the analysis. The script will not re-download the content again.
-   `Grambank v1.0` This dataset is available in identical archived form both on Zenodo and GitHub. You can fetch the data from either location.
    -   Zenodo location: <https://zenodo.org/records/7740140> - click `download`/`download all`, extract file, extract contents of file and open the directory `grambank/grambank-grambank-9e0f341`. Move the folder `cldf` to `data/grambank/` in this project.
    -   Github location: <https://github.com/grambank/grambank/tree/v1.0> - Clone this Git repository or [download this repository as a ZIP file and extract it](https://docs.github.com/en/repositories/working-with-files/using-files/downloading-source-code-archives#downloading-source-code-archives-from-the-repository-view). Open the directory `grambank` and move the folder `cldf` to `data/grambank/` in this project
    -   once the files are in place, run `02_get_grambank_data.R` which derives specific tables for the analysis. The script will not re-download the content again.
-   `google-research/url-nlp commit e2adf5c9e2af5108d7e5d2a920ce9936d9867cc2`. This dataset is available on GitHub.
    -   GitHub location: <https://github.com/google-research/url-nlp/tree/e2adf5c9e2af5108d7e5d2a920ce9936d9867cc2> Clone this Git repository or [download this repository as a ZIP file and extract it](https://docs.github.com/en/repositories/working-with-files/using-files/downloading-source-code-archives#downloading-source-code-archives-from-the-repository-view). Move the file `url-nlp/linguameta/linguameta.tsv` to `data/google-research-url-nlp/` in this project.
    -   once the file is in place, run `02_google_pop.R` which derives a specific table for the analysis. The script will not re-download the content again.
-   `UD v2.14`. This dataset is available at the website of the Czech Digital Research Infrastructure for Language Technologies, Arts and Humanities (LINDAT)
    -   LINDAT location (URL triggers automatic download): <https://lindat.mff.cuni.cz/repository/items/e22c28af-deba-4411-a49d-d7a99e28d205/download/zip> - open link which triggers download of compressed file. Extract the downloaded file and then also extract the file `ud-treebanks-v2.14.tgz`. Move the directory `ud-treebanks-v2.14` to the folder `data` in the project folder. The directory `ud-treebanks-v2.14` contains 283 directories, one for each treebank, with names like "UD_Abaza-ATB" and "UD_English-EWT". These are later further processed by the script `02_collapse_UD_dirs.R` for analysis.

```         
02_collapse_UD_dirs.R
```

#### 3. Calculate metrics on datasets

We calculate mean feature entropy as defined by Çöltekin and Rama (2023), as well as several custom metrics described in the manuscript.
Mean feature entropy is calculated on all processed datasets with:

```
03_run_python.R
```

Our own metrics require further pre-processing of the data.
This preprocessing, and the calculation of the metrics themselves, occur in functions in the following script:

```         
03_process_data_per_UD_proj.R
```

To actually process the data and calculate the metrics, call the methods defined in that script with the desired parameters. 
In the manuscript we report the results of running each method four times, with the following parameter combinations:

```
# Processing
process_UD_data(input_dir = "output/processed_data/ud-treebanks-v2.14_collapsed/", 
                output_dir = "output/processed_data/ud-treebanks-v2.14_processed/", 
                agg_level = "upos",
                core_features = "core_features_only",
)
process_UD_data(input_dir = "output/processed_data/ud-treebanks-v2.14_collapsed/", 
                output_dir = "output/processed_data/ud-treebanks-v2.14_processed/", 
                agg_level = "upos",
                core_features = "core_features_only",
)
process_UD_data(input_dir = "output/processed_data/ud-treebanks-v2.14_collapsed/", 
                output_dir = "output/processed_data/ud-treebanks-v2.14_processed/", 
                agg_level = "lemma",
                core_features = "core_features_only",
)
process_UD_data(input_dir = "output/processed_data/ud-treebanks-v2.14_collapsed/", 
                output_dir = "output/processed_data/ud-treebanks-v2.14_processed/", 
                agg_level = "upos",
                core_features = "all_features",
)
process_UD_data(input_dir = "output/processed_data/ud-treebanks-v2.14_collapsed/", 
                output_dir = "output/processed_data/ud-treebanks-v2.14_processed/", 
                agg_level = "lemma", #lemma token,
                core_features = "all_features",
)

# Calculation
calculate_surprisal(input_dir = "output/processed_data/ud-treebanks-v2.14_processed/agg_level_upos_core_features_only/processed_tsv/", 
                    agg_level = "upos",
                    core_features = "core_features_only",
                    output_dir <- "output/results/ud-treebanks-v2.14_results")

calculate_surprisal(input_dir = "output/processed_data/ud-treebanks-v2.14_processed/agg_level_upos_all_features/processed_tsv/", 
                    agg_level = "upos",
                    core_features = "all_features",
                    output_dir <- "output/results/ud-treebanks-v2.14_results")

calculate_surprisal(input_dir = "output/processed_data/ud-treebanks-v2.14_processed/agg_level_lemma_core_features_only/processed_tsv/", 
                    agg_level = "lemma", 
                    core_features = "core_features_only", 
                    output_dir <- "output/results/ud-treebanks-v2.14_results")

calculate_surprisal(input_dir = "output/processed_data/ud-treebanks-v2.14_processed/agg_level_lemma_all_features/processed_tsv/", 
                    agg_level = "lemma", 
                    core_features = "all_features", 
                    output_dir <- "output/results/ud-treebanks-v2.14_results")
```

See section **Metrics** for details of the calculation function.

#### 4. Summarise and plot

To summarise the results and generate the plots found in the manuscript, use the following scripts:

```         
04_stack_summaries.R
04_combine_all_data.R
04_plot_SPLOM.R
04_maps.R
```

## Output

The output folders are structured as follows: 
+ `plots`: SPLOM plots and maps created in step 4.
+ `processed_data`: Preprocessing of UD data:
  + `ud-treebanks-v2.14_collapsed`: Treebanks after filtering with `02_collapse_UD_dirs.R`
  + `ud-treebanks-v2.14_processed`: Treebanks after preprocessing with `process_UD_data()` in `03_process_data_per_UD_proj.R`
+ `results`: Results of calculations performed by `calculate_surprisal()` in `03_process_data_per_UD_proj.R`. Subdirectories organise data as follows:
  + `summarised`: Summary data at the level of the whole data-set (e.g. number of types, number of tokens, ratios and surprisals) 
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
It is a relatively complex script which defines a function that runs through all of the UD-data-sets.
It takes three arguments: 
+ `directory`: a path to a directory in which there is a folder called `processed_data` that is produced by `02_collapse_UD_dirs.R`.
+ `agg_level`: must be `"upos"` or `"lemma"`. 
+ `core_features`: a Boolean. If `TRUE`, uses only the "core" UD features. See the manuscript for details.

In `00_run_all.R` we run this function four times, varying the last two binary arguments so that we get all the combinations of metrics that we are after.
The code in `03_process_data_per_UD_proj.R` matches the steps described in the article sections "Detailed technical procedure" and "Additional metrics".
This function produces a rich output of information per token and (mean) summaries.

As the token-level information is too large for plotting, we use `04_stack_summaries.R` to stack the summaries that are produced for each data-set on each function call.
These are combined into one table which is then written to `output/all_summaries_stacked.tsv`, which is then used by the plotting script `04_plot_SPLOM.R`.

## Test

We provide a script that tests the method of calculating informational metrics using dummy data.
To run the tests, navigate to the directory `tests/` and call `Rscript test_03_process_data_per_UD_proj.R` (from the terminal) or `source("test_03_process_data_per_UD_proj")` (from Rstudio).
Because the tests rely on fewer packages, whose dependencies are not version-specific, these are installed into the default package location at run-time (see `requirements_tests.R`).
