library(dplyr, lib.loc = "../utility/packages/")
library(ggplot2, lib.loc = "../utility/packages/")
library(magrittr, lib.loc = "../utility/packages/")
library(readr, lib.loc = "../utility/packages/")
library(GGally, lib.loc = "../utility/packages/")
library(stringr, lib.loc = "../utility/packages/")

source("../utility/fun_def_SPLOM_fun.R")

##################################
df <- readr::read_tsv("output/results/all_results.tsv", show_col_types = F)

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

ggplot2::ggsave("output/plots/SPLOM_metrics_custom.png", height = 30, width = 30, units = "cm", plot = p)

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
  coloured_SPLOM(hist_label_size = 2.3, method = "spearman",text_cor_size = 5, text_strip_size = 7, pair_colors = pal, herringbone = T, cor_test_method_exact = FALSE
  )

ggplot2::ggsave("output/plots/SPLOM_metrics_other.png", height = 30, width = 30, units = "cm", plot = p)

####################################
# SPLOM external metrics

#CR
df_for_plot <- df %>% 
  dplyr::select("Surprisal feat\nagg_level = UPOS\nall features" = "sum_surprisal_morph_split_mean_upos_all_features" , 
                "Surprisal featstring\nagg_level = lemma\ncore features only" =  "surprisal_per_morph_featstring_mean_lemma_core_features_only", 
                "TTR",
                "Çöltekin & Rama's\nmfh\n(slightly modified version)" = mfh
  )  

cat("Dataframe for SPLOM external metrics plot:\n")
cat(nrow(df_for_plot), "rows and", ncol(df_for_plot), "columns\n")

pal <- c(sum_surprisal_morph_split_mean_upos_all_features_col, #1
         surprisal_per_morph_featstring_mean_lemma_core_features_only_col,   #2
         TTR_col, #3
         "#DBAC5E" #4"
)

p <- df_for_plot %>% 
  coloured_SPLOM(hist_label_size = 3,
                 pair_colors = pal, 
                 text_cor_size = 5, 
                 text_strip_size = 10,
                 method = "spearman",
                 cor_test_method_exact = FALSE,
                 herringbone = T)


ggplot2::ggsave("output/plots/SPLOM_metrics_external_CR.png", height = 18, width = 18, units = "cm", plot = p)

#grambank
df_for_plot <- df %>% 
  group_by(glottocode) %>% 
  summarise(sum_surprisal_morph_split_mean_upos_all_features = mean(sum_surprisal_morph_split_mean_upos_all_features), 
            surprisal_per_morph_featstring_mean_lemma_core_features_only = mean(surprisal_per_morph_featstring_mean_lemma_core_features_only), 
            TTR = mean(TTR),
            Fusion = mean(Fusion), 
            n_feat_cats_all_features = mean(n_feat_cats_all_features),
            Informativity = mean(Informativity), .groups = "drop") %>% 
  dplyr::select("Surprisal feat\nagg_level = UPOS\nall features" = "sum_surprisal_morph_split_mean_upos_all_features" , 
                "Surprisal featstring\nagg_level = lemma\ncore features only" =  "surprisal_per_morph_featstring_mean_lemma_core_features_only", 
                "TTR",
                "Feat cat (n)\nall features" = "n_feat_cats_all_features",    
                "Fusion\n(Grambank v1.0)" = "Fusion", 
                "Informativity\n(Grambank v1.0)" ="Informativity")  

cat("Dataframe for SPLOM external metrics plot (Grambank):\n")
cat(nrow(df_for_plot), "rows and", ncol(df_for_plot), "columns\n")

pal <- c(sum_surprisal_morph_split_mean_upos_all_features_col, #1
         surprisal_per_morph_featstring_mean_lemma_core_features_only_col,   #2
         TTR_col, #3
         "#f57f31", #6
         "pink",    "#c387f5" #11
)

p <- df_for_plot %>% 
  coloured_SPLOM(hist_label_size = 2.5,
                 pair_colors = pal, 
                 text_cor_size = 5, 
                 text_strip_size = 7,
                 method = "spearman",
                 cor_test_method_exact = FALSE,
                 
                 herringbone = T)


