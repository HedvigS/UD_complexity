source("01_requirements.R")
source("fun_def_SPLOM_fun.R")

##################################

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
    coloured_SPLOM(text_cor_size = 5, text_strip_size = 10, 
                   hist_label_size = 3, herringbone = T,pair_colors = pal
                   )

ggsave("output/plots/SPLOM_custom_metrics.png", height = 30, width = 30, units = "cm", plot = p)

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
  coloured_SPLOM(hist_label_size = 2.3, text_cor_size = 5, text_strip_size = 6, pair_colors = pal, herringbone = T
                 )


df_for_plot %>% 
  coloured_SPLOM(hist_label_size = 2.5, text_cor_size = 5, text_strip_size = 7, herringbone = T
  )


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

pal <- c(sum_surprisal_morph_split_mean_upos_all_features_col, #1
         surprisal_per_morph_featstring_mean_lemma_core_features_only_col,   #2
         TTR_col, #3
         "#DBAC5E", #4
         "#f5dd02", #5
         "#f57f31", #6
         "grey40"
         )

p <- df_for_plot %>% 
  coloured_SPLOM(hist_label_size = 3,
                 pair_colors = pal, 
                 text_cor_size = 5, 
                 text_strip_size = 10,
                 herringbone = T,
                 col_pairs_to_constraint = c("Fusion\n(Grambank v1.0)", 
                                             "Informativity\n(Grambank v1.0)", 
                                             "Pop\n (Google)", 
                                             "Pop\n(Google)\nlog10"
                                             ), 
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
  coloured_SPLOM(pair_colors = pal, text_cor_size = 5, text_strip_size = 10, hist_label_size = 2.5, herringbone = T)

ggsave("output/plots/SPLOM_custom_metrics_PUD.png", height = 30, width = 30, units = "cm", plot = p)

df_for_plot <- df %>% 
  filter(str_detect(dir, pattern = "PUD")) %>% 
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
  coloured_SPLOM(hist_label_size = 2.3, text_cor_size = 5, text_strip_size = 7, pair_colors = pal, herringbone = T)

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
                 text_cor_size = 5, 
                 text_strip_size = 10,
                 col_pairs_to_constraint = c("Fusion\n(Grambank v1.0)", 
                                             "Informativity\n(Grambank v1.0)", 
                                             "Pop\n (Google)", 
                                             "Pop\n(Google)\nlog10"), 
                 col_pairs_constraint = "glottocode", herringbone = T)

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