library(dplyr, lib.loc = "../utility/packages/")
library(ggplot2, lib.loc = "../utility/packages/")
library(magrittr, lib.loc = "../utility/packages/")
library(readr, lib.loc = "../utility/packages/")
library(GGally, lib.loc = "../utility/packages/")
library(stringr, lib.loc = "../utility/packages/")

source("../utility/fun_def_SPLOM_fun.R")

##################################
df <- readr::read_tsv("output/results/all_results.tsv", show_col_types = F)

#define colores to variables in order to resuse them accross different SPLOMS
sum_surprisal_morph_split_mean_upos_all_features_col <- "#2be375"
surprisal_per_morph_featstring_mean_lemma_core_features_only_col <- "#357dc4"
TTR_col <- "#9234eb"
CR_col <- "#DBAC5E"
fusion_col <- "#f57f31"
informativity_col <- "pink"
feat_cat_all_col <- "#f723bb"

# SPLOM custom metrics

df_for_plot <- df %>%
  dplyr::select("Surprisal\nfeat\nagg_level = lemma\nall features" = "sum_surprisal_morph_split_mean_lemma_all_features"  ,         
                "Surprisal\nfeat\nagg_level = lemma\ncore features only"  = "sum_surprisal_morph_split_mean_lemma_core_features_only"    ,  
                "Surprisal\nfeat\nagg_level = UPOS\nall features" = "sum_surprisal_morph_split_mean_upos_all_features" ,           
                "Surprisal\nfeat\nagg_level = UPOS\ncore features only" = "sum_surprisal_morph_split_mean_upos_core_features_only"   ,    
                "Surprisal\nfeatstring\nagg_level = lemma\nall features" = "surprisal_per_morph_featstring_mean_lemma_all_features" ,     
                "Surprisal\nfeatstring\nagg_level = lemma\ncore features only" =  "surprisal_per_morph_featstring_mean_lemma_core_features_only",
                "Surprisal\nfeatstring\nagg_level = UPOS\nall features" = "surprisal_per_morph_featstring_mean_upos_all_features",       
                "Surprisal\nfeatstring\nagg_level = UPOS\ncore features only" = "surprisal_per_morph_featstring_mean_upos_core_features_only" ) 

cat("Dataframe for SPLOM custom metrics plot:\n")
cat(nrow(df_for_plot), "rows and", ncol(df_for_plot), "columns\n")


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
  coloured_SPLOM(text_cor_size = 5, 
                 text_strip_size = 10, 
                 method = "spearman",
                 hist_label_size = 3, 
                 herringbone = TRUE,
                 hist_bins = 10, 
                 pair_colors = pal, 
                 cor_test_method_exact = TRUE
  )


p$p_values_df %>% 
  dplyr::mutate(
    pair_key = stringr::str_replace_all(pair_key, "\n", " "), #removing line breaks in tsv
    x = stringr::str_replace_all(x, "\n", " "), #removing line breaks in tsv
    y = stringr::str_replace_all(y, "\n", " "),
    # keep fixed-point, suppress scientific notation
    pvalue = sprintf("%.17f", pvalue)
  ) %>%   
  readr::write_tsv("output/results/correlation_dfs/correlation_df_metrics_custom.tsv", na = "")
 
ggplot2::ggsave("output/plots/SPLOM_metrics_custom.png", height = 30, width = 30, units = "cm", plot = p$plot)

####################################
# SPLOM other metrics

df_for_plot <- df %>% 
  dplyr::select("Surprisal\nfeat\nagg_level = UPOS\nall features" = "sum_surprisal_morph_split_mean_upos_all_features" , 
                "Surprisal\nfeatstring\nagg_level = lemma\ncore features only" = "surprisal_per_morph_featstring_mean_lemma_core_features_only",
                "TTR",
                "LTR"   ,
                "Feats per token\n(mean)\nall features" = "n_feats_per_token_mean_all_features",          #5
                "Feats per token\n(mean)\ncore features only" ="n_feats_per_token_mean_core_features_only",
                "Suprisal of token\nmean" = suprisal_token_mean, 
                "Types (n)" = "n_types", 
                "Tokens (n) " = "n_tokens",
                "Feat cat (n)\nall features" = "n_feat_cats_all_features",                                    
                "Feat cat (n)\ncore features only" = "n_feat_cats_core_features_only" #11
                
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
         "#cf2757", #9
         feat_cat_all_col, #10
         "#c387f5", #11
         "grey40" #12
)