ggplot2::ggsave("output/plots/SPLOM_metrics_external_Grambank.png", height = 18, width = 18, units = "cm", plot = p)

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
  
  ggplot2::ggsave("output/plots/SPLOM_metrics_custom_PUD.png", height = 30, width = 30, units = "cm", plot = p)
  
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
  
  ggplot2::ggsave("output/plots/SPLOM_metrics_other_PUD.png", height = 30, width = 30, units = "cm", plot = p)
  
} else {
  cat("No PUD data available for SPLOM other metrics plot.\n")
}

####################################
# PUD external metrics

#CR
df_for_plot <- df %>% 
  dplyr::filter(stringr::str_detect(dir, pattern = "PUD")) %>% 
  dplyr::select("Surprisal feat\nagg_level = UPOS\nall features" = "sum_surprisal_morph_split_mean_upos_all_features" , 
                "Surprisal featstring\nagg_level = lemma\ncore features only" =  "surprisal_per_morph_featstring_mean_lemma_core_features_only", 
                "TTR",
                "Çöltekin & Rama's\nmfh\n(slightly modified version)" = mfh
  )  


cat("Dataframe for SPLOM external metrics PUD plot CR:\n")
cat(nrow(df_for_plot), "rows and", ncol(df_for_plot), "columns\n")

if (nrow(df_for_plot) > 0) {
  
  
  pal <- c(sum_surprisal_morph_split_mean_upos_all_features_col, #1
           surprisal_per_morph_featstring_mean_lemma_core_features_only_col,   #2
           TTR_col, #3
           "#DBAC5E" #4"
  )
  
  p <- df_for_plot %>% 
    coloured_SPLOM(hist_label_size = 3,
                   pair_colors = pal, 
                   text_cor_size = 5, 
                   text_strip_size = 10,
                   method = "spearman",
                   cor_test_method_exact = FALSE,
                   herringbone = T)
  
  
  ggplot2::ggsave("output/plots/SPLOM_metrics_external_CR_PUD.png", height = 18, width = 18, units = "cm", plot = p)
  
  
  
} else {
  cat("No PUD data available for SPLOM external metrics plot CR.\n")
}

#external grambank
df_for_plot <- df %>% 
  group_by(glottocode) %>% 
  summarise(sum_surprisal_morph_split_mean_upos_all_features = mean(sum_surprisal_morph_split_mean_upos_all_features), 
            surprisal_per_morph_featstring_mean_lemma_core_features_only = mean(surprisal_per_morph_featstring_mean_lemma_core_features_only), 
            TTR = mean(TTR),
            Fusion = mean(Fusion), 
            n_feat_cats_all_features = mean(n_feat_cats_all_features),
            Informativity = mean(Informativity), .groups = "drop"
            ) %>% 
  dplyr::select("Surprisal feat\nagg_level = UPOS\nall features" = "sum_surprisal_morph_split_mean_upos_all_features" , 
                "Surprisal featstring\nagg_level = lemma\ncore features only" =  "surprisal_per_morph_featstring_mean_lemma_core_features_only", 
                "TTR",
                "Feat cat (n)\nall features" = "n_feat_cats_all_features",    
                "Fusion\n(Grambank v1.0)" = "Fusion", 
                "Informativity\n(Grambank v1.0)" ="Informativity")  



cat("Dataframe for SPLOM external metrics PUD plot CR:\n")
cat(nrow(df_for_plot), "rows and", ncol(df_for_plot), "columns\n")

if (nrow(df_for_plot) > 0) {
  
  pal <- c(sum_surprisal_morph_split_mean_upos_all_features_col, #1
           surprisal_per_morph_featstring_mean_lemma_core_features_only_col,   #2
           TTR_col, #3
           "#f57f31", #6
           "pink",    "#c387f5" #11
  )
  
  p <- df_for_plot %>% 
    coloured_SPLOM(hist_label_size = 2.5,
                   pair_colors = pal, 
                   text_cor_size = 5, 
                   text_strip_size = 7,
                   method = "spearman",
                   cor_test_method_exact = FALSE,
                   
                   herringbone = T)
  
  
  ggplot2::ggsave("output/plots/SPLOM_metrics_external_Grambank_PUD.png", height = 18, width = 18, units = "cm", plot = p)
  
  
  
} else {
  cat("No PUD data available for SPLOM external metrics plot.\n")
}

