source("01_requirements.R")

fns <- list.files(path = "../data/ud-treebanks-v2.13/", 
                  pattern = "conllu", 
                  full.names = T, 
                  recursive = T)


df_all_means <- data.frame("fn" = as.character(),
                           "n_feats_per_sent_mean" =  as.character(),
                           "n_feats_per_token_mean" =  as.character())


for(i in 1:length(fns)){
# i <- 85
  fn <- fns[i]


  cat(paste0("I'm on ", fn, ". It is number ", i, " out of ", length(fns) ,".\n"))
  
conllu <- udpipe::udpipe_read_conllu(fn) %>% 
  dplyr::filter(!str_detect(token, "[[:punct:]]")|
           upos != "PUNCT")  

#count number of types, tokens, lemmas and sentences
n_tokens_per_sentence_df <- conllu %>% 
  dplyr::filter(!is.na(token)) %>% 
  group_by(sentence_id) %>% 
  summarise(n_tokens = n(), .groups = "drop")

n_unique_per_sentence_lemma_df <- conllu %>% 
  dplyr::filter(!is.na(lemma)) %>% 
  distinct(sentence_id, lemma) %>%
  group_by(sentence_id) %>% 
  summarise(n_lemma = n(), .groups = "drop")
  
#counting feats per token and sentence
conllu_split <- conllu %>%
  dplyr::mutate(feats = str_split(feats, "\\|")) %>% 
  tidyr::unnest(cols = c(feats))  %>% 
  dplyr::filter(!is.na(feats)) %>% 
  tidyr::separate(feats, sep = "=", into = c("feats", "feat_spec"))  %>% 
  dplyr::filter(str_detect(feats, paste0(UD_feats_df$feat, collapse = "|"))) %>% 
  dplyr::filter(!str_detect(feats, "Abbr|Typo|Foreign|ExtPos"))

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