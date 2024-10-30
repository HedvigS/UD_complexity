source("01_requirements.R")

Glottolog <- read_tsv("output/processed_data/glottolog_5.0_languages.tsv", show_col_types = F) %>% 
  dplyr::select(glottocode = Glottocode, Longitude, Latitude, Family_ID, Language_level_ID, Name) %>%   dplyr::mutate(Longitude = if_else(Longitude <= -25, Longitude + 360, Longitude))  #shifting the longlat 

UD_langs <- read_tsv("../data/UD_languages.tsv", show_col_types = F) %>% 
  distinct(dir,  glottocode)

fns <- list.files("output/surprisal_per_feat_per_lemma/",  full.names = T)

fns <- fns[c(63, 130, 216)]

df_min_max <- data.frame(id = c("TEMP_min", "TEMP_max"), 
                         sum_surprisal_morph_split = c(0, 26))
                                                       #97.83992) )

df_all <- data.frame(bin = as.character(), 
                     n = as.numeric(), 
                     dir = as.character())

for(i in 1:length(fns)){
  
#  i <- 1
  fn <- fns[i]
  dir <- fn %>% basename() %>% str_replace_all(".tsv", "") %>% str_replace_all("surprisal_per_feat_per_lemma_", "") 
    
  df <- read_tsv(fn, show_col_types = F)

  df <- df %>% 
#    full_join(df_min_max, by = join_by(id, sum_surprisal_morph_split)) %>% 
    transform(bin = cut(sum_surprisal_morph_split, breaks = -1:98)) %>% 
    filter(!str_detect(id, "TEMP")) %>% 
    group_by(bin) %>% 
    summarise(n = n()) %>% 
    mutate(dir = dir)
  
  df_all <- df %>% 
    full_join(df_all)
  
}

breaks_df <- data.frame(bin = cut(x = 0:max(df_min_max$sum_surprisal_morph_split), 
                                  breaks = -1:98))


joined <- df_all %>% full_join(breaks_df) %>% 
  complete(bin, dir, fill = list(n = 0)) %>% 
  filter(!is.na(dir))

joined$bin_display <- joined$bin %>% 		
  str_replace_all("[\\(|\\[|\\]]", "") 		

joined <- joined %>% 
  tidyr::separate(col = bin_display, sep = ",", into = c("low", "high")) %>% 		
  mutate(low = round(as.numeric(low), digits = 1)) %>% 		
  mutate(high = round(as.numeric(high), digits = 1)) %>% 		
  unite(low, high, col = bin_display, sep = "-", remove = F) 


joined$bin_display <- fct_reorder(joined$bin_display, joined$low)

joined %>% 
  ggplot(mapping = aes(x = bin_display, y = n)) + 
  geom_bar(stat = "identity") +
  facet_wrap(~dir, ncol = 1) +
  theme(axis.text.x = element_blank())

ggsave("output/plots/barplot_test.png", height = 5, width = 5)