p <-  df_for_plot %>% 
  coloured_SPLOM(hist_label_size = 2.3, 
                 method = "spearman",
                 text_cor_size = 5, 
                 text_strip_size = 7, 
                 pair_colors = pal, 
                 herringbone = TRUE, 
                 hist_bins = 10, 
                 cor_test_method_exact = FALSE
  )

p$p_values_df %>% 
  dplyr::mutate(
    pair_key = stringr::str_replace_all(pair_key, "\n", " "), #removing line breaks in tsv
    x = stringr::str_replace_all(x, "\n", " "), #removing line breaks in tsv
    y = stringr::str_replace_all(y, "\n", " "),
    # keep fixed-point, suppress scientific notation
    pvalue = sprintf("%.17f", pvalue)
  ) %>%   
  readr::write_tsv("output/results/correlation_dfs/correlation_df_metrics_other.tsv", na = "")

ggplot2::ggsave("output/plots/SPLOM_metrics_other.png", height = 30, width = 30, units = "cm", plot = p$plot)

####################################
# SPLOM external metrics

#CR
df_for_plot <- df %>% 
  dplyr::select("Surprisal\nfeat\nagg_level = UPOS\nall features" = "sum_surprisal_morph_split_mean_upos_all_features" , 
                "Surprisal\nfeatstring\nagg_level = lemma\ncore features only" =  "surprisal_per_morph_featstring_mean_lemma_core_features_only", 
                "TTR",
                "Feat cat (n)\nall features" = "n_feat_cats_all_features",    
                "Çöltekin & Rama's\nmfh\n(slightly modified\nversion)" = mfh
  )  

cat("Dataframe for SPLOM external metrics plot:\n")
cat(nrow(df_for_plot), "rows and", ncol(df_for_plot), "columns\n")

pal <- c(sum_surprisal_morph_split_mean_upos_all_features_col, #1
         surprisal_per_morph_featstring_mean_lemma_core_features_only_col,   #2
         TTR_col, #3
         feat_cat_all_col,
         CR_col #4"
)

p <- df_for_plot %>% 
  coloured_SPLOM(hist_label_size = 2.5,
                 pair_colors = pal, 
                 text_cor_size = 5, 
                 text_strip_size = 9,
                 adjust_pvalues = "holm", 
                 adjust_pvalues_for_pairs =   c("Surprisal\nfeat\nagg_level = UPOS\nall features_TTR",
                                                "Feat cat (n)\nall features_Surprisal\nfeat\nagg_level = UPOS\nall features",
                                                "Çöltekin & Rama's\nmfh\n(slightly modified\nversion)_Surprisal\nfeat\nagg_level = UPOS\nall features",
                                                "Surprisal\nfeatstring\nagg_level = lemma\ncore features only_TTR",
                                                "Feat cat (n)\nall features_Surprisal\nfeatstring\nagg_level = lemma\ncore features only",
                                                "Çöltekin & Rama's\nmfh\n(slightly modified\nversion)_Surprisal\nfeatstring\nagg_level = lemma\ncore features only",
                                                "Feat cat (n)\nall features_TTR"  ,
                                                "Çöltekin & Rama's\nmfh\n(slightly modified\nversion)_TTR" ),
                 method = "spearman",
                 hist_bins = 10, 
                 cor_test_method_exact = FALSE,
                 herringbone = T)

p$p_values_df %>%  
  dplyr::mutate(
    pair_key = stringr::str_replace_all(pair_key, "\n", " "), #removing line breaks in tsv
    x = stringr::str_replace_all(x, "\n", " "), #removing line breaks in tsv
    y = stringr::str_replace_all(y, "\n", " "),
    # keep fixed-point, suppress scientific notation
    pvalue = sprintf("%.17f", pvalue)
  ) %>%   
  readr::write_tsv("output/results/correlation_dfs/correlation_df_metrics_external_CR.tsv", na = "")

