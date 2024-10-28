source("01_requirements.R")

Glottolog <- read_tsv("../data/glottolog_language_table_wide_df_3.0.tsv", show_col_types = F) %>% 
  dplyr::select(glottocode = Glottocode, Longitude, Latitude, Family_ID, Language_level_ID, Name) %>% 
  dplyr::mutate(Longitude = if_else(Longitude <= -25, Longitude + 360, Longitude))  #shifting the longlat 


UD_langs <- read_tsv("../data/UD_languages.tsv", show_col_types = F) %>% 
  dplyr::select(dir,  glottocode)

fns <- list.files("output/surprisal_per_feat_per_UPOS_lookup/",  full.names = T)

stacked <- SH.misc::stack_tsvs(fns = fns)

stacked$dir <-   stacked$filename%>% basename() %>% str_replace_all(".tsv", "") %>% str_replace_all("surprisal_per_feat_per_UPOS_lookup_", "") 


summed <- stacked %>% 
  filter(feat_value != "unassigned") %>% 
  dplyr::select(dir, upos, feat, feat_value, n) %>%
  group_by(dir, upos, feat) %>% 
  mutate(sum = sum(n)) %>% 
  ungroup() %>% 
  mutate(prop = n/sum) %>% 
  group_by(dir, upos, feat) %>% 
  slice_max(prop) %>% 
  left_join(UD_langs, relationship = "many-to-many", by = "dir") %>% 
  left_join(Glottolog, relationship = "many-to-many", by ="glottocode")

Adj_polar_df <- summed %>% 
  filter(upos =="ADJ") %>% 
  filter(feat =="Polarity") 

basemap +
  geom_jitter(data = Adj_polar_df, stat = "identity", 
              position = position_jitter(width = 2, height = 2, seed = 198 #jittering the points to prevent overplotting
              ),
              aes(x=Longitude, 
                  y=Latitude,
                  fill = prop),
              shape = 21, 
              alpha = 0.8, 
              stroke = 0.4, 
              color = "grey44") +
  scale_fill_viridis_c(direction = -1, end = 0.9) +
  theme(legend.position = "bottom") +
  ggtitle("Usefulness of ADJ polarity marking, UD treebank v2.14")

ggsave("output/plots/map_usefulness_ADJ_polar.png")

  


Noun_num_df <- summed %>% 
  filter(upos =="NOUN") %>% 
  filter(feat =="Number") 


basemap +
  geom_jitter(data = Noun_num_df , stat = "identity", 
              position = position_jitter(width = 2, height = 2, seed = 198 #jittering the points to prevent overplotting
              ),
              aes(x=Longitude, 
                  y=Latitude,
                  fill = prop),
              shape = 21, 
              alpha = 0.8, 
              stroke = 0.4, 
              color = "grey44") +
  scale_fill_viridis_c(direction = -1) +
  theme(legend.position = "bottom") +
  ggtitle("Usefulness of NOUN number marking, UD treebank v2.14")

ggsave("output/plots/map_usefulness_noun_number.png")
