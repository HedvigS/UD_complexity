source("01_requirements.R")

Glottolog <- read_tsv("../data/glottolog_language_table_wide_df_3.0.tsv", show_col_types = F) %>% 
  dplyr::select(glottocode = Glottocode, Longitude, Latitude, Family_ID, Language_level_ID, Name)

UD_lgs <- read_tsv("../data/UD_languages.tsv", show_col_types = F) 

UD_complexity <- read_tsv("output/sum_dfs/all_sum_df_means.tsv", show_col_types = F) %>% 
  mutate(conllu= basename(fn)) %>% 
  left_join(UD_lgs, by = "conllu")

UD_type_counts <- read_tsv("output/sum_dfs/all_sum_df_counts.tsv", show_col_types = F) %>% 
  mutate(conllu= basename(fn)) %>% 
  left_join(UD_lgs, by = "conllu") %>% 
  dplyr::select(conllu, n_token, n_type, n_unique_lemma, n_sentence, n_feats, fn, glottocode)


joined <- UD_complexity %>% 
  full_join(UD_type_counts, by = join_by(fn, conllu, glottocode)) %>% 
  left_join(Glottolog, by = join_by(glottocode)) %>% 
  dplyr::mutate(Longitude = if_else(Longitude <= -25, Longitude + 360, Longitude)) %>%  #shifting the longlat of the dataframe to match the pacific centered map
  arrange(n_sentence) %>% 
  group_by(Language_level_ID) %>% 
  mutate(n_sentence_per_language = sum(n_sentence))

  
#fetching datasets
world <- ggplot2::map_data('world2', 
                           wrap=c(-25,335), #rewrapping the worldmap, i.e. shifting the center. I prefer this to world2 because I like to adjust the wrapping a bit differently, and world2 results in polygons leaking
                           ylim=c(-55,90)) #cutting out antarctica (not obligatory) and the northermost part where there are no language points in glottolog

lakes <- ggplot2::map_data("lakes", 
                            wrap=c(-25,335), 
                            col="white", border="gray",  
                            ylim=c(-55,90))


#Basemap
basemap <- ggplot(joined) +
  geom_polygon(data=world, aes(x=long, #plotting the landmasses
                               y=lat,group=group),
               colour="gray90",
               fill="gray90", linewidth = 0.5) +
  geom_polygon(data=lakes, aes(x=long,#plotting lakes
                               y=lat,group=group),
               colour="gray90",
               fill="white", size = 0.3)  +
  theme(#all of theme options are set such that it makes the most minimal plot, no legend, not grid lines etc
    panel.grid.major = element_blank(), 
    panel.grid.minor = element_blank(),
    axis.title.x=element_blank(),
    axis.title.y=element_blank(),
    axis.line = element_blank(),
    panel.border = element_blank(),
    legend.position = "none",
    panel.background = element_rect(fill = "white"),
    axis.text.x = element_blank(),
    axis.text.y = element_blank(),
    axis.ticks = element_blank())   +
  coord_map(projection = "vandergrinten") + #a non-rectangular world map projection that is a decen compromise between area and distances accuracy
  ylim(-55,) #cutting out antarctica (not obligatory) 
             

#plotting the variable with small set of values and non-ordered
#this plot will have distinct color values from randomcoloR and visible legend


basemap +
  geom_point(data = distinct(joined, "Language_level_ID", .keep_all = T), stat = "identity", 
             position = position_jitter(width = 1, height = 1 #jittering the points to prevent overplotting
             ),
             aes(x=Longitude, 
                 y=Latitude,
                 size = n_sentence_per_language,
                 fill = n_sentence_per_language),
             shape = 21, 
             alpha = 0.8, 
             stroke = 0.4, 
             color = "grey44") +
  scale_fill_viridis_c(direction = -1)

ggsave("output/plots/map_sentences_per_language.png")

joined %>% 
distinct(n_sentence_per_language, Language_level_ID, Name) %>% 
  arrange(desc(n_sentence_per_language)) %>% 
  .[1:10,]


basemap +
  geom_point(position = position_jitter(width = 1, height = 1 #jittering the points to prevent overplotting
             ),
             aes(x=Longitude, 
                 y=Latitude,
                 size = n_feats_per_sent_mean,
                 fill = n_feats_per_sent_mean),
             shape = 21, 
             alpha = 0.8, 
             stroke = 0.4, 
             color = "grey44") +
  scale_fill_viridis_c(direction = -1)


ggsave("output/plots/map_feats_per_sentence.png")


basemap +
  geom_point(position = position_jitter(width = 1, height = 1 #jittering the points to prevent overplotting
  ),
  aes(x=Longitude, 
      y=Latitude,
      size = n_feats_per_token_mean,
      fill = n_feats_per_token_mean),
  shape = 21, 
  alpha = 0.8, 
  stroke = 0.4, 
  color = "grey44") +
  scale_fill_viridis_c(direction = -1)


ggsave("output/plots/map_feats_per_token.png")
