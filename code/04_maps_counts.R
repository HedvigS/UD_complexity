source("01_requirements.R")

Glottolog <- read_tsv("../data/glottolog_language_table_wide_df_3.0.tsv", show_col_types = F) %>% 
  dplyr::select(glottocode = Glottocode, Longitude, Latitude, Family_ID, Language_level_ID, Name)

UD_langs <- read_tsv("../data/UD_languages.tsv", show_col_types = F) %>% 
  dplyr::select(dir, conllu, glottocode)

fns <- list.files("output/counts/", pattern = ".tsv", full.names = T)

df_all <- data.frame(dir = as.character(), 
                     sentences = as.numeric(),
                     sum_tokens = as.numeric(), 
                     mean_feats_per_token)

for(i in 1:length(fns)){
  i <- 1
  fn <- fns[1]
  dir <- fn %>% basename() %>% str_replace_all(".tsv", "")
  df <- read_tsv(fn)
  n_sentences <- nrow(df)

  df_unnested <- df %>% 
    mutate(feats_per_token = str_split(feats_per_token, ";")) %>% 
    unnest(feats_per_token) 
  
  mean_feats_per_token <- mean(df_unnested$feats_per_token)
  
}

mean_feats_per_token_per_lang <-  counts_unnested %>% 
  full_join(UD_langs, relationship = "many-to-many", by = "dir") %>% 
  mutate(feats_per_token = as.numeric(feats_per_token)) %>% 
  group_by(glottocode) %>% 
    summarise(mean_feats_per_token = mean(feats_per_token))

joined <- counts_df %>% 
  full_join(UD_langs, relationship = "many-to-many", by = "dir") %>% 
  group_by(glottocode) %>% 
  summarise(sum_tokens = sum(n_tokens), .groups = "drop") %>% 
  left_join(mean_feats_per_token_per_lang, by = join_by(glottocode)) %>% 
  left_join(Glottolog, by = "glottocode") %>% 
  dplyr::mutate(Longitude = if_else(Longitude <= -25, Longitude + 360, Longitude))  #shifting the longlat 

basemap <- SH.misc::basemap_EEZ(, south = "down", colour_border_land = "white", colour_border_eez = "lightgray") 

basemap +
  geom_jitter(data = joined, stat = "identity", 
             position = position_jitter(width = 2, height = 2 #jittering the points to prevent overplotting
             ),
             aes(x=Longitude, 
                 y=Latitude,
                 size = sum_tokens,
                 fill = sum_tokens),
             shape = 21, 
             alpha = 0.8, 
             stroke = 0.4, 
             color = "grey44") +
  scale_fill_viridis_c(direction = -1) +
  ggtitle("Tokens per language (across different UD-collections)")

ggsave("output/plots/map_tokens_per_language.png", height = 5, width = 7)

basemap +
  geom_jitter(data = joined, stat = "identity", 
              position = position_jitter(width = 2, height = 2 #jittering the points to prevent overplotting
              ),
              aes(x=Longitude, 
                  y=Latitude,
                  fill = mean_feats_per_token),
              shape = 21, 
              alpha = 0.8, 
              stroke = 0.4, 
              color = "grey44") +
  scale_fill_viridis_c(direction = -1)  +
  ggtitle("Mean number of morph feats per token per language (across different UD-collections)")

ggsave("output/plots/map_mean_feats_per_token_per_language.png", height = 5, width = 7)