ggplot2::ggsave("output/plots/SPLOM_metrics_external_CR.png", height = 18, width = 18, units = "cm", plot = p$plot)

#grambank
df_for_plot <- df %>% 
  dplyr::group_by(glottocode) %>% 
  dplyr::summarise(sum_surprisal_morph_split_mean_upos_all_features = mean(sum_surprisal_morph_split_mean_upos_all_features), 
            surprisal_per_morph_featstring_mean_lemma_core_features_only = mean(surprisal_per_morph_featstring_mean_lemma_core_features_only), 
            TTR = mean(TTR),
            mfh = mean(mfh),
            Fusion = mean(Fusion), 
            n_feat_cats_all_features = mean(n_feat_cats_all_features),
            Informativity = mean(Informativity), .groups = "drop") %>% 
  dplyr::select("Surprisal\nfeat\nagg_level = UPOS\nall features" = "sum_surprisal_morph_split_mean_upos_all_features" , 
                "Surprisal\nfeatstring\nagg_level = lemma\ncore features only" =  "surprisal_per_morph_featstring_mean_lemma_core_features_only", 
                "TTR",
                "Feat cat (n)\nall features" = "n_feat_cats_all_features",    
                "Çöltekin & Rama's\nmfh\n(slightly modified\nversion)" = mfh,
                "Fusion\n(Grambank v1.0)" = "Fusion", 
                "Informativity\n(Grambank v1.0)" ="Informativity")  

cat("Dataframe for SPLOM external metrics plot (Grambank):\n")
cat(nrow(df_for_plot), "rows and", ncol(df_for_plot), "columns\n")

pal <- c(sum_surprisal_morph_split_mean_upos_all_features_col, #1
         surprisal_per_morph_featstring_mean_lemma_core_features_only_col,   #2
         TTR_col, #3
         feat_cat_all_col,
         CR_col,
         fusion_col, 
         informativity_col
)

p <- df_for_plot %>% 
  coloured_SPLOM(hist_label_size = 1.8,
                 pair_colors = pal, 
                 text_cor_size = 5, 
                 text_strip_size = 6,
                 adjust_pvalues = "holm",adjust_pvalues_for_pairs = c("Fusion\n(Grambank v1.0)_Surprisal\nfeat\nagg_level = UPOS\nall features", 
                                                                      "Informativity\n(Grambank v1.0)_Surprisal\nfeat\nagg_level = UPOS\nall features" ,
                                                                      "Fusion\n(Grambank v1.0)_Surprisal\nfeatstring\nagg_level = lemma\ncore features only",
                                                                      "Informativity\n(Grambank v1.0)_Surprisal\nfeatstring\nagg_level = lemma\ncore features only" ,
                                                                      "Fusion\n(Grambank v1.0)_TTR",
                                                                      "Informativity\n(Grambank v1.0)_TTR",
                                                                      "Feat cat (n)\nall features_Fusion\n(Grambank v1.0)" ,
                                                                      "Feat cat (n)\nall features_Informativity\n(Grambank v1.0)" ,
                                                                      "Çöltekin & Rama's\nmfh\n(slightly modified\nversion)_Fusion\n(Grambank v1.0)"  ,
                                                                      "Çöltekin & Rama's\nmfh\n(slightly modified\nversion)_Informativity\n(Grambank v1.0)"  
                 ),
                 method = "spearman",
                 hist_bins = 10, 
                 cor_test_method_exact = FALSE,
                 herringbone = T)


