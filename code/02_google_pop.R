source("01_requirements.R")

if(!file.exists("output/processed_data/google_pop.tsv")){

Glottolog <-read_tsv("output/processed_data/glottolog_5.0_languages.tsv", show_col_types = F) %>% 
  dplyr::rename(glottocode = Glottocode)
  
google_pop_stats <- read_tsv("https://github.com/google-research/url-nlp/raw/2bb52571b91601092df2e821969f6a974424666d/linguameta/linguameta.tsv", show_col_types = F) %>% 
  dplyr::select(glottocode, Pop = estimated_number_of_speakers) %>% 
  filter(!is.na(glottocode)) %>% 
  filter(!is.na(Pop))
  
google_pop_stats %>%  
  write_tsv("output/processed_data/google_pop.tsv")

df <- google_pop_stats %>% 
  left_join(Glottolog, by = "glottocode") %>% 
  filter(!is.na(Longitude))

basemap +
  geom_jitter(data = df, mapping = aes(x = Longitude, y = Latitude, size = Pop, color = log10(Pop))) +
#  theme(plot.margin = unit(c(0,0,0,0), "cm")) +
  ggtitle("Speaker population per language from Google's LinguaMeta-project \n(github.com/google-research/url-nlp), ref = 2bb5257")

ggsave("output/plots/google_pop_map.png", height = 10, width = 12)
}