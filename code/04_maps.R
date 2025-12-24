library(dplyr, lib.loc = "../utility/packages/")
library(magrittr, lib.loc = "../utility/packages/")
library(ggplot2, lib.loc = "../utility/packages/")
library(readr, lib.loc = "../utility/packages/")
library(stringr, lib.loc = "../utility/packages/")
library(viridis, lib.loc = "../utility/packages/")

source("02_basemap.R")


##################################
Glottolog <-readr::read_tsv("output/processed_data/glottolog_5.0_languages.tsv", show_col_types = F) %>% 
  dplyr::rename(glottocode = Glottocode) %>% 
  dplyr::mutate(Longitude = ifelse(Longitude <= -25, Longitude + 360, Longitude)) 

df <- readr::read_tsv("output/results/all_results.tsv", show_col_types = F)

df <- df %>% 
  dplyr::filter(n_feat_cats_all_features != 0) %>% 
  dplyr::filter(n_feat_cats_core_features_only != 0) %>% 
  dplyr::left_join(Glottolog, by = "glottocode")

# Sum surprisal morph split mean, agg level = UPOS, all features
p <- basemap +
  ggplot2::geom_jitter(data = df, mapping = ggplot2::aes(x = Longitude, y = Latitude, fill = sum_surprisal_morph_split_mean_upos_all_features),
              size = 2, alpha = 0.8, width = 3.5, height=3.5, shape = 21, color = "black") +
  ggplot2::ggtitle("morpho-surprisal / feat / UPOS / all features") +
  viridis::scale_fill_viridis(option = "plasma", breaks = c(1,3, 5, 7, 9, 11)) +
  ggplot2::theme( plot.margin = ggplot2::unit(c(0, 0, 0, 0), "cm") , 
         legend.position = "inside",
         legend.position.inside = c(0.7, 0.02),       # x and y in [0,1]
         legend.justification = c(1, 0),
         legend.direction = "horizontal",
         legend.title = ggplot2::element_blank())

ggplot2::ggsave(filename = "output/plots/map_sum_surprisal_morph_split_mean_upos_all_features.png",  height = 5, width = 7, plot = p)

# Surprisal per morph featstring mean, agg level = lemma, core features only
p <- basemap +
  ggplot2::geom_jitter(data = df, mapping = ggplot2::aes(x = Longitude, y = Latitude, fill = surprisal_per_morph_featstring_mean_lemma_core_features_only), 
              size = 2, alpha = 0.8, width = 3.5, height=3.5, shape = 21, color = "black") +
  ggplot2::ggtitle("morpho-surprisal / featstring  /  lemma / core features only")+
  viridis::scale_fill_viridis(option = "plasma", breaks = c(0, 1,2)) +
  ggplot2::theme( plot.margin = ggplot2::unit(c(0, 0, 0, 0), "cm") , 
         legend.position = "inside",
         legend.position.inside = c(0.7, 0.02),       # x and y in [0,1]
         legend.justification = c(1, 0),
         legend.direction = "horizontal",
         legend.title = ggplot2::element_blank())

ggplot2::ggsave(filename = "output/plots/map_surprisal_per_morph_featstring_mean_lemma_core_features_only.png",  height = 5, width = 7, plot = p)

########################### PUD ################################
df_PUD  <- df %>% 
  dplyr::filter(stringr::str_detect(dir, pattern = "PUD"))

# Sum surprisal morph split mean, agg level = UPOS, all features (PUD)
p <- basemap +
  ggplot2::geom_jitter(data = df_PUD, mapping = ggplot2::aes(x = Longitude, y = Latitude, fill = sum_surprisal_morph_split_mean_upos_all_features),
              size = 2, alpha = 0.8, width = 3.5, height=3.5, shape = 21, color = "black") +
  ggplot2::ggtitle("morpho-surprisal / feat / UPOS / all features (PUD)")+
  viridis::scale_fill_viridis(option = "plasma", breaks = c(0,1,3, 5, 7)) +
  ggplot2::theme( plot.margin = ggplot2::unit(c(0, 0, 0, 0), "cm") , 
         legend.position = "inside",
         legend.position.inside = c(0.7, 0.02),       # x and y in [0,1]
         legend.justification = c(1, 0),
         legend.direction = "horizontal",
         legend.title = ggplot2::element_blank())

ggplot2::ggsave(filename = "output/plots/map_sum_surprisal_morph_split_mean_upos_all_features_PUD.png", height = 5, width = 7, plot = p)

# Surprisal per morph featstring mean, agg level = lemma, core features only (PUD)
p <- basemap +
  ggplot2::geom_jitter(data = df_PUD, mapping = ggplot2::aes(x = Longitude, y = Latitude, fill = surprisal_per_morph_featstring_mean_lemma_core_features_only), 
              size = 2, alpha = 0.8, width = 3.5, height=3.5, shape = 21, color = "black") +
  ggplot2::ggtitle("morpho-surprisal / featstring  /  lemma / core features only (PUD)")+
  viridis::scale_fill_viridis(option = "plasma", breaks = c(0,0.5, 1,2)) +
  ggplot2::theme( plot.margin = ggplot2::unit(c(0, 0, 0, 0), "cm") , 
         legend.position = "inside",
         legend.position.inside = c(0.7, 0.02),       # x and y in [0,1]
         legend.justification = c(1, 0),
         legend.direction = "horizontal",
         legend.title = ggplot2::element_blank())

ggplot2::ggsave(filename = "output/plots/map_surprisal_per_morph_featstring_mean_lemma_core_features_only_PUD.png",  height = 5, width = 7, plot = p)

