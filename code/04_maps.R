source(file = "01_requirements.R")

UD_langs <- read_tsv("../data/UD_languages.tsv", show_col_types = F) %>% 
  filter(is.na(multilingual_exclude)) %>% 
  dplyr::select(dir, glottocode)

Glottolog <-read_tsv("output/processed_data/glottolog_5.0_languages.tsv", show_col_types = F) %>% 
  dplyr::rename(glottocode = Glottocode)

df <- read_tsv(file = "output/all_summaries_stacked.tsv", show_col_types = F) %>% 
  inner_join(UD_langs, by = "dir") %>% 
  left_join(Glottolog, by = "glottocode") %>% 
  filter(n_feat_cats_all_features != 0) %>% 
  filter(n_feat_cats_core_features_only != 0) %>% 
  distinct()

basemap +
  geom_jitter(data = df, mapping = aes(x = Longitude, y = Latitude, color = sum_surprisal_morph_split_mean_upos_all_features),
              size = 2, alpha = 0.9, width = 3, height=3) +
  scale_color_viridis(end =0.9) +
  ggtitle("Surprisal feat, agg_level = UPOS, all features") +
  theme( plot.margin = unit(c(0, 0, 0, 0), "cm") )

ggsave("output/plots/map_sum_surprisal_morph_split_mean_upos_all_features.png",  height = 5, width = 7)

basemap +
  geom_jitter(data = df, mapping = aes(x = Longitude, y = Latitude, color = surprisal_per_morph_featstring_mean_lemma_core_features_only), 
              size = 2, alpha = 0.9, width = 3, height=3) +
  scale_color_viridis(end =0.9) +
  ggtitle("Surprisal featstring, agg_level = lemma, core features only")+
  theme( plot.margin = unit(c(0, 0, 0, 0), "cm") )

ggsave("output/plots/map_surprisal_per_morph_featstring_mean_lemma_core_features_only.png",  height = 5, width = 7)

########################### PUD ################################
df_PUD  <- df %>% 
  filter(str_detect(dir, pattern = "PUD"))


basemap +
  geom_jitter(data = df_PUD, mapping = aes(x = Longitude, y = Latitude, color = sum_surprisal_morph_split_mean_upos_all_features),
              size = 2, alpha = 0.9, width = 3, height=3) +
  scale_color_viridis(end =0.9) +
  ggtitle("Surprisal feat, agg_level = UPOS, all features (PUD)")+
  theme( plot.margin = unit(c(0, 0, 0, 0), "cm") )

ggsave("output/plots/map_sum_surprisal_morph_split_mean_upos_all_features_PUD.png", height = 5, width = 7)

basemap +
  geom_jitter(data = df_PUD, mapping = aes(x = Longitude, y = Latitude, color = surprisal_per_morph_featstring_mean_lemma_core_features_only), 
              size = 2, alpha = 0.9, width = 3, height=3) +
  scale_color_viridis(end =0.9) +
  ggtitle("Surprisal featstring, agg_level = lemma, core features only (PUD)")+
  theme( plot.margin = unit(c(0, 0, 0, 0), "cm") )

ggsave("output/plots/map_surprisal_per_morph_featstring_mean_lemma_core_features_only_PUD.png",  height = 5, width = 7)

