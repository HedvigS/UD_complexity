source("01_requirements.R")

fns <- list.files(path = "../data/ud-treebanks-v2.13/", 
                  pattern = "conllu", 
                  full.names = T, 
                  recursive = T)


df_all_means <- data.frame("fn" = as.character(),
                           "n_feats_per_sent_mean" =  as.character(),
                           "n_feats_per_token_mean" =  as.character())

df_all_counts <- data.frame(n_token = as.character(),
                        n_type = as.character(),
                        n_sentence = as.character(), 
                        n_feats = as.character(),
                        n_unique_lemma = as.character(),
                        fn = as.character()) 

for(i in 1:length(fns)){
# i <- 3
  fn <- fns[i]


  cat(paste0("I'm on ", fn, ". It is number ", i, " out of ", length(fns) ,".\n"))
  
conllu <- udpipe::udpipe_read_conllu(fn)

#count number of types, tokens, lemmas and sentences
n_token <- conllu %>% 
  filter(!str_detect(token, "[[:punct:]]")|
           upos != "PUNCT") %>% nrow()

n_type <- conllu %>% 
  filter(!str_detect(token, "[[:punct:]]")|
           upos != "PUNCT") %>% 
  distinct(token) %>% 
  nrow()

n_sentence <- conllu$sentence_id %>% unique() %>% length()

n_unique_lemma <- conllu %>% 
  filter(!is.na(lemma)) %>% 
  filter(!str_detect(token, "[[:punct:]]")|
           upos != "PUNCT") %>%
  distinct(lemma) %>% nrow()

#counting feats per token and sentence
conllu_split <- conllu %>%
  mutate(feats = str_split(feats, "\\|")) %>% 
  tidyr::unnest(cols = c(feats))  %>% 
  filter(!is.na(feats)) 
  #  filter(!str_detect(token, "[[:punct:]]")) %>% 
  #  mutate(feats = if_else(is.na(feats), "standin", feats)) %>% 
  
n_feats <- conllu_split %>% 
  filter(!is.na(feats)) %>% 
  filter(!str_detect(token, "[[:punct:]]")|
           upos != "PUNCT") %>%
  distinct(feats) %>% nrow()




df_all_counts <- data.frame(n_token = as.character(n_token),
                            n_type = as.character(n_type),
                            n_feats = as.character(n_feats ),
                            n_sentence = as.character(n_sentence), 
                            n_unique_lemma = as.character(n_unique_lemma),
                            fn = fn) %>% 
  full_join(df_all_counts, by = join_by(n_token, n_type, n_sentence,n_feats , n_unique_lemma, fn))

df_all_counts %>% 
  write_tsv("output/sum_dfs/all_sum_df_counts.tsv")









conllu_split_n_token <- conllu_split %>% 
  group_by(sentence_id, token_id) %>% 
  summarise(n_feats_per_token = n(),
            .groups = "drop") 

df_spec <- conllu_split %>% 
  group_by(sentence_id, sentence) %>% 
  summarise(n_feats_per_sent = n(), .groups = "drop") %>%   
  full_join(conllu_split_n_token,
            by = join_by(sentence_id)) %>% 
  mutate(fn = fn)

fn_spec <- paste0("output/sum_dfs/", basename(fn), "_sum_df.tsv")

df_spec %>% 
      write_tsv(file = fn_spec)

        
        #means
token_mean <- df_spec %>% 
      group_by(fn) %>% 
      summarise(n_feats_per_token_mean = mean(n_feats_per_token), .groups = "drop")

sent_mean <- df_spec %>% 
  distinct(sentence_id, fn,n_feats_per_sent) %>% 
  group_by(fn) %>% 
  summarise(n_feats_per_sent_mean = mean(n_feats_per_sent), .groups = "drop")

df_all_means <-  sent_mean %>% 
  full_join(token_mean, by = "fn") %>% 
  mutate(across(everything(), as.character)) %>% 
  full_join(df_all_means, by = join_by(fn, n_feats_per_sent_mean, n_feats_per_token_mean))

df_all_means %>% 
  write_tsv("output/sum_dfs/all_sum_df_means.tsv")

}