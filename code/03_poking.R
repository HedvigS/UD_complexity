source("01_requirements.R")

fns <- list.files(path = "../data/ud-treebanks-v2.13/", 
                  pattern = "cs.*conllu", 
                  full.names = T, 
                  recursive = T)


for(i in 1:length(fns)){
  i <- 3
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

}