library(dplyr, lib.loc = "../utility/packages/")
library(ggplot2, lib.loc = "../utility/packages/")
library(magrittr, lib.loc = "../utility/packages/")
library(readr, lib.loc = "../utility/packages/")
library(GGally, lib.loc = "../utility/packages/")
library(stringr, lib.loc = "../utility/packages/")

source("../utility/fun_def_SPLOM_fun.R")

##################################
df <- readr::read_tsv("output/results/all_results.tsv", show_col_types = F)

df <- df %>% 
  dplyr::filter(n_feat_cats_all_features != 0) %>% 
  dplyr::filter(n_feat_cats_core_features_only != 0) 

# SPLOM custom metrics

df_for_plot <- df %>%
  dplyr::select("Surprisal feat\nagg_level = lemma\nall features" = "sum_surprisal_morph_split_mean_lemma_all_features"  ,         
                "Surprisal feat\nagg_level = lemma\ncore features only"  = "sum_surprisal_morph_split_mean_lemma_core_features_only"    ,  
                "Surprisal feat\nagg_level = UPOS\nall features" = "sum_surprisal_morph_split_mean_upos_all_features" ,           
                "Surprisal feat\nagg_level = UPOS\ncore features only" = "sum_surprisal_morph_split_mean_upos_core_features_only"   ,    
                "Surprisal featstring\nagg_level = lemma\nall features" = "surprisal_per_morph_featstring_mean_lemma_all_features" ,     
                "Surprisal featstring\nagg_level = lemma\ncore features only" =  "surprisal_per_morph_featstring_mean_lemma_core_features_only",
                "Surprisal featstring\nagg_level = UPOS\nall features" = "surprisal_per_morph_featstring_mean_upos_all_features",       
                "Surprisal featstring\nagg_level = UPOS\ncore features only" = "surprisal_per_morph_featstring_mean_upos_core_features_only" ) 

cat("Dataframe for SPLOM custom metrics plot:\n")
cat(nrow(df_for_plot), "rows and", ncol(df_for_plot), "columns\n")

sum_surprisal_morph_split_mean_upos_all_features_col <- "#2be375"
surprisal_per_morph_featstring_mean_lemma_core_features_only_col <- "#357dc4"
TTR_col <- "#9234eb"

pal <- c("#A7E1A1" , #1
         "#5bafe3",   #2
         sum_surprisal_morph_split_mean_upos_all_features_col, #3
         "#90D8D7", #4
         "#86e397" , #5
         surprisal_per_morph_featstring_mean_lemma_core_features_only_col, #6
         "#35c43f", #7
         "grey40" #8
)

p <- df_for_plot %>% 
  coloured_SPLOM(text_cor_size = 5, text_strip_size = 10, method = "spearman",
                 hist_label_size = 3, herringbone = T,pair_colors = pal, cor_test_method_exact = FALSE
  )

ggplot2::ggsave("output/plots/SPLOM_custom_metrics.png", height = 30, width = 30, units = "cm", plot = p)

####################################
# SPLOM other metrics

df_for_plot <- df %>% 
  dplyr::select("Surprisal feat\nagg_level = UPOS\nall features" = "sum_surprisal_morph_split_mean_upos_all_features" , 
                "Surprisal featstring\nagg_level = lemma\ncore features only" = "surprisal_per_morph_featstring_mean_lemma_core_features_only",
                "TTR",
                "LTR"   ,
                "Feats per token\n(mean)\nall features" = "n_feats_per_token_mean_all_features",                         
                "Feats per token\n(mean)\ncore features only" ="n_feats_per_token_mean_core_features_only",
                "Suprisal of token\nmean" = suprisal_token_mean, 
                "Types (n)" = "n_types", 
                "Tokens (n) " = "n_tokens",
                "Sentences (n)" = "n_sentences" ,
                "Feat cat (n)\nall features" = "n_feat_cats_all_features",                                    
                "Feat cat (n)\ncore features only" = "n_feat_cats_core_features_only"
                
  ) 

cat("Dataframe for SPLOM other metrics plot:\n")
cat(nrow(df_for_plot), "rows and", ncol(df_for_plot), "columns\n")

pal <- c(sum_surprisal_morph_split_mean_upos_all_features_col, #1
         surprisal_per_morph_featstring_mean_lemma_core_features_only_col,   #2
         TTR_col, #3
         "#BA4FE1", #4
         "#cf2d27" , #5
         "#E278B1", #6
         "#ed268d", #7
         "#c735e8", #8
         "#f723bb", #9
         "#cf2757", #10
         "#c387f5", #11
         "grey40" #12
)


