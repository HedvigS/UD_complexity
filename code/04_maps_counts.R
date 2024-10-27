source("01_requirements.R")

Glottolog <- read_tsv("../data/glottolog_language_table_wide_df_3.0.tsv", show_col_types = F) %>% 
  dplyr::select(glottocode = Glottocode, Longitude, Latitude, Family_ID, Language_level_ID, Name)

UD_langs <- read_tsv("../data/UD_languages.tsv", show_col_types = F) %>% 
  dplyr::select(dir,  glottocode)

fns <- list.files("output/counts/", pattern = ".tsv", full.names = T)

df_all <- data.frame(dir = as.character(), 
                     n_sentences = as.numeric(),
                     sum_tokens = as.numeric(), 
                     mean_feats_per_token =  as.numeric())

for(i in 1:length(fns)){
 # i <- 13
  fn <- fns[i]
  dir <- fn %>% basename() %>% str_replace_all(".tsv", "") %>% str_replace_all("counts_", "") %>% str_replace_all("_summarised", "")
  df <- read_tsv(fn, show_col_types = F)
  n_sentences <- nrow(df)

  df_unnested <- df %>% 
    mutate(feats_per_token = str_split(feats_per_token, ";")) %>% 
    unnest(feats_per_token) 
  
  df_spec <- data.frame(dir = dir, 
                        n_sentences =nrow(df),
                         sum_tokens = sum(df$n_tokens), 
                         mean_feats_per_token =  mean(as.numeric(df_unnested$feats_per_token))
                        )
  
  df_all <- df_spec %>% 
    full_join(df_all, by = join_by(dir, n_sentences, sum_tokens, mean_feats_per_token))
  
}

joined <- df_all %>% 
  left_join(UD_langs, relationship = "many-to-many", by = "dir") %>% 
  left_join(Glottolog, by = "glottocode") %>% 
  distinct(dir, n_sentences, sum_tokens, mean_feats_per_token, glottocode, Longitude, Latitude) %>% 
  dplyr::mutate(Longitude = if_else(Longitude <= -25, Longitude + 360, Longitude))  #shifting the longlat 

basemap +
  geom_jitter(data = joined, stat = "identity", 
             position = position_jitter(width = 2, height = 2 #jittering the points to prevent overplotting
             ),
             aes(x=Longitude, 
                 y=Latitude,
                 size = sum_tokens,
                 fill = sum_tokens),
             shape = 21, 
             alpha = 0.7, 
             stroke = 0.5, 
             color = "grey44") +
  scale_fill_viridis_c(direction = -1, end = 0.9) +
  ggtitle("Number of tokens per UD treebank v2.14")

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
  ggtitle("Mean number of morph feats per token per UD treebank v2.14")

ggsave("output/plots/map_mean_feats_per_token_per_treebank.png", height = 5, width = 7)

