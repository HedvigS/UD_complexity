source("01_requirements.R")

fns <- list.files("output/sum_dfs/", pattern = "df_means.tsv", full.names = T)

df <- data.frame("fn" = as.character(),
                 "n_feats_per_semt_mean" =  as.character(),
                 "n_feats_per_token_mean" =  as.character())


for(fn in fns){
 df <- read_tsv(fn, col_types = cols(.default = "c")) %>% 
   full_join(df)
  
}

df$n_feats_per_token_mean %>% as.numeric() %>% hist()  
  


df <- read_tsv(file = "output/all_conllu_df.tsv")



df_mean <- df %>% 
  group_by(fn, sentence_id) %>% 
  summarise(n = sum(n), .groups = "drop") %>% 
  group_by(fn) %>% 
  summarise(mean_n = mean(n)) 

df_mean$mean_n %>% hist(breaks = 10)
