# Fix libPaths to our local package directory
.libPaths("../utility/packages/")

library(dplyr, lib.loc = "../utility/packages/")
library(magrittr, lib.loc = "../utility/packages/")
library(readr, lib.loc = "../utility/packages/")

##################################

UD_langs <- readr::read_tsv("../data/UD_languages.tsv", show_col_types = F) %>% 
  dplyr::filter(is.na(multilingual_exclude)) %>% 
  dplyr::distinct(dir, glottocode)

mfh <- readr::read_tsv("output/results/mfh_stacked.tsv", show_col_types = FALSE) %>% 
  dplyr::rename( n_total_rows_mfh = n_total_rows, 
                 n_total_rows_filtered_mfh= n_total_rows_filtered)

df_grambank_metrics <- readr::read_tsv("output/processed_data/grambank_theo_scores.tsv", show_col_types = F) %>% 
  dplyr::rename(glottocode = Language_ID) 

df <- readr::read_tsv(file = "output/all_summaries_stacked.tsv", show_col_types = F) %>% 
  dplyr::full_join(mfh, by = "dir") %>% 
  dplyr::inner_join(UD_langs, by = "dir") %>% 
  dplyr::left_join(df_grambank_metrics, by = "glottocode") 

# with each calculating run-through, we count number of feature categories (Tense, Def etc) in the entire dataset and per token. These should be exactly the same regardless if the agg_level is upos or lemma, but should differ depending on if we've trimmed to core_features or not. This is just a reality check to check that all is as expected
if(sum(df$n_feat_cats_lemma_all_features == df$n_feat_cats_upos_all_features) != nrow(df)){
  stop("n_feat_cats_lemma_all_features are not the same as n_feat_cats_upos_all_features.")  
}

if(
  sum(df$n_feat_cats_lemma_core_features_only == df$n_feat_cats_upos_core_features_only) != nrow(df)){
  stop("n_feat_cats_lemma_core_features_only are not the same as n_feat_cats_upos_core_features_only.")  
}

if(
  sum(df$n_feat_cats_lemma_core_features_only == df$n_feat_cats_upos_core_features_only) != nrow(df)){
  stop("n_feat_cats_lemma_core_features_only are not the same as n_feat_cats_upos_core_features_only.")  
} 

if(
  sum(df$n_feats_per_token_mean_upos_all_features == df$n_feats_per_token_mean_lemma_all_features) != nrow(df)){
  stop("n_feats_per_token_mean_upos_all_features are not the same as n_feats_per_token_mean_lemma_all_features.")  
} 

if(
  sum(df$n_feats_per_token_mean_upos_core_features_only == df$n_feats_per_token_mean_lemma_core_features_only) != nrow(df)){
  stop("n_feats_per_token_mean_upos_core_features_only are not the same as n_feats_per_token_mean_lemma_core_features_only.")  
} 

#If no errors were thrown, we might as well just keep on of these columns instead of both in each pair
df <- df %>% 
  dplyr::mutate(n_feat_cats_core_features_only = n_feat_cats_lemma_core_features_only) %>% 
  dplyr::select(-n_feat_cats_lemma_core_features_only, -n_feat_cats_upos_core_features_only) %>% 
  dplyr::mutate(n_feat_cats_all_features = n_feat_cats_lemma_all_features) %>% 
  dplyr::select(-n_feat_cats_upos_all_features, -n_feat_cats_lemma_all_features) %>% 
  dplyr::mutate(n_feats_per_token_mean_core_features_only = n_feats_per_token_mean_lemma_core_features_only) %>% 
  dplyr::select(-n_feats_per_token_mean_lemma_core_features_only, -n_feats_per_token_mean_upos_core_features_only) %>% 
  dplyr::mutate(n_feats_per_token_mean_all_features = n_feats_per_token_mean_lemma_all_features) %>% 
  dplyr::select(-n_feats_per_token_mean_lemma_all_features, -n_feats_per_token_mean_upos_all_features) 

#some datasets don't have the tokens in them
df <- df %>% 
  dplyr::mutate(TTR = ifelse(n_types <=2, NA, TTR)) %>% #if there are fewer than 2 types in the data, set number of types, TTR, LTR and surprisal of token to missing as this indicates that it is not reliable
  dplyr::mutate(LTR = ifelse(n_types <=2, NA, LTR))  %>% 
  dplyr::mutate(suprisal_token_mean = ifelse(n_types <=2, NA, suprisal_token_mean))  %>% 
  dplyr::mutate(n_types = ifelse(n_types <=2, NA, n_types))  %>% 
  dplyr::mutate(mfh = ifelse(n_total_rows_filtered_mfh == 0, NA, mfh))   %>% #for C&R's mfh measurement, because of the dataset we use as input sometimes the number of tokens the score is based on is in fact 0. In those cases, mfh will also be 0 but it is not a meaningful value because it is based on 0 tokens. We exclude these.
  dplyr::filter(n_feat_cats_all_features >= 2)

#noting ranks
df$mfh_rank <- base::rank(df$mfh, na.last = "keep") 

df$sum_surprisal_morph_split_mean_upos_all_features_rank <- base::rank(df$sum_surprisal_morph_split_mean_upos_all_features, na.last = "keep")

df$surprisal_per_morph_featstring_mean_lemma_core_features_only_rank <- base::rank(df$surprisal_per_morph_featstring_mean_lemma_core_features_only, na.last = "keep")

df$Fusion_rank <- base::rank(df$Fusion, na.last = "keep")
df$Informativity_rank <- base::rank(df$Informativity, na.last = "keep")

df %>% 
  readr::write_tsv("output/results/all_results.tsv", na = "")
