library(dplyr, lib.loc = "../utility/packages/")
library(reshape2, lib.loc = "../utility/packages/")
library(readr, lib.loc = "../utility/packages/")
library(tidyr, lib.loc = "../utility/packages/")

source("../utility/SH_misc/stack_tsvs.R")

fns <- list.files(path = "output/summarised/", pattern = "agg_level.*.tsv", full.names = T)

all <- stack_tsvs(fns = fns) 

custom_metrics_df_4_ways <- all %>% 
  dplyr::select(dir, agg_level, core_features,
    "sum_surprisal_morph_split_mean"     ,
 "surprisal_per_morph_featstring_mean" ) %>% 
  reshape2::melt(id.vars = c("dir", "agg_level", "core_features")) %>%
  tidyr::unite(variable, agg_level, core_features, col = "variable") %>% 
  reshape2::dcast(dir ~ variable, value.var = "value")

metrics_df_2_ways <- all %>% 
  dplyr::select(dir, core_features,
"n_feats_per_token_mean", "n_feat_cats" ) %>% 
  reshape2::melt(id.vars = c("dir", "core_features")) %>%
  tidyr::unite(variable, core_features, col = "variable", remove = T) %>% 
  dplyr::distinct() %>% 
  reshape2::dcast(dir ~ variable, value.var = "value")

df <- all %>% 
  dplyr::select(dir, "n_types", "n_tokens" , "n_sentences" ,"TTR" ,    "LTR"   , "suprisal_token_mean" ) %>% 
  dplyr::distinct() %>% 
  dplyr::full_join(custom_metrics_df_4_ways, by = "dir") %>% 
  dplyr::full_join(metrics_df_2_ways, by = "dir")
  
df %>% 
  readr::write_tsv("output/all_summaries_stacked.tsv", na = "")

