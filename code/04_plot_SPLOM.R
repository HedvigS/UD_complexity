source("01_requirements.R")
source("fun_def_SPLOM_fun.R")

UD_langs <- read_tsv("../data/UD_languages.tsv", show_col_types = F) %>% 
  dplyr::select(dir, glottocode)

df_external <- read_tsv("output/processed_data/grambank_theo_scores.tsv", show_col_types = F) %>% 
  rename(glottocode = Language_ID) %>% 
  full_join(read_tsv("output/processed_data/google_pop.tsv", show_col_types = F), by = "glottocode")

df <- read_tsv(file = "output/all_summaries_stacked.tsv", show_col_types = F) %>% 
  left_join(UD_langs, by = "dir") %>% 
  left_join(df_external, by = "glottocode") %>% 
  filter(n_feat_cats_all_features != 0) %>% 
  filter(n_feat_cats_core_features_only != 0) %>% 
  distinct()

df_for_plot <- df %>% 
  dplyr::select("Surprisal feat\nagg_level = lemma\nall features" = "sum_surprisal_morph_split_mean_lemma_all_features"  ,         
                "Surprisal feat\nagg_level = lemma\ncore features only"  = "sum_surprisal_morph_split_mean_lemma_core_features_only"    ,  
                "Surprisal feat\nagg_level = UPOS\nall features" = "sum_surprisal_morph_split_mean_upos_all_features" ,           
                "Surprisal feat\nagg_level = UPOS\ncore features only" = "sum_surprisal_morph_split_mean_upos_core_features_only"   ,    
                "Surprisal featstring\nagg_level = lemma\nall features" = "surprisal_per_morph_featstring_mean_lemma_all_features" ,     
                "Surprisal featstring\nagg_level = lemma\ncore features only" =  "surprisal_per_morph_featstring_mean_lemma_core_features_only",
                "Surprisal featstring\nagg_level = UPOS\nall features" = "surprisal_per_morph_featstring_mean_upos_all_features",       
                "Surprisal featstring\nagg_level = UPOS\ncore features only" = "surprisal_per_morph_featstring_mean_upos_core_features_only" ) 

colors <-  c("#E55679", "#5FE3B6", "#D447A0", "#B1E586", "#D8A8DE", "#E5E145", "#63E580", "#74E1DA", "#889C8B", "#94E949", "#E58F8F", "#DC8F3D", "#7295CF", "#C6E5E9", "#699D55", "#64BFDB", "#E489D4", "#8E7CE0", "#7045D9", "#9A6E7E", "#E2E0C7", "#D6AF87", "#D03AE7", "#BABFE5", "#D567DD", "#C0E7B5", "#E7C3D1", "#D9D377")

p <- df_for_plot %>% 
    coloured_SPLOM(pair_colors = colors, text_cor_size = 5, text_strip_size = 10, hist_label_size = 2.5)

ggsave("output/plots/SPLOM_custom_metrics.png", height = 30, width = 30, units = "cm", plot = p)

df_for_plot <- df %>% 
  dplyr::select("Surprisal feat\nagg_level = UPOS\nall features" = "sum_surprisal_morph_split_mean_upos_all_features" , 
                "Surprisal featstring\nagg_level = lemma\ncore features only" = "surprisal_per_morph_featstring_mean_lemma_core_features_only",
                "Types (n)" = "n_types", 
                "Tokens (n) " = "n_tokens",
                "Sentences (n)" = "n_sentences" ,
                "TTR",
                "LTR"   ,
                "Feat cat (n)\nall features" = "n_feat_cats_all_features",                                    
                "Feat cat (n)\ncore features only" = "n_feat_cats_core_features_only",                               
                "Feats per token(n)(mean)\nall features" = "n_feats_per_token_mean_all_features",                         
                "Feats per token(n)(mean)\ncore features only" ="n_feats_per_token_mean_core_features_only"
            ) 


colors <-  c("#CBF1B5", "#E6ADC8", "#8A41A4", "#5C65DF", "#E276D7", "#69B9DE", "#6271B8", "#559EE8", "#A8BFEF", "#61E66C", "#5CE896", "#EDE9A9", "#E581B4", "#5BE939", "#E9B2A8", "#7E34E2", "#D2F62E", "#9BCF89", "#B08CE6", "#B4ECDF", "#B1AE8A", "#E0EC7F", "#A39C9D", "#94EDC0", "#E0EDCE", "#C7AFE5", "#44A96B", "#93605C", "#53725B", "#BCB5CA", "#7BB79F", "#959747", "#E547DA", "#ECD5EC", "#B0EA56", "#50748D", "#59DDDA", "#E68992", "#A177AA", "#E3C763", "#4FEAC5", "#E0A967", "#CE4086", "#7CB633", "#E2CAA0", "#E85158", "#E0EEF1", "#E48449", "#B55DE3", "#89DCEA", "#E7A1E5", "#EDDED2", "#B6D3E2", "#A0E981", "#E6DF41")

