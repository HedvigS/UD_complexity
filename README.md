R-code project for exploring informational load of morphology in different langauges using Universal Depedencies.

# Data
## Universal Dependencies
To run the scripts in this repository you will need to download the raw data from [version 2.14 of the Universal Dependencies database](https://lindat.mff.cuni.cz/repository/xmlui/handle/11234/1-5502/allzip).
The downloaded file must be unzipped twice: unzipping the initial file produces three further compressed files, of which you should unzip `ud-treebanks-v2.14.tgz`.
This in turn produces 283 directories, one for each treebank, with names like "UD_Abaza-ATB" and "UD_English-EWT".
All of these should be copied into `UD_complexity/data/ud-treebanks-v2.14/`.

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
