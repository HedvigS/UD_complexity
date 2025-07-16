library(dplyr, lib.loc = "../utility/packages/")
library(ggplot2, lib.loc = "../utility/packages/")
library(readr, lib.loc = "../utility/packages/")
library(magrittr, lib.loc = "../utility/packages/")

source("02_basemap.R")

if(!file.exists("output/processed_data/google_pop.tsv")){

Glottolog <- readr::read_tsv("output/processed_data/glottolog_5.0_languages.tsv", show_col_types = F) %>% 
  dplyr::rename(glottocode = Glottocode) %>% 
  dplyr::mutate(Longitude = if_else(Longitude <= -25, Longitude + 360, Longitude)) 

if(!file.exists("../data/google-research-url-nlp/linguameta.tsv")){
readr::read_tsv("https://github.com/google-research/url-nlp/raw/e2adf5c9e2af5108d7e5d2a920ce9936d9867cc2/linguameta/linguameta.tsv", show_col_types = F) %>% 
    readr::write_tsv(file = "../data/google-research-url-nlp/linguameta.tsv") 
  }

google_pop_stats <- read_tsv("../data/google-research-url-nlp/linguameta.tsv", show_col_types = F) %>% 
  dplyr::select(glottocode, Pop = estimated_number_of_speakers) %>% 
  dplyr::filter(!is.na(glottocode)) %>% 
  dplyr::filter(!is.na(Pop))
  
google_pop_stats %>%  
  readr::write_tsv("output/processed_data/google_pop.tsv")

df <- google_pop_stats %>% 
  dplyr::left_join(Glottolog, by = "glottocode") %>% 
  dplyr::filter(!is.na(Longitude))

p <- basemap +
  ggplot2::geom_jitter(data = df, mapping = ggplot2::aes(x = Longitude, y = Latitude, size = Pop, 
                                                         fill = log10(Pop +1), color = log10(Pop +1)), 
              shape = 21, alpha = 0.9, stroke = 0.3) +
  ggplot2::theme(legend.position = "None") +
  ggplot2::ggtitle("Speaker population per language from Google's LinguaMeta-project \n(github.com/google-research/url-nlp")

ggplot2::ggsave(filename = "output/plots/google_pop_map.png", height = 10, width = 12, plot = p)
}