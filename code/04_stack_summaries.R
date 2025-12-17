library(dplyr, lib.loc = "../utility/packages/")
library(reshape2, lib.loc = "../utility/packages/")
library(readr, lib.loc = "../utility/packages/")
library(tidyr, lib.loc = "../utility/packages/")
library(magrittr, lib.loc = "../utility/packages/")
library(ggplot2, lib.loc = "../utility/packages/")
library(forcats, lib.loc = "../utility/packages/")

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




fns1 <- list.files(path = "output/processed_data/ud-treebanks-v2.14_processed/agg_level_lemma_all_features/counts/", 
                   pattern = ".tsv", full.names = T)
fns2 <- list.files(path = "output/processed_data/ud-treebanks-v2.14_processed/agg_level_lemma_core_features_only/counts/", 
                   pattern = ".tsv", full.names = T)
fns3 <- list.files(path = "output/processed_data/ud-treebanks-v2.14_processed/agg_level_upos_all_features/counts/", 
                   pattern = ".tsv", full.names = T)
fns4 <- list.files(path = "output/processed_data/ud-treebanks-v2.14_processed/agg_level_upos_core_features_only/counts/", 
                   pattern = ".tsv", full.names = T)

fns <- c(fns1, fns2, fns3, fns4)

all_counts <- stack_tsvs(fns = fns, verbose = F) 

all_counts$dir <- forcats::fct_reorder(all_counts$dir, all_counts$n_tokens_in_input)

all_counts <- all_counts %>% 
  dplyr::mutate(diff = n_tokens_in_input - n_tokens_output)

col_pal <- c("blue", "purple", "orange", "salmon", "pink")

p <- all_counts %>% 
  dplyr::filter(diff > 6000) %>% 
  dplyr::select(dir, n_tokens_in_input, n_tokens_empty_dropped, n_tokens_only_subwords, n_tokens_multiwords_resolved) %>% 
  reshape2::melt(id.vars = "dir") %>% 
  ggplot2::ggplot() +
  ggplot2::geom_point(mapping = ggplot2::aes(x = dir, y = value, fill = variable, color = variable),shape = 6, stroke = 1, alpha = 0.4) +
  ggplot2::scale_fill_manual(values = col_pal) +
  ggplot2::scale_color_manual(values = col_pal) +
#  ggplot2::scale_x_discrete(
#    breaks = function(x) x[seq(1, length(x), by = 5)]  ) +
  ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 60, hjust = 1))

all_counts$dir <- forcats::fct_reorder(all_counts$dir, all_counts$diff)

all_counts %>% 
  ggplot2::ggplot() +
  ggplot2::geom_bar(mapping = ggplot2::aes(x = dir, y = diff), stat = "identity")

all_counts %>% 
  ggplot2::ggplot() +
  ggplot2::geom_point(mapping = aes(x = n_tokens_in_input, y = diff))

  
all_counts$diff %>% mean()
