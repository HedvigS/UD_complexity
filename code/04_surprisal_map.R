source("01_requirements.R")

Glottolog <- read_tsv("../data/glottolog_language_table_wide_df_3.0.tsv", show_col_types = F) %>% 
  dplyr::select(glottocode = Glottocode, Longitude, Latitude, Family_ID, Language_level_ID, Name)

UD_langs <- read_tsv("../data/UD_languages.tsv", show_col_types = F) %>% 
  dplyr::select(dir,  glottocode)

fns <- list.files("output/surprisal_per_feat_per_lemma/",  full.names = T)

df_all <- data.frame(dir = as.character(), 
                    mean_sum_surprisal_morph_split = as.numeric())

for(i in 1:length(fns)){
  
  #  i <- 1
  fn <- fns[i]
  dir <- fn %>% basename() %>% str_replace_all(".tsv", "") %>% str_replace_all("surprisal_per_feat_per_lemma_", "") 
  
  df <- read_tsv(fn, show_col_types = F)
  
df_spec <- data.frame( mean_sum_surprisal_morph_split=  df$sum_surprisal_morph_split %>% mean(), 
                       dir = dir)

df_all <- full_join(df_spec, df_all, by = join_by(mean_sum_surprisal_morph_split, dir))

}

joined <- df_all %>% 
  left_join(UD_langs) %>% 
  left_join(Glottolog) %>% 
  distinct() %>% 
  dplyr::mutate(Longitude = if_else(Longitude <= -25, Longitude + 360, Longitude))  #shifting the longlat 

basemap +
  geom_jitter(data = joined, stat = "identity", 
              position = position_jitter(width = 2, height = 2, seed = 198 #jittering the points to prevent overplotting
              ),
              aes(x=Longitude, 
                  y=Latitude,
                  fill = mean_sum_surprisal_morph_split),
              shape = 21, 
              alpha = 0.8, 
              stroke = 0.4, 
              color = "grey44") +
  scale_fill_viridis_c(direction = -1, end = 0.9) +
  ggtitle("Mean surprisal per token of split morph tags given lemma per UD treebank v2.14")



ggsave("output/plots/map_surprisal_per_feat_per_lemma_UD_treebank.png", height = 5, width = 7)
