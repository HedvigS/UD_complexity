source("01_requirements.R")

fns <- list.files(path = "../data/ud-treebanks-v2.13/", 
                  pattern = "conllu", 
                  full.names = T, 
                  recursive = T)

n <- length(fns)

for(i in 1:n){
fn <- fns[i]

  cat(paste0("I'm on ", fn, ".\n"))
  cat(paste0("It is number ", i, " out of ", n ,".\n"))
  
conllu <- udpipe::udpipe_read_conllu(fn)

conllu_split <- conllu %>%
  mutate(feats = str_split(feats, "\\|")) %>% 
  tidyr::unnest(cols = c(feats))  %>% 
  filter(!is.na(feats)) 
  #  filter(!str_detect(token, "[[:punct:]]")) %>% 
  #  mutate(feats = if_else(is.na(feats), "standin", feats)) %>% 
  
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
    
}

