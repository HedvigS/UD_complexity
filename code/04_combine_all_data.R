library(dplyr, lib.loc = "../utility/packages/")
library(magrittr, lib.loc = "../utility/packages/")
library(readr, lib.loc = "../utility/packages/")
library(stringr, lib.loc = "../utility/packages/")

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
  dplyr::mutate(TTR = ifelse(n_types <=2, NA, TTR)) %>% 
  dplyr::mutate(LTR = ifelse(n_types <=2, NA, LTR))  %>% 
  dplyr::mutate(suprisal_token_mean = ifelse(n_types <=2, NA, suprisal_token_mean))  %>% 
  dplyr::mutate(n_types = ifelse(n_types <=2, NA, n_types))  %>% 
  dplyr::filter(n_feat_cats_all_features >= 2)

df %>% 
  readr::write_tsv("output/results/all_results.tsv", na = "")