p <-  df_for_plot %>% 
  coloured_SPLOM(hist_label_size = 2.3, method = "spearman",text_cor_size = 5, text_strip_size = 6, pair_colors = pal, herringbone = T, cor_test_method_exact = FALSE
  )

ggplot2::ggsave("output/plots/SPLOM_other_metrics.png", height = 30, width = 30, units = "cm", plot = p)

####################################
# SPLOM external metrics

df_for_plot <- df %>% 
  dplyr::select("glottocode",
                "Surprisal feat\nagg_level = UPOS\nall features" = "sum_surprisal_morph_split_mean_upos_all_features" , 
                "Surprisal featstring\nagg_level = lemma\ncore features only" =  "surprisal_per_morph_featstring_mean_lemma_core_features_only", 
                "TTR",
                "Fusion\n(Grambank v1.0)" = "Fusion", 
                "Informativity\n(Grambank v1.0)" ="Informativity",
                "Çöltekin & Rama's\nmfh\n(slightly modified version)" = mfh
  )  %>% 
  dplyr::distinct()

cat("Dataframe for SPLOM external metrics plot:\n")
cat(nrow(df_for_plot), "rows and", ncol(df_for_plot), "columns\n")

pal <- c(sum_surprisal_morph_split_mean_upos_all_features_col, #1
         surprisal_per_morph_featstring_mean_lemma_core_features_only_col,   #2
         TTR_col, #3
         "#DBAC5E", #4
         "#f5dd02", #5
         "#f57f31", #6
         "pink",
         "grey40"
)

p <- df_for_plot %>% 
  coloured_SPLOM(hist_label_size = 3,
                 pair_colors = pal, 
                 text_cor_size = 5, 
                 text_strip_size = 10,
                 method = "spearman",
                 cor_test_method_exact = FALSE,
                
                 herringbone = T,
                 col_pairs_to_constraint = c("Fusion\n(Grambank v1.0)", 
                                             "Informativity\n(Grambank v1.0)", 
                                             "Pop\n (Google)", 
                                             "Pop\n(Google)\nlog10"
                 ), 
                 col_pairs_constraint = "glottocode")


ggplot2::ggsave("output/plots/SPLOM_metrics_external.png", height = 30, width = 30, units = "cm", plot = p)

####################################
# PUD

df_for_plot <- df %>% 
  dplyr::filter(stringr::str_detect(dir, pattern = "PUD")) %>% 
  dplyr::select("Surprisal feat\nagg_level = lemma\nall features" = "sum_surprisal_morph_split_mean_lemma_all_features"  ,         
                "Surprisal feat\nagg_level = lemma\ncore features only"  = "sum_surprisal_morph_split_mean_lemma_core_features_only"    ,  
                "Surprisal feat\nagg_level = UPOS\nall features" = "sum_surprisal_morph_split_mean_upos_all_features" ,           
                "Surprisal feat\nagg_level = UPOS\ncore features only" = "sum_surprisal_morph_split_mean_upos_core_features_only"   ,    
                "Surprisal featstring\nagg_level = lemma\nall features" = "surprisal_per_morph_featstring_mean_lemma_all_features" ,     
                "Surprisal featstring\nagg_level = lemma\ncore features only" =  "surprisal_per_morph_featstring_mean_lemma_core_features_only",
                "Surprisal featstring\nagg_level = UPOS\nall features" = "surprisal_per_morph_featstring_mean_upos_all_features",       
                "Surprisal featstring\nagg_level = UPOS\ncore features only" = "surprisal_per_morph_featstring_mean_upos_core_features_only" ) 

cat("Dataframe for SPLOM custom metrics PUD plot:\n")
cat(nrow(df_for_plot), "rows and", ncol(df_for_plot), "columns\n")

if (nrow(df_for_plot) > 0) {
  
  pal <- c("#A7E1A1" , #1
           "#5bafe3",   #2
           sum_surprisal_morph_split_mean_upos_all_features_col, #3
           "#90D8D7", #4
           "#86e397" , #5
           surprisal_per_morph_featstring_mean_lemma_core_features_only_col, #6
           "#35c43f", #7
           "grey40" #8
  )
  
  p <- df_for_plot %>% 
    coloured_SPLOM(pair_colors = pal, text_cor_size = 5, text_strip_size = 10,method = "spearman", hist_label_size = 2.5, herringbone = T, hist_bins = 7, cor_test_method_exact = FALSE)
  
  ggplot2::ggsave("output/plots/SPLOM_custom_metrics_PUD.png", height = 30, width = 30, units = "cm", plot = p)
  
} else {
  cat("No PUD data available for SPLOM custom metrics plot.\n")
}

####################################
# PUD other metrics

