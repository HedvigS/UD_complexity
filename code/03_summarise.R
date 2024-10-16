source("01_requirements.R")

Glottolog_table_long_shifted <- read_tsv("../data/glottolog_language_table_wide_df_3.0.tsv", show_col_types = F) %>% 
  dplyr::select(glottocode = Glottocode, Longitude, Latitude) %>% 
  mutate(Longitude = if_else(Longitude <= -25, Longitude + 360, Longitude)) #shifting the longlat of the dataframe to match the pacific centered map

fns <- list.files(path = "output/UD_conllu/", pattern = "_summarised.tsv", recursive = T, full.names = T)

fns <- fns[1:300]

all_raw <- fns %>% 
  map_df(
    function(x) data.table::fread(x ,
                                  encoding = 'UTF-8', header = TRUE, 
                                  fill = TRUE, blank.lines.skip = TRUE,
                                  sep = "\t", na.strings = "",
    )   %>% 
      mutate(across(everything(), as.character)) %>% 
      mutate(filename = basename(x)) %>% 
      mutate(conllu = str_replace(filename, "_summarised.tsv", ""))
  ) 

UD_langs <- read_tsv("../data/UD_languages.tsv", show_col_types = F) %>% 
  separate(glottocode, into = c("glottocode", "glottocode2"), sep = "; ")

all <- all_raw %>% 
  mutate(feats_n = as.numeric(feats_n)) %>% 
  mutate(feats_ratio_sentence = as.numeric(feats_ratio_sentence)) %>%
  mutate(feats_per_token = as.numeric(feats_per_token)) %>%
  left_join(UD_langs, by = "conllu") 

df <- all %>% 
  group_by(glottocode) %>% 
  summarise(n = n()) %>% 
  left_join(Glottolog_table_long_shifted)

basemap <- SH.misc::basemap_EEZ(south = "down", colour_land = "whitesmoke", colour_border_land = "whitesmoke", colour_border_eez = "lightgray",colour_ocean_EEZ = "lightgray", padding = 0, colour_ocean = "gray") +
  viridis::scale_color_viridis(direction = 1) +
  viridis::scale_fill_viridis(direction = 1) 
  
basemap +
  geom_jitter(data = df, aes(x = Longitude, y = Latitude, color = n ,fill = n, size = n), alpha = 0.6, linewidth = 3) +
  ggtitle("Sentences per language")

ggsave("output/plots/map_sentences_per_lg.png", height = 9, width = 8)


all %>% 
  mutate()

all <- all %>% 
  filter(!is.na(feats_ratio_sentence)) %>% 
  group_by(glottocode) %>% 
  mutate(mean_feats_ratio_sentence = mean(feats_ratio_sentence)) %>% 
  mutate()


all$glottocode <- forcats::fct_reorder(all$glottocode, all$mean)

all %>%
  ggplot() +
  ggridges::geom_density_ridges(aes(x = feats_ratio_sentence, y = glottocode, fill = mean) , bandwidth =  0.116) +
  theme_classic() +
  theme(axis.text.y = element_blank(), 
        legend.position = "none", 
        axis.title.y = element_blank()) +
  viridis::scale_fill_viridis() +
  viridis::scale_color_viridis()

ggsave("output/plots/ridgeplot_feats_ratio_sentence.png", width = 7, height = 7)


all_means <- all %>% 
  distinct(glottocode, mean_feats_ratio_sentence) %>% 
  left_join(Glottolog_table_long_shifted)

all_means %>% 
  write_tsv("output/processed_data/df_means_feats_per_token_per_sentence.tsv")

basemap +
  geom_jitter(data = all_means, aes(x = Longitude, y = Latitude, color = mean ,fill = mean), alpha = 0.6, size = 2, shape = 21) +
  ggtitle("Tokens per sentence per language mean")

ggsave("output/plots/map_feats_per_token_per_sentence.png", height = 9, width = 8)

