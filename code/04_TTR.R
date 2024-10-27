source("01_requirements.R")

Glottolog <- read_tsv("../data/glottolog_language_table_wide_df_3.0.tsv", show_col_types = F) %>% 
  dplyr::select(glottocode = Glottocode, Longitude, Latitude, Family_ID, Language_level_ID, Name)

UD_langs <- read_tsv("../data/UD_languages.tsv", show_col_types = F) %>% 
  dplyr::select(dir,  glottocode)

fns <- list.files("output/TTR/", pattern = "sum.tsv", full.names = T)

stacked <- SH.misc::stack_tsvs(fns = fns) 

stacked <- stacked %>% 
  rename(dir = fn)

stacked <- stacked %>% 
  left_join(UD_langs) %>% 
  left_join(Glottolog) %>% 
  distinct() %>% 
  dplyr::mutate(Longitude = if_else(Longitude <= -25, Longitude + 360, Longitude))  #shifting the longlat 


basemap +
  geom_jitter(data = stacked, stat = "identity", 
              position = position_jitter(width = 2, height = 2, seed = 198 #jittering the points to prevent overplotting
              ),
              aes(x=Longitude, 
                  y=Latitude,
                  fill = TTR),
              shape = 21, 
              alpha = 0.8, 
              stroke = 0.4, 
              color = "grey44") +
  scale_fill_viridis_c(direction = -1, end = 0.9) +
  ggtitle("Type-Token-Ratio per UD treebank v2.14")


ggsave("output/plots/map_TTR_per_UD_treebank.png", height = 5, width = 7)
