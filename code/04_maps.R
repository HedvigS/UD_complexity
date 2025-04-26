source(file = "01_requirements.R")

UD_langs <- read_tsv("../data/UD_languages.tsv", show_col_types = F) %>% 
  dplyr::select(dir, glottocode)

Glottolog <-read_tsv("output/processed_data/glottolog_5.0_languages.tsv", show_col_types = F) %>% 
  dplyr::rename(glottocode = Glottocode)

df <- read_tsv(file = "output/all_summaries_stacked.tsv", show_col_types = F) %>% 
  left_join(UD_langs, by = "dir") %>% 
  left_join(Glottolog, by = "glottocode") %>% 
  filter(n_feat_cats_all_features != 0) %>% 
  filter(n_feat_cats_core_features_only != 0) %>% 
  distinct()

basemap +
  geom_jitter(data = df, mapping = aes(x = Longitude, y = Latitude, color = sum_surprisal_morph_split_mean_upos_all_features),
              size = 2.5, alpha = 0.8) +
                scale_color_viridis() +
  ggtitle("Surprisal feat, agg_level = UPOS, all features")

ggsave("output/plots/map_sum_surprisal_morph_split_mean_upos_all_features.png", height = 10, width = 12)

basemap +
  geom_jitter(data = df, mapping = aes(x = Longitude, y = Latitude, color = surprisal_per_morph_featstring_mean_lemma_core_features_only), 
                size = 2.5, alpha = 0.8) +
  scale_color_viridis() +
  ggtitle("Surprisal featstring, agg_level = lemma, core features only")

ggsave("output/plots/surprisal_per_morph_featstring_mean_lemma_core_features_only.png", height = 10, width = 12)
