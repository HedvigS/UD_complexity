
library(dplyr, lib.loc = "../utility/packages/")
library(magrittr, lib.loc = "../utility/packages/")

source(file = "01_requirements.R")
source("02_basemap.R")

UD_langs <- read_tsv("../data/UD_languages.tsv", show_col_types = F) %>% 
  filter(is.na(multilingual_exclude)) %>% 
  distinct(dir, glottocode) %>% 
  mutate(PUD = ifelse(str_detect(dir, pattern = "PUD"), "PUD", "NOT PUD"))

Glottolog <-read_tsv("output/processed_data/glottolog_5.0_languages.tsv", show_col_types = F) %>% 
  dplyr::rename(glottocode = Glottocode) %>% 
  dplyr::mutate(Longitude = if_else(Longitude <= -25, Longitude + 360, Longitude)) 
  

df <- read_tsv(file = "output/all_summaries_stacked.tsv", show_col_types = F) %>% 
  inner_join(UD_langs, by = "dir") %>% 
  left_join(Glottolog, by = "glottocode") %>% 
  filter(n_feat_cats_all_features != 0) %>% 
  filter(n_feat_cats_core_features_only != 0) %>% 
  distinct()

p <- basemap +
  geom_jitter(data = df, mapping = aes(x = Longitude, y = Latitude, fill = sum_surprisal_morph_split_mean_upos_all_features),
              size = 2, alpha = 0.8, width = 3.5, height=3.5, shape = 21, color = "black") +
  ggtitle("Surprisal feat, agg_level = UPOS, all features") +
  scale_fill_viridis(option = "plasma", breaks = c(1,3, 5, 7, 9, 11)) +
  theme( plot.margin = unit(c(0, 0, 0, 0), "cm") , 
         legend.position = "inside",
         legend.position.inside = c(0.7, 0.02),       # x and y in [0,1]
         legend.justification = c(1, 0),
         legend.direction = "horizontal",
         legend.title = element_blank())

ggsave(filename = "output/plots/map_sum_surprisal_morph_split_mean_upos_all_features.png",  height = 5, width = 7, plot = p)

p <- basemap +
  geom_jitter(data = df, mapping = aes(x = Longitude, y = Latitude, fill = surprisal_per_morph_featstring_mean_lemma_core_features_only), 
              size = 2, alpha = 0.8, width = 3.5, height=3.5, shape = 21, color = "black") +
  ggtitle("Surprisal featstring, agg_level = lemma, core features only")+
  scale_fill_viridis(option = "plasma", breaks = c(0, 1,2)) +
  theme( plot.margin = unit(c(0, 0, 0, 0), "cm") , 
         legend.position = "inside",
         legend.position.inside = c(0.7, 0.02),       # x and y in [0,1]
         legend.justification = c(1, 0),
         legend.direction = "horizontal",
         legend.title = element_blank())

ggsave(filename = "output/plots/map_surprisal_per_morph_featstring_mean_lemma_core_features_only.png",  height = 5, width = 7, plot = p)

########################### PUD ################################
df_PUD  <- df %>% 
  filter(str_detect(dir, pattern = "PUD"))


p <- basemap +
  geom_jitter(data = df_PUD, mapping = aes(x = Longitude, y = Latitude, fill = sum_surprisal_morph_split_mean_upos_all_features),
              size = 2, alpha = 0.8, width = 3.5, height=3.5, shape = 21, color = "black") +
  ggtitle("Surprisal feat, agg_level = UPOS, all features (PUD)")+
  scale_fill_viridis(option = "plasma", breaks = c(0,1,3, 5, 7)) +
  theme( plot.margin = unit(c(0, 0, 0, 0), "cm") , 
         legend.position = "inside",
         legend.position.inside = c(0.7, 0.02),       # x and y in [0,1]
         legend.justification = c(1, 0),
         legend.direction = "horizontal",
         legend.title = element_blank())

ggsave(filename = "output/plots/map_sum_surprisal_morph_split_mean_upos_all_features_PUD.png", height = 5, width = 7, plot = p)

basemap +
  geom_jitter(data = df_PUD, mapping = aes(x = Longitude, y = Latitude, fill = surprisal_per_morph_featstring_mean_lemma_core_features_only), 
              size = 2, alpha = 0.8, width = 3.5, height=3.5, shape = 21, color = "black") +
  ggtitle("Surprisal featstring, agg_level = lemma, core features only (PUD)")+
  scale_fill_viridis(option = "plasma", breaks = c(0,0.5, 1,2)) +
  theme( plot.margin = unit(c(0, 0, 0, 0), "cm") , 
         legend.position = "inside",
         legend.position.inside = c(0.7, 0.02),       # x and y in [0,1]
         legend.justification = c(1, 0),
         legend.direction = "horizontal",
         legend.title = element_blank())

ggsave(filename = "output/plots/map_surprisal_per_morph_featstring_mean_lemma_core_features_only_PUD.png",  height = 5, width = 7, plot = p)