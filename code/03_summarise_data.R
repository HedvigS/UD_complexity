source("01_requirements.R")

df <- read_tsv(file = "output/all_conllu_df.tsv")



df_mean <- df %>% 
  group_by(fn, sentence_id) %>% 
  summarise(n = sum(n), .groups = "drop") %>% 
  group_by(fn) %>% 
  summarise(mean_n = mean(n)) 

df_mean$mean_n %>% hist(breaks = 10)
