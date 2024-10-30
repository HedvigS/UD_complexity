source("01_requirements.R")

data <- read_tsv("output/summaries/counts.tsv") 

data %>% arrange(desc(sum_tokens)) %>% .[1:10,] %>% write_tsv("output/summaries/top_ten.tsv")

basemap +
  geom_jitter(data = data, stat = "identity", 
             position = position_jitter(width = 2, height = 2, seed = seed #jittering the points to prevent overplotting
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
  theme(legend.position = "bottom")+
  ggtitle("Number of tokens per UD treebank v2.14")

ggsave("output/plots/map_tokens_per_UD_treebank.png", height = 5, width = 7)

data <- data %>% 
  filter(sum_tokens > 2000)

basemap +
  geom_jitter(data = data, stat = "identity", 
              position = position_jitter(width = 2, height = 2, seed = seed #jittering the points to prevent overplotting
              ),
              aes(x=Longitude, 
                  y=Latitude,
                  fill = mean_feats_per_token),
              shape = 21, 
              alpha = 0.8, 
              stroke = 0.4, 
              color = "grey44") +
  scale_fill_viridis_c(direction = -1, end = 0.9)+
  theme(legend.position = "bottom") +
  ggtitle("Mean number of morph feats per token per UD treebank v2.14")

ggsave("output/plots/map_mean_feats_per_token_per_treebank.png", height = 5, width = 7)


  