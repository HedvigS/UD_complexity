R-code project for exploring informational load of morphology in different langauges using Universal Depedencies.

# Data
## Universal Dependencies
Fetch the treebanks files for ud-treebanks-v2.14: <https://lindat.mff.cuni.cz/repository/xmlui/handle/11234/1-5502>. place these in data/ud-treebanks-v2.14/. The directories have names like "UD_Abaza-ATB" and "UD_English-EWT" and inside there should be files that end with.conllu.

## Language populations
Google NLP-reserach team: <https://raw.githubusercontent.com/google-research/url-nlp/refs/heads/main/linguameta/linguameta.tsv>

## Grambank v1
<https://zenodo.org/records/7844558>
<https://zenodo.org/records/7740140/files/g>

## Output folder details

+ `counts`: summary values per sentence
+ `processed_data`: Data processed by steps earlier than `02_process_data_per_UD_proj.R`, and used by that script to generate further output files.
+ `surprisal_per_feat`: counts, proportions and sum of surprisals for individual feature values
+ `surprisal_per_feat_lookup`: counts, proportions and surprisals for individual feature values
+ `surprisal_per_featstring`: counts, proportions and surprisals for full feature strings for each token (where the counts and proportions are determined per `agg_level`, either UPOS, lemma or token)
+ `surprisal_per_featstring_lookup`: counts, proportions and surprisals per feature string, per `agg_level` (UPOS, lemma or token)
+ `surprisal_per_token`: counts, proportions and surprisals for each token regardless of morphological features. Ignores UPOS, so "marks" (English verb) and "marks" (English plural noun) would be counted as two instances of the same token.
+ `surprisal_per_token_sum_sentence`: The surprisals from `surprisal_per_token` summed at the level of "sentence_id"
+ `TTR`: Type-token ratios of individual tokens
