source("01_requirements.R")

data <- read_tsv("output/summaries/counts.tsv", show_col_types = F) %>%
  filter(sum_tokens > minimum_tokens) %>% 
  dplyr::select(dir)

data <- read_tsv("output/summaries/mean_sum_surprisal_morph_split.tsv", show_col_types = F) %>% 
  inner_join(data)

basemap +
  geom_jitter(data = data, stat = "identity", 
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