df_for_plot <- df %>% 
  dplyr::filter(stringr::str_detect(dir, pattern = "PUD")) %>% 
  dplyr::select("Surprisal feat\nagg_level = UPOS\nall features" = "sum_surprisal_morph_split_mean_upos_all_features" , 
                "Surprisal featstring\nagg_level = lemma\ncore features only" = "surprisal_per_morph_featstring_mean_lemma_core_features_only",
                "TTR",
                "LTR"   ,
                "Feats per token\n(mean)\nall features" = "n_feats_per_token_mean_all_features",                         
                "Feats per token\n(mean)\ncore features only" ="n_feats_per_token_mean_core_features_only",
                "Suprisal of token\nmean" = suprisal_token_mean, 
                "Types (n)" = "n_types", 
                "Tokens (n) " = "n_tokens",
                #  "Sentences (n)" = "n_sentences" ,
                "Feat cat (n)\nall features" = "n_feat_cats_all_features",                                    
                "Feat cat (n)\ncore features only" = "n_feat_cats_core_features_only"
  ) 

cat("Dataframe for SPLOM other metrics PUD plot:\n")
cat(nrow(df_for_plot), "rows and", ncol(df_for_plot), "columns\n")

if (nrow(df_for_plot) > 0) {
  
  pal <- c(sum_surprisal_morph_split_mean_upos_all_features_col, #1
           surprisal_per_morph_featstring_mean_lemma_core_features_only_col,   #2
           TTR_col, #3
           "#BA4FE1", #4
           "#cf2d27" , #5
           "#E278B1", #6
           "#ed268d", #7
           "#c735e8", #8
           "#f723bb", #9
           #  "#cf2757", #10
           "#c387f5", #11
           "grey40" #12
  )
  
  p <-  df_for_plot %>% 
    coloured_SPLOM(hist_label_size = 2.3, text_cor_size = 5, text_strip_size = 7, method = "spearman",pair_colors = pal, herringbone = T, hist_bins = 7, cor_test_method_exact = FALSE)
  
  ggplot2::ggsave("output/plots/SPLOM_other_metrics_PUD.png", height = 30, width = 30, units = "cm", plot = p)
  
} else {
  cat("No PUD data available for SPLOM other metrics plot.\n")
}

####################################
# PUD external metrics

df_for_plot <- df %>% 
  dplyr::filter(stringr::str_detect(dir, pattern = "PUD")) %>% 
  dplyr::select("glottocode",
                "Surprisal feat\nagg_level = UPOS\nall features" = "sum_surprisal_morph_split_mean_upos_all_features" , 
                "Surprisal featstring\nagg_level = lemma\ncore features only" =  "surprisal_per_morph_featstring_mean_lemma_core_features_only", 
                "TTR",
                "Fusion\n(Grambank v1.0)" = "Fusion", 
                "Informativity\n(Grambank v1.0)" ="Informativity",
                "Çöltekin & Rama's\nmfh\n(slightly modified version)" = mfh
  )  %>% 
  dplyr::distinct()

cat("Dataframe for SPLOM external metrics PUD plot:\n")
cat(nrow(df_for_plot), "rows and", ncol(df_for_plot), "columns\n")

if (nrow(df_for_plot) > 0) {
  
  pal <- c(sum_surprisal_morph_split_mean_upos_all_features_col, #1
           surprisal_per_morph_featstring_mean_lemma_core_features_only_col,   #2
           TTR_col, #3
           "#DBAC5E", #4
           "#f5dd02", #5
           "#f57f31", #6
           "grey40"
  )
  
  p <-df_for_plot %>% 
    coloured_SPLOM(hist_label_size = 3,
                   pair_colors = pal, 
                   method = "spearman",
                   cor_test_method_exact = FALSE,   
                   text_cor_size = 5, 
                   text_strip_size = 10,
                   col_pairs_to_constraint = c("Fusion\n(Grambank v1.0)", 
                                               "Informativity\n(Grambank v1.0)", 
                                               "Pop\n (Google)", 
                                               "Pop\n(Google)\nlog10"), 
                   col_pairs_constraint = "glottocode", herringbone = T, hist_bins = 7)
  
  
  ggplot2::ggsave("output/plots/SPLOM_metrics_external_PUD.png", height = 30, width = 30, units = "cm", plot = p)
  
} else {
  cat("No PUD data available for SPLOM external metrics plot.\n")
}

#df_check <- df %>% 
#  distinct(glottocode, Fusion, Pop) 

#df_check <- df_check[complete.cases(df_check),]

#nrow(df_check)

#df_check %>% 
#  ggplot(aes(x = Fusion, y = Pop)) +
#  geom_point() +
#  ggpubr::stat_cor(method = "pearson", p.digits = 2, geom = "label", color = "blue",
#                   label.y.npc="top", label.x.npc = "left", alpha = 0.8) 