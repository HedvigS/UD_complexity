source("01_requirements.R")

google_pop_stats <- read_tsv("https://raw.githubusercontent.com/google-research/url-nlp/refs/heads/main/linguameta/linguameta.tsv", show_col_types = F) %>% 
  dplyr::select(glottocode, Pop = estimated_number_of_speakers) %>% 
  filter(!is.na(glottocode)) %>% 
  filter(!is.na(Pop))
  
google_pop_stats %>%  
  write_tsv("output/processed_data/google_pop.tsv")

df <- google_pop_stats %>% 
  left_join(Glottolog, by = "glottocode")

basemap +
  geom_jitter(data = df, mapping = aes(x = Longitude, y = Latitude, size = Pop, color = log10(Pop))) +
#  theme(plot.margin = unit(c(0,0,0,0), "cm")) +
  ggtitle("Speaker population per language from Google's LinguaMeta-project \n(github.com/google-research/url-nlp)")

ggsave("output/plots/google_pop_map.png", height = 10, width = 12)