p <-  df_for_plot %>% 
  coloured_SPLOM(hist_label_size = 2.5, text_cor_size = 5, text_strip_size = 6, pair_colors = colors)

ggsave("output/plots/SPLOM_other_metrics.png", height = 30, width = 30, units = "cm", plot = p)

df_for_plot <- df %>% 
  dplyr::select("glottocode",
                "Surprisal feat\nagg_level = UPOS\nall features" = "sum_surprisal_morph_split_mean_upos_all_features" , 
                "Surprisal featstring\nagg_level = lemma\ncore features only" =  "surprisal_per_morph_featstring_mean_lemma_core_features_only", 
                "TTR",
                "Fusion\n(Grambank v1.0)" = "Fusion", 
                "Informativity\n(Grambank v1.0)" ="Informativity",
                "Pop\n (Google)" = "Pop"
  )  %>% 
  mutate("Pop\n(Google)\nlog10" = log10(`Pop\n (Google)` +1)) %>% 
  distinct()

colors <-  c("#E55679", "#5FE3B6", "#D447A0", "#B1E586", "#D8A8DE", "#E5E145", "#63E580", "#74E1DA", "#889C8B", "#94E949", "#E58F8F", "#DC8F3D", "#7295CF", "#C6E5E9", "#699D55", "#64BFDB", "#E489D4", "#8E7CE0", "#7045D9", "#9A6E7E", "#E2E0C7")

p <-df_for_plot %>% 
  coloured_SPLOM(hist_label_size = 3,
                 pair_colors = colors, 
                 text_cor_size = 5, 
                 text_strip_size = 10,
                 col_pairs_to_constraint = c("Fusion", "Informativity", "Pop\n (Google)", "Pop\n(Google)\nlog10"), 
                 col_pairs_constraint = "glottocode")

ggsave("output/plots/SPLOM_metrics_external.png", height = 30, width = 30, units = "cm", plot = p)


###PUD

df_for_plot <- df %>% 
  filter(str_detect(dir, pattern = "PUD")) %>% 
  dplyr::select("Surprisal feat\nagg_level = lemma\nall features" = "sum_surprisal_morph_split_mean_lemma_all_features"  ,         
                "Surprisal feat\nagg_level = lemma\ncore features only"  = "sum_surprisal_morph_split_mean_lemma_core_features_only"    ,  
                "Surprisal feat\nagg_level = UPOS\nall features" = "sum_surprisal_morph_split_mean_upos_all_features" ,           
                "Surprisal feat\nagg_level = UPOS\ncore features only" = "sum_surprisal_morph_split_mean_upos_core_features_only"   ,    
                "Surprisal featstring\nagg_level = lemma\nall features" = "surprisal_per_morph_featstring_mean_lemma_all_features" ,     
                "Surprisal featstring\nagg_level = lemma\ncore features only" =  "surprisal_per_morph_featstring_mean_lemma_core_features_only",
                "Surprisal featstring\nagg_level = UPOS\nall features" = "surprisal_per_morph_featstring_mean_upos_all_features",       
                "Surprisal featstring\nagg_level = UPOS\ncore features only" = "surprisal_per_morph_featstring_mean_upos_core_features_only" ) 

colors <-  c("#E55679", "#5FE3B6", "#D447A0", "#B1E586", "#D8A8DE", "#E5E145", "#63E580", "#74E1DA", "#889C8B", "#94E949", "#E58F8F", "#DC8F3D", "#7295CF", "#C6E5E9", "#699D55", "#64BFDB", "#E489D4", "#8E7CE0", "#7045D9", "#9A6E7E", "#E2E0C7", "#D6AF87", "#D03AE7", "#BABFE5", "#D567DD", "#C0E7B5", "#E7C3D1", "#D9D377")

p <- df_for_plot %>% 
  coloured_SPLOM(pair_colors = colors, text_cor_size = 5, text_strip_size = 10, hist_label_size = 2.5)

