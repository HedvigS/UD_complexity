source("01_requirements.R")
source("fun_def_SPLOM_fun.R")

df <- read_tsv(file = "output/all_summaries_stacked.tsv", show_col_types = F)

df_for_plot <- df %>% 
  dplyr::select("Surprisal feat\nagg_level = lemma\nall features" = "sum_surprisal_morph_split_mean_lemma_all_features"  ,         
                "Surprisal feat\nagg_level = lemma\ncore features only"  = "sum_surprisal_morph_split_mean_lemma_core_features_only"    ,  
                "Surprisal feat\nagg_level = UPOS\nall features" = "sum_surprisal_morph_split_mean_upos_all_features" ,           
                "Surprisal feat\nagg_level = UPOS\ncore features only" = "sum_surprisal_morph_split_mean_upos_core_features_only"   ,    
                "Surprisal featstring\nagg_level = lemma\nall features" = "surprisal_per_morph_featstring_mean_lemma_all_features" ,     
                "Surprisal featstring\nagg_level = lemma\ncore features only" =  "surprisal_per_morph_featstring_mean_lemma_core_features_only",
                "Surprisal featstring\nagg_level = UPOS\nall features" = "surprisal_per_morph_featstring_mean_upos_all_features",       
                "Surprisal featstring\nagg_level = UPOS\ncore features only" = "surprisal_per_morph_featstring_mean_upos_core_features_only" ) 

colors <-  c("#E55679", "#5FE3B6", "#D447A0", "#B1E586", "#D8A8DE", "#E5E145", "#63E580", "#74E1DA", "#889C8B", "#94E949", "#E58F8F", "#DC8F3D", "#7295CF", "#C6E5E9", "#699D55", "#64BFDB", "#E489D4", "#8E7CE0", "#7045D9", "#9A6E7E", "#E2E0C7", "#D6AF87", "#D03AE7", "#BABFE5", "#D567DD", "#C0E7B5", "#D9D377", "#E7C3D1")

  
p <-  df_for_plot %>% 
    coloured_SPLOM(pair_colors = colors)

ggsave("output/plots/SPLOM_custom_metrics.png", height = 30, width = 30, units = "cm", plot = p)




df_for_plot <- df %>% 
  dplyr::select("Surprisal feat\nagg_level = lemma\ncore features only"  = "sum_surprisal_morph_split_mean_lemma_core_features_only"    ,  
                "Surprisal feat\nagg_level = UPOS\nall features" = "sum_surprisal_morph_split_mean_upos_all_features" ,           
                "Surprisal featstring\nagg_level = lemma\ncore features only" =  "surprisal_per_morph_featstring_mean_lemma_core_features_only",
                "Surprisal featstring\nagg_level = UPOS\nall features" = "surprisal_per_morph_featstring_mean_upos_all_features", 
                "n_types", 
                "n_tokens",
                "n_sentences" ,
                "TTR",
                "LTR"   ,
            #    "n_feat_cats_all_features",                                    
            #     "n_feat_cats_core_features_only",                               
                "n_feats_per_token_mean_all_features",                         
                "n_feats_per_token_mean_core_features_only"
            ) 


p <-  df_for_plot %>% 
  coloured_SPLOM(hist_label_size = 2.5)

ggsave("output/plots/SPLOM_other_metrics.png", height = 30, width = 30, units = "cm", plot = p)


df_for_plot <- df %>% 
  dplyr::select(#"Surprisal feat\nagg_level = lemma\ncore features only"  = "sum_surprisal_morph_split_mean_lemma_core_features_only"    ,  
                #"Surprisal feat\nagg_level = UPOS\nall features" = "sum_surprisal_morph_split_mean_upos_all_features" ,           
                #"Surprisal featstring\nagg_level = lemma\ncore features only" =  "surprisal_per_morph_featstring_mean_lemma_core_features_only",
                #"Surprisal featstring\nagg_level = UPOS\nall features" = "surprisal_per_morph_featstring_mean_upos_all_features", 
                #"n_types", 
                #"n_tokens",
                #"n_sentences" ,
                "TTR",
                "LTR"   ,
                    "n_feat_cats_all_features",                                    
                     "n_feat_cats_core_features_only",                               
                "n_feats_per_token_mean_all_features",                         
                "n_feats_per_token_mean_core_features_only"
  ) 


p <-  df_for_plot %>% 
  coloured_SPLOM(hist_label_size = 2.5)
p
