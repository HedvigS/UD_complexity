source("01_requirements.R")

fns <- list.files(path = paste0("output/processed_data/", UD_version), pattern = ".tsv", all.files = T, full.names = T)
                  



df_all_means <- data.frame("fn" = as.character(),
                           "n_feats_per_sent_mean" =  as.character(),
                           "n_feats_per_token_mean" =  as.character())


for(i in 1:length(fns)){
# i <- 238
  fn <- fns[i]


  cat(paste0("I'm on ", basename(fn), ". It is number ", i, " out of ", length(fns) ,".\n"))
  
conllu <- read_tsv(fn, show_col_types = F) %>% 
  dplyr::filter(!str_detect(token, "[[:punct:]]")|
           upos != "PUNCT")  

#count number of types, tokens, lemmas and sentences
n_tokens_per_sentence_df <- conllu %>% 
  dplyr::filter(!is.na(token)) %>% 
  group_by(sentence_id) %>% 
  summarise(n_tokens = n(), .groups = "drop")

n_unique_lemma_per_sentence <- conllu %>% 
  dplyr::filter(!is.na(lemma)) %>% 
  distinct(sentence_id, lemma) %>%
  group_by(sentence_id) %>% 
  summarise(n_lemma = n(), .groups = "drop")
  
#counting feats per token and sentence
conllu_split <- conllu %>%
  dplyr::mutate(feats = str_split(feats, "\\|")) %>% 
  tidyr::unnest(cols = c(feats))  %>% 
  dplyr::filter(!is.na(feats)) %>% 
  tidyr::separate(feats, sep = "=", into = c("feats", "feat_value"))  %>% 
  dplyr::filter(str_detect(feats, paste0(UD_feats_df$feat, collapse = "|"))) %>% 
  dplyr::filter(!str_detect(feats, "Abbr|Typo|Foreign|ExtPos"))

test <- conllu_split %>% 
  group_by(lemma, upos, feats, feat_value) %>% 
  summarise(n = n()) %>% 
  group_by(lemma, upos,feats) %>% 
  mutate(sum = sum(n)) %>% 
  ungroup() %>% 
  mutate(prop = n/sum) %>% 
  group_by(lemma, upos, feats) %>% 
  mutate(n_alt = n()) 

test %>% 
  group_by(lemma, upos, feats) %>% 
  slice_max(prop ) %>% View()
  







n_feats_per_sentence_df <- conllu_split %>% 
  group_by(sentence_id) %>% 
  summarise(feats_n = n(), .groups = "drop") 

n_feats_per_token_df <- conllu_split %>% 
  group_by(sentence_id, token_id) %>% 
  summarise(feats_n = n(), .groups = "drop") %>% 
  group_by(sentence_id) %>% 
  summarise(feats_per_token = paste0(feats_n, collapse = ";"),
            mean_feats_per_token = mean(feats_n)) 

df <- n_tokens_per_sentence_df  %>% 
  full_join(n_unique_per_sentence_lemma_df,by = join_by(sentence_id)) %>% 
  full_join(n_feats_per_sentence_df, by = join_by(sentence_id)) %>% 
  full_join(n_feats_per_token_df , by = join_by(sentence_id)) %>% 
  dplyr::mutate(feats_ratio_sentence = feats_n / n_tokens) %>% 
  dplyr::mutate(fn = fn)

df %>% write_tsv(file = paste0("output/UD_conllu/", basename(fn), "_summarised.tsv"))

}