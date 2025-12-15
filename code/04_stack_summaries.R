library(dplyr, lib.loc = "../utility/packages/")
library(reshape2, lib.loc = "../utility/packages/")
library(readr, lib.loc = "../utility/packages/")
library(tidyr, lib.loc = "../utility/packages/")
library(magrittr, lib.loc = "../utility/packages/")

source("../utility/SH_misc/stack_tsvs.R")

fns1 <- list.files(path = "output/results/ud-treebanks-v2.14_results/agg_level_lemma_all_features/summarised/", 
                  pattern = ".tsv", full.names = T)
fns2 <- list.files(path = "output/results/ud-treebanks-v2.14_results/agg_level_lemma_core_features_only/summarised/", 
                  pattern = ".tsv", full.names = T)
fns3 <- list.files(path = "output/results/ud-treebanks-v2.14_results/agg_level_upos_all_features/summarised/", 
                  pattern = ".tsv", full.names = T)
fns4 <- list.files(path = "output/results/ud-treebanks-v2.14_results/agg_level_upos_core_features_only/summarised/", 
                  pattern = ".tsv", full.names = T)

fns <- c(fns1, fns2, fns3, fns4)

all <- stack_tsvs(fns = fns, verbose = F) 

custom_metrics_df_4_ways <- all %>% 
  dplyr::select(dir, agg_level, core_features,
    "sum_surprisal_morph_split_mean"     ,
 "surprisal_per_morph_featstring_mean" ) %>% 
  reshape2::melt(id.vars = c("dir", "agg_level", "core_features")) %>%
  tidyr::unite(variable, agg_level, core_features, col = "cast_variable", sep = "_", remove = TRUE) %>%
  reshape2::dcast(dir ~ cast_variable, value.var = "value")

metrics_df_2_ways <- all %>% 
  dplyr::select(dir, agg_level, core_features,
"n_feats_per_token_mean", "n_feat_cats" ) %>% 
  reshape2::melt(id.vars = c("dir", "agg_level", "core_features")) %>%
  tidyr::unite(variable, agg_level, core_features, col = "cast_variable", remove = TRUE) %>% 
  reshape2::dcast(dir ~ cast_variable, value.var = "value")

df <- all %>% 
  dplyr::select(dir, "n_types", "n_tokens" , "n_sentences" ,"TTR" ,    "LTR"   , "suprisal_token_mean" ) %>% 
  dplyr::distinct() %>% 
  dplyr::full_join(custom_metrics_df_4_ways, by = "dir") %>% 
  dplyr::full_join(metrics_df_2_ways, by = "dir")
  
df %>% 
  readr::write_tsv("output/all_summaries_stacked.tsv", na = "")