#Feat / UPOS / all & Fusion & All & 0.0454 & \textit{0.409} \\ "Fusion\n(Grambank v1.0)_Surprisal\nfeat\nagg_level = UPOS\nall features"
#Feat / UPOS / all & Informativity & All & \textit{0.305} & \textit{1.000} \\ "Informativity\n(Grambank v1.0)_Surprisal\nfeat\nagg_level = UPOS\nall features"  
#Featstring / lemma / core & Fusion & All & 0.00735 & \textit{0.0735} \\ "Fusion\n(Grambank v1.0)_Surprisal\nfeatstring\nagg_level = lemma\ncore features only"         
#Featstring / lemma / core & Informativity & All & \textit{0.505} & \textit{1.000} \\ "Informativity\n(Grambank v1.0)_Surprisal\nfeatstring\nagg_level = lemma\ncore features only"      
#Type-Token Ratio & Fusion & All & \textit{0.736} & \textit{1.000} \\ "Fusion\n(Grambank v1.0)_TTR"
#Type-Token Ratio & Informativity & All & \textit{0.321} & \textit{1.000} \\ "Informativity\n(Grambank v1.0)_TTR"  
#\#Feature categories & Fusion & All & \textit{0.371} & \textit{1.000} \\ "Feat cat (n)\nall features_Fusion\n(Grambank v1.0)" 
#\#Feature categories & Informativity & All & \textit{0.760} & \textit{1.000} \\ "Feat cat (n)\nall features_Informativity\n(Grambank v1.0)" 
#MFH & Fusion & All & \textit{0.0510} & \textit{0.409} \\  "Çöltekin & Rama's\nmfh\n(slightly modified\nversion)_Fusion\n(Grambank v1.0)"   
#MFH & Informativity & All & \textit{0.726} & \textit{1.000} \\  "Çöltekin & Rama's\nmfh\n(slightly modified\nversion)_Informativity\n(Grambank v1.0)"       


p$p_values_df %>% 
  dplyr::mutate(
    pair_key = stringr::str_replace_all(pair_key, "\n", " "), #removing line breaks in tsv
    x = stringr::str_replace_all(x, "\n", " "), #removing line breaks in tsv
    y = stringr::str_replace_all(y, "\n", " "),
    # keep fixed-point, suppress scientific notation
    pvalue = sprintf("%.17f", pvalue))  %>% 
  readr::write_tsv("output/results/correlation_dfs/correlation_df_metrics_external_Grambank.tsv", na = "")

ggplot2::ggsave("output/plots/SPLOM_metrics_external_Grambank.png", height = 18, width = 18, units = "cm", plot = p$plot)

##############################################################################
##############################################################################
##############################################################################
# PUD

df_for_plot <- df %>% 
  dplyr::filter(stringr::str_detect(dir, pattern = "PUD")) %>% 
  dplyr::select("Surprisal\nfeat\nagg_level = lemma\nall features" = "sum_surprisal_morph_split_mean_lemma_all_features"  ,         
                "Surprisal\nfeat\nagg_level = lemma\ncore features only"  = "sum_surprisal_morph_split_mean_lemma_core_features_only"    ,  
                "Surprisal\nfeat\nagg_level = UPOS\nall features" = "sum_surprisal_morph_split_mean_upos_all_features" ,           
                "Surprisal\nfeat\nagg_level = UPOS\ncore features only" = "sum_surprisal_morph_split_mean_upos_core_features_only"   ,    
                "Surprisal\nfeatstring\nagg_level = lemma\nall features" = "surprisal_per_morph_featstring_mean_lemma_all_features" ,     
                "Surprisal\nfeatstring\nagg_level = lemma\ncore features only" =  "surprisal_per_morph_featstring_mean_lemma_core_features_only",
                "Surprisal\nfeatstring\nagg_level = UPOS\nall features" = "surprisal_per_morph_featstring_mean_upos_all_features",       
                "Surprisal\nfeatstring\nagg_level = UPOS\ncore features only" = "surprisal_per_morph_featstring_mean_upos_core_features_only" ) 

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
    coloured_SPLOM(pair_colors = pal, 
                   text_cor_size = 5, 
                   text_strip_size = 10,
                   method = "spearman", 
                   hist_label_size = 3, 
                   herringbone = TRUE, 
                   hist_bins = 7, 
                   cor_test_method_exact = TRUE)
  
  p$p_values_df %>% 
    dplyr::mutate(
      pair_key = stringr::str_replace_all(pair_key, "\n", " "), #removing line breaks in tsv
      x = stringr::str_replace_all(x, "\n", " "), #removing line breaks in tsv
      y = stringr::str_replace_all(y, "\n", " "),
      # keep fixed-point, suppress scientific notation
      pvalue = sprintf("%.17f", pvalue)
    ) %>%   
    readr::write_tsv("output/results/correlation_dfs/correlation_df_metrics_custom_PUD.tsv", na = "")
  
  ggplot2::ggsave("output/plots/SPLOM_metrics_custom_PUD.png", height = 30, width = 30, units = "cm", plot = p$plot)
  
} else {
  cat("No PUD data available for SPLOM custom metrics plot.\n")
}

####################################
# PUD other metrics

df_for_plot <- df %>% 
  dplyr::filter(stringr::str_detect(dir, pattern = "PUD")) %>% 
  dplyr::select("Surprisal\nfeat\nagg_level = UPOS\nall features" = "sum_surprisal_morph_split_mean_upos_all_features" , 
                "Surprisal\nfeatstring\nagg_level = lemma\ncore features only" = "surprisal_per_morph_featstring_mean_lemma_core_features_only",
                "TTR",
                "LTR"   ,
                "Feats per token\n(mean)\nall features" = "n_feats_per_token_mean_all_features",                         
                "Feats per token\n(mean)\ncore features only" ="n_feats_per_token_mean_core_features_only",
                "Suprisal of token\nmean" = suprisal_token_mean, 
                "Types (n)" = "n_types", 
                "Tokens (n) " = "n_tokens",
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
           "#cf2757", #9
           feat_cat_all_col, #10
           "#c387f5", #11
           "grey40" #12
  )
  
  p <-  df_for_plot %>% 
    coloured_SPLOM(hist_label_size = 2.3, 
                   text_cor_size = 5, text_strip_size = 7, 
                   method = "spearman",
                   pair_colors = pal, 
                   herringbone = TRUE, 
                   hist_bins = 7, 
                   cor_test_method_exact = FALSE)
  
  
  p$p_values_df %>% 
    dplyr::mutate(
      pair_key = stringr::str_replace_all(pair_key, "\n", " "), #removing line breaks in tsv
      x = stringr::str_replace_all(x, "\n", " "), #removing line breaks in tsv
      y = stringr::str_replace_all(y, "\n", " "),
      # keep fixed-point, suppress scientific notation
      pvalue = sprintf("%.17f", pvalue)
    ) %>%   
    readr::write_tsv("output/results/correlation_dfs/correlation_df_metrics_other_PUD.tsv", na = "")
  
  ggplot2::ggsave("output/plots/SPLOM_metrics_other_PUD.png", height = 30, width = 30, units = "cm", plot = p$plot)
  
} else {
  cat("No PUD data available for SPLOM other metrics plot.\n")
}

####################################
# PUD external metrics

#CR
df_for_plot <- df %>% 
  dplyr::filter(stringr::str_detect(dir, pattern = "PUD")) %>% 
  dplyr::select("Surprisal\nfeat\nagg_level = UPOS\nall features" = "sum_surprisal_morph_split_mean_upos_all_features" , 
                "Surprisal\nfeatstring\nagg_level = lemma\ncore features only" =  "surprisal_per_morph_featstring_mean_lemma_core_features_only", 
                "TTR",
                "Feat cat (n)\nall features" = "n_feat_cats_all_features",    
                "Çöltekin & Rama's\nmfh\n(slightly modified\nversion)" = mfh
  )  


cat("Dataframe for SPLOM external metrics PUD plot CR:\n")
cat(nrow(df_for_plot), "rows and", ncol(df_for_plot), "columns\n")

if (nrow(df_for_plot) > 0) {
  
  
  pal <- c(sum_surprisal_morph_split_mean_upos_all_features_col, #1
           surprisal_per_morph_featstring_mean_lemma_core_features_only_col,   #2
           TTR_col, #3
           feat_cat_all_col,
           CR_col #4"
  )
  
  p <- df_for_plot %>% 
    coloured_SPLOM(hist_label_size = 2.5,
                   pair_colors = pal, 
                   text_cor_size = 5, 
                   text_strip_size = 9,
                   adjust_pvalues = "holm",
                   adjust_pvalues_for_pairs =   c("Surprisal\nfeat\nagg_level = UPOS\nall features_TTR",
                                                                          "Feat cat (n)\nall features_Surprisal\nfeat\nagg_level = UPOS\nall features",
                                                                          "Çöltekin & Rama's\nmfh\n(slightly modified\nversion)_Surprisal\nfeat\nagg_level = UPOS\nall features",
                                                                          "Surprisal\nfeatstring\nagg_level = lemma\ncore features only_TTR",
                                                                          "Feat cat (n)\nall features_Surprisal\nfeatstring\nagg_level = lemma\ncore features only",
                                                                          "Çöltekin & Rama's\nmfh\n(slightly modified\nversion)_Surprisal\nfeatstring\nagg_level = lemma\ncore features only",
                                                                          "Feat cat (n)\nall features_TTR"  ,
                                                                          "Çöltekin & Rama's\nmfh\n(slightly modified\nversion)_TTR" ),
                   method = "spearman",
                   hist_bins = 7, 
                   cor_test_method_exact = FALSE,
                   herringbone = T)
  
  p$p_values_df %>% 
    dplyr::mutate(
      pair_key = stringr::str_replace_all(pair_key, "\n", " "), #removing line breaks in tsv
      x = stringr::str_replace_all(x, "\n", " "), #removing line breaks in tsv
      y = stringr::str_replace_all(y, "\n", " "),
      # keep fixed-point, suppress scientific notation
      pvalue = sprintf("%.17f", pvalue)
    ) %>%   
    readr::write_tsv("output/results/correlation_dfs/correlation_df_metrics_external_CR_PUD.tsv", na = "")
  

  
  p$p_values_df$pair_key 
  #Feat / UPOS / all & Type-Token Ratio & All & 3.65e-06 & 1.46e-05 \\ "Surprisal\nfeat\nagg_level = UPOS\nall features_TTR" 
  #Feat / UPOS / all & \#Feature categories & All & <2.22e-16 & <2.22e-16 \\ "Feat cat (n)\nall features_Surprisal\nfeat\nagg_level = UPOS\nall features" 
  #Feat / UPOS / all & MFH & All & <2.22e-16 & <2.22e-16 \\ "Çöltekin & Rama's\nmfh\n(slightly modified\nversion)_Surprisal\nfeat\nagg_level = UPOS\nall features"   
  #Featstring / lemma / core & Type-Token Ratio & All & \textit{0.0924} & \textit{0.0924} \\  "Surprisal\nfeatstring\nagg_level = lemma\ncore features only_TTR" 
  #Featstring / lemma / core & \#Feature categories & All & 3.66e-11 & 1.83e-10 \\ "Feat cat (n)\nall features_Surprisal\nfeatstring\nagg_level = lemma\ncore features only"         
  #Featstring / lemma / core & MFH & All & <2.22e-16 & <2.22e-16 \\ "Çöltekin & Rama's\nmfh\n(slightly modified\nversion)_Surprisal\nfeatstring\nagg_level = lemma\ncore features only"
  #Type-Token Ratio & \#Feature categories & All & 0.00939 & 0.0188 \\ "Feat cat (n)\nall features_TTR"      
  #Type-Token Ratio & MFH & All & 0.00246 & 0.00739 \\ "Çöltekin & Rama's\nmfh\n(slightly modified\nversion)_TTR"  
  
  
  
  ggplot2::ggsave("output/plots/SPLOM_metrics_external_CR_PUD.png", height = 18, width = 18, units = "cm", plot = p$plot)
  
  
  
} else {
  cat("No PUD data available for SPLOM external metrics plot CR.\n")
}

#external grambank
df_for_plot <- df %>% 
  dplyr::filter(stringr::str_detect(dir, pattern = "PUD")) %>% 
  dplyr::group_by(glottocode) %>% 
  dplyr::summarise(sum_surprisal_morph_split_mean_upos_all_features = mean(sum_surprisal_morph_split_mean_upos_all_features), 
            surprisal_per_morph_featstring_mean_lemma_core_features_only = mean(surprisal_per_morph_featstring_mean_lemma_core_features_only), 
            TTR = mean(TTR),
            Fusion = mean(Fusion), 
            mfh = mean(mfh),
            n_feat_cats_all_features = mean(n_feat_cats_all_features),
            Informativity = mean(Informativity), .groups = "drop"
            ) %>% 
  dplyr::select(
    "Surprisal\nfeat\nagg_level = UPOS\nall features" = "sum_surprisal_morph_split_mean_upos_all_features" , 
                "Surprisal\nfeatstring\nagg_level = lemma\ncore features only" =  "surprisal_per_morph_featstring_mean_lemma_core_features_only", 
                "TTR",
                "Feat cat (n)\nall features" = "n_feat_cats_all_features",  
    "Çöltekin & Rama's\nmfh\n(slightly modified\nversion)" = "mfh",
                "Fusion\n(Grambank v1.0)" = "Fusion", 
                "Informativity\n(Grambank v1.0)" ="Informativity")  



cat("Dataframe for SPLOM external metrics PUD plot CR:\n")
cat(nrow(df_for_plot), "rows and", ncol(df_for_plot), "columns\n")

if (nrow(df_for_plot) > 0) {
  
  pal <- c(sum_surprisal_morph_split_mean_upos_all_features_col, #1
           surprisal_per_morph_featstring_mean_lemma_core_features_only_col,   #2
           TTR_col, #3
           feat_cat_all_col, 
           CR_col, 
           fusion_col, 
           informativity_col
  )
  
  p <- df_for_plot %>% 
    coloured_SPLOM(hist_label_size = 1.8,
                   pair_colors = pal, 
                   text_cor_size = 5, 
                   text_strip_size = 6,
                   method = "spearman",
                   adjust_pvalues = "holm",adjust_pvalues_for_pairs = c("Fusion\n(Grambank v1.0)_Surprisal\nfeat\nagg_level = UPOS\nall features", 
                                                                        "Informativity\n(Grambank v1.0)_Surprisal\nfeat\nagg_level = UPOS\nall features" ,
                                                                        "Fusion\n(Grambank v1.0)_Surprisal\nfeatstring\nagg_level = lemma\ncore features only",
                                                                        "Informativity\n(Grambank v1.0)_Surprisal\nfeatstring\nagg_level = lemma\ncore features only" ,
                                                                        "Fusion\n(Grambank v1.0)_TTR",
                                                                        "Informativity\n(Grambank v1.0)_TTR",
                                                                        "Feat cat (n)\nall features_Fusion\n(Grambank v1.0)" ,
                                                                        "Feat cat (n)\nall features_Informativity\n(Grambank v1.0)" ,
                                                                        "Çöltekin & Rama's\nmfh\n(slightly modified\nversion)_Fusion\n(Grambank v1.0)"  ,
                                                                        "Çöltekin & Rama's\nmfh\n(slightly modified\nversion)_Informativity\n(Grambank v1.0)"  
                   ),
                   hist_bins = 7, 
                   cor_test_method_exact = FALSE,
                   herringbone = T)
  
  p$p_values_df %>% 
    dplyr::mutate(
      pair_key = stringr::str_replace_all(pair_key, "\n", " "), #removing line breaks in tsv
      x = stringr::str_replace_all(x, "\n", " "), #removing line breaks in tsv
      y = stringr::str_replace_all(y, "\n", " "),
      # keep fixed-point, suppress scientific notation
      pvalue = sprintf("%.17f", pvalue)
    ) %>%   
    readr::write_tsv("output/results/correlation_dfs/correlation_df_metrics_external_Grambank_PUD.tsv", na = "")
  
  
  ggplot2::ggsave("output/plots/SPLOM_metrics_external_Grambank_PUD.png", height = 18, width = 18, units = "cm", plot = p$plot)
  
} else {
  cat("No PUD data available for SPLOM external metrics plot.\n")
}
