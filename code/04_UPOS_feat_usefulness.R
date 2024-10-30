source("01_requirements.R")

summed <- read_tsv("output/summaries/UPOS_prop.tsv", show_col_types = F)

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
  filter(upos =="VERB") %>% 
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
  ggtitle("Usefulness of VERB number marking, UD treebank v2.14")

ggsave("output/plots/map_usefulness_verb_number.png",height = 5, width = 7)