ggsave("output/plots/SPLOM_custom_metrics_PUD.png", height = 30, width = 30, units = "cm", plot = p)

df_for_plot <- df %>% 
  filter(str_detect(dir, pattern = "PUD")) %>% 
  dplyr::select("Surprisal feat\nagg_level = UPOS\nall features" = "sum_surprisal_morph_split_mean_upos_all_features" , 
                "Surprisal featstring\nagg_level = lemma\ncore features only" = "surprisal_per_morph_featstring_mean_lemma_core_features_only",
                "Types (n)" = "n_types", 
                "Tokens (n) " = "n_tokens",
                #"Sentences (n)" = "n_sentences" ,
                "TTR",
                "LTR"   ,
                "Feat cat (n)\nall features" = "n_feat_cats_all_features",                                    
                "Feat cat (n)\ncore features only" = "n_feat_cats_core_features_only",                               
                "Feats per token(n)(mean)\nall features" = "n_feats_per_token_mean_all_features",                         
                "Feats per token(n)(mean)\ncore features only" ="n_feats_per_token_mean_core_features_only"
  ) 


colors <-  c("#CBF1B5", "#E6ADC8", "#8A41A4", "#5C65DF", "#E276D7", "#69B9DE", "#6271B8", "#559EE8", "#A8BFEF", "#61E66C", "#5CE896", "#EDE9A9", "#E581B4", "#5BE939", "#E9B2A8", "#7E34E2", "#D2F62E", "#9BCF89", "#B08CE6", "#B4ECDF", "#B1AE8A", "#E0EC7F", "#A39C9D", "#94EDC0", "#E0EDCE", "#C7AFE5", "#44A96B", "#93605C", "#53725B", "#BCB5CA", "#7BB79F", "#959747", "#E547DA", "#ECD5EC", "#B0EA56", "#50748D", "#59DDDA", "#E68992", "#A177AA", "#E3C763", "#4FEAC5", "#E0A967", "#CE4086", "#7CB633", "#E2CAA0")

p <-  df_for_plot %>% 
  coloured_SPLOM(hist_label_size = 2.5, text_cor_size = 5, text_strip_size = 6, pair_colors = colors)

ggsave("output/plots/SPLOM_other_metrics_PUD.png", height = 30, width = 30, units = "cm", plot = p)

df_for_plot <- df %>% 
  filter(str_detect(dir, pattern = "PUD")) %>% 
  dplyr::select("glottocode",
                "Surprisal feat\nagg_level = UPOS\nall features" = "sum_surprisal_morph_split_mean_upos_all_features" , 
                "Surprisal featstring\nagg_level = lemma\ncore features only" =  "surprisal_per_morph_featstring_mean_lemma_core_features_only", 
                "TTR",
                "Fusion\n(Grambank v1.0)" = "Fusion", 
                "Informativity\n(Grambank v1.0)" ="Informativity",
                "Pop\n (Google)" = "Pop"
  )  %>% 
  mutate("Pop\n(Google)\nlog10" = log10(`Pop\n (Google)` +1)) %>% 
  distinct()

colors <-  c("#E55679", "#5FE3B6", "#D447A0", "#B1E586", "#D8A8DE", "#E5E145", "#63E580", "#74E1DA", "#889C8B", "#94E949", "#E58F8F", "#DC8F3D", "#7295CF", "#C6E5E9", "#699D55", "#64BFDB", "#E489D4", "#8E7CE0", "#7045D9", "#9A6E7E", "#E2E0C7")

p <-df_for_plot %>% 
  coloured_SPLOM(hist_label_size = 3,
                 pair_colors = colors, 
                 text_cor_size = 5, 
                 text_strip_size = 10,
                 col_pairs_to_constraint = c("Fusion", "Informativity", "Pop\n (Google)", "Pop\n(Google)\nlog10"), 
                 col_pairs_constraint = "glottocode")

ggsave("output/plots/SPLOM_metrics_external_PUD.png", height = 30, width = 30, units = "cm", plot = p)



#df_check <- df %>% 
#  distinct(glottocode, Fusion, Pop) 
  
#df_check <- df_check[complete.cases(df_check),]
  
#nrow(df_check)

#df_check %>% 
#  ggplot(aes(x = Fusion, y = Pop)) +
#  geom_point() +
#  ggpubr::stat_cor(method = "pearson", p.digits = 2, geom = "label", color = "blue",
#                   label.y.npc="top", label.x.npc = "left", alpha = 0.8) 