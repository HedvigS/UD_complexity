source("01_requirements.R")
#this script takes the output from 02_process_data_per_UD_proj and greates summaries to be plotted

Glottolog <- read_tsv("output/processed_data/glottolog_5.0_languages.tsv", show_col_types = F) %>%
  dplyr::select(glottocode = Glottocode, Longitude, Latitude, Family_ID, Language_level_ID, Name) %>% 
  dplyr::mutate(Longitude = if_else(Longitude <= -25, Longitude + 360, Longitude))  #shifting the longlat 

UD_langs <- read_tsv("../data/UD_languages.tsv", show_col_types = F) %>% 
  filter(!str_detect(glottocodes, ";")) %>% 
  distinct(dir,  glottocode) 

##basic counts

fns <- list.files("output/counts/", pattern = ".tsv", full.names = T)

df_all <- data.frame(dir = as.character(), 
                     n_sentences = as.numeric(),
                     sum_tokens = as.numeric(), 
                     mean_feats_per_token =  as.numeric())

for(i in 1:length(fns)){
  # i <- 13
  fn <- fns[i]
  dir <- fn %>% basename() %>% str_replace_all(".tsv", "") %>% str_replace_all("counts_", "") %>% str_replace_all("_summarised", "")
  df <- read_tsv(fn, show_col_types = F)
  n_sentences <- nrow(df)
  
  df_unnested <- df %>% 
    mutate(feats_per_token = str_split(feats_per_token, ";")) %>% 
    unnest(feats_per_token) 
  
  df_spec <- data.frame(dir = dir, 
                        n_sentences =nrow(df),
                        sum_tokens = sum(df$n_tokens), 
                        mean_feats_per_token =  mean(as.numeric(df_unnested$feats_per_token))
  )
  
  df_all <- df_spec %>% 
    full_join(df_all, by = join_by(dir, n_sentences, sum_tokens, mean_feats_per_token))
  
}

joined <- df_all %>% 
  inner_join(UD_langs, by = "dir") %>% 
  left_join(Glottolog, by = "glottocode") %>% 
  distinct(dir, n_sentences, sum_tokens, mean_feats_per_token, glottocode, Longitude, Latitude) %>% 
  dplyr::mutate(Longitude = if_else(Longitude <= -25, Longitude + 360, Longitude))  #shifting the longlat 

joined %>% 
  write_tsv("output/summaries/counts.tsv")


#SURPRISAL PER FEAT PER LEMMA (I.E. NOT FEATSTRING BUT SPLIT)

fns <- list.files("output/surprisal_per_feat_per_lemma/",  full.names = T)

df_all <- data.frame(dir = as.character(), 
                     mean_sum_surprisal_morph_split_per_lemma = as.numeric())

for(i in 1:length(fns)){
  
  #  i <- 1
  fn <- fns[i]
  dir <- fn %>% basename() %>% str_replace_all(".tsv", "") %>% str_replace_all("surprisal_per_feat_per_lemma_", "") 
  
  df <- read_tsv(fn, show_col_types = F)
  
  df_spec <- data.frame( mean_sum_surprisal_morph_split_per_lemma=  df$sum_surprisal_morph_split %>% mean(), 
                         dir = dir)
  
  df_all <- full_join(df_spec, df_all, by = join_by(mean_sum_surprisal_morph_split_per_lemma, dir))
  
}

joined <- df_all %>% 
  inner_join(UD_langs) %>% 
  left_join(Glottolog) %>% 
  distinct() %>% 
  dplyr::mutate(Longitude = if_else(Longitude <= -25, Longitude + 360, Longitude))  #shifting the longlat 

joined %>% 
  write_tsv("output/summaries/mean_sum_surprisal_per_lemma_morph_split.tsv")



#SURPRISAL PER FEAT PER LEMMA (I.E. NOT FEATSTRING BUT SPLIT)

fns <- list.files("output/surprisal_per_feat_per_UPOS/",  full.names = T)

df_all <- data.frame(dir = as.character(), 
                     mean_sum_surprisal_morph_split_per_UPOS = as.numeric())

for(i in 1:length(fns)){
  
  #  i <- 1
  fn <- fns[i]
  dir <- fn %>% basename() %>% str_replace_all(".tsv", "") %>% str_replace_all("surprisal_per_feat_per_UPOS_", "") 
  
  df <- read_tsv(fn, show_col_types = F)
  
  df_spec <- data.frame( mean_sum_surprisal_morph_split_per_UPOS=  df$sum_surprisal_morph_split %>% mean(), 
                         dir = dir)
  
  df_all <- full_join(df_spec, df_all, by = join_by(mean_sum_surprisal_morph_split_per_UPOS, dir))
  
}

joined <- df_all %>% 
  inner_join(UD_langs) %>% 
  left_join(Glottolog) %>% 
  distinct() %>% 
  dplyr::mutate(Longitude = if_else(Longitude <= -25, Longitude + 360, Longitude))  #shifting the longlat 

joined %>% 
  write_tsv("output/summaries/mean_sum_surprisal_per_UPOS_morph_split.tsv")







#TTR
fns <- list.files("output/TTR/", pattern = "sum.tsv", full.names = T)

stacked <- SH.misc::stack_tsvs(fns = fns, verbose = F) 

stacked <- stacked %>% 
  inner_join(UD_langs) %>% 
  left_join(Glottolog) %>% 
  distinct() %>% 
  dplyr::mutate(Longitude = if_else(Longitude <= -25, Longitude + 360, Longitude))  #shifting the longlat 

stacked %>% 
  write_tsv("output/summaries/TTR.tsv")

#Morph tag usefulness


fns <- list.files("output/surprisal_per_feat_per_UPOS_lookup/",  full.names = T)

stacked <- SH.misc::stack_tsvs(fns = fns, verbose = F)

stacked$dir <-   stacked$filename%>% basename() %>% str_replace_all(".tsv", "") %>% str_replace_all("surprisal_per_feat_per_UPOS_lookup_", "") 


summed <- stacked %>% 
  filter(feat_value != "unassigned") %>% 
  dplyr::select(dir, upos, feat, feat_value, n) %>%
  group_by(dir, upos, feat) %>% 
  mutate(sum = sum(n)) %>% 
  ungroup() %>% 
  mutate(prop = n/sum) %>% 
  group_by(dir, upos, feat) %>% 
  slice_max(prop) %>% 
  inner_join(UD_langs, relationship = "many-to-many", by = "dir") %>% 
  left_join(Glottolog, relationship = "many-to-many", by ="glottocode")

summed %>% 
  write_tsv("output/summaries/UPOS_prop.tsv")
