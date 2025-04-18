source("01_requirements.R")

fns <- list.files(path = paste0("../data/", UD_version), 
                  pattern = "conllu", 
                  full.names = T, 
                  recursive = T)

UD_langs <- read_tsv("../data/UD_languages.tsv", show_col_types = F) %>% 
  dplyr::select(dir, conllu, glottocode) %>% 
  filter((conllu %in% basename(fns)))

UD_dirs <- UD_langs %>% 
  group_by(dir) %>% 
  summarise(conllus = paste0(conllu, collapse = ";"), .groups = "drop")


for(i in 1:nrow(UD_dirs)){
  
  #i <- 1
  
  cat(paste0("I'm on ", UD_dirs[i,1], ". That's ", i, " of ", nrow(UD_dirs), ".\n"))
  
  UD_dir_spec <- UD_dirs[i,] %>% 
    mutate(conllus = str_split(conllus, ";")) %>% 
    unnest(conllus)
  
  ######
  df <- data.frame(
    "id"  = as.character(),
    "doc_id"        = as.character(),
    "paragraph_id"   = as.character(),
    "sentence_id"    = as.character(),
    "sentence"      = as.character(), 
    "token_id"     = as.character(),  
    "token"        = as.character(),  
    "lemma"        = as.character(),  
    "upos"         = as.character(), 
    "xpos"          = as.character(), 
    "feats"         = as.character(), 
    "head_token_id"  = as.character(),
    "dep_rel"       = as.character(), 
    "deps"       = as.character(),    
    "misc"    = as.character()
    )
  

  for(y in 1:nrow(UD_dir_spec)){
#      y = 1
     fn <-     paste0("../data/", UD_version, "/", UD_dir_spec[1,1],"/", UD_dir_spec[y,2] )

    conllu <- udpipe::udpipe_read_conllu(fn) %>%   
      dplyr::filter(!is.na(token)) %>% 
      dplyr::mutate(lemma = ifelse(is.na(lemma), token, lemma)) %>% #if there isn't a lemma assigned, assume that the unique token is the lemma
      #  dplyr::filter(!str_detect(feats, "Foreign=Yes|ExtPos=Yes")) %>% 
      dplyr::filter(upos != "PUNCT")  %>% #remove tokens that are tagged with the part-of-speech tag punct for punctuation
      dplyr::filter(upos != "X")  %>%
      dplyr::filter(upos != "SYM")  %>%
      dplyr::filter(token != "%") %>%  #remove tokens that are just "%"
      dplyr::filter(token != "[:punct:]+") %>% #remove tokens that only consist of punctuation (including "$")
      dplyr::filter(token != "[[punct]]+%") #remove tokens that consists of punctuation and percent sign only
    
    if(all(!is.na(conllu$doc_id))){
      suppressWarnings( conllu$doc_id <- stringr::str_pad(as.numeric(conllu$doc_id), width = 3, pad = "0", side = "left") )
    }
    
    suppressWarnings(conllu$paragraph_id <- stringr::str_pad(as.numeric(conllu$paragraph_id), width = 3, pad = "0", side = "left"))
    suppressWarnings(conllu$token_id <- stringr::str_pad(as.numeric(conllu$token_id), width = 3, pad = "0", side = "left"))
    
    conllu <- conllu %>% 
      tidyr::unite(doc_id, paragraph_id, sentence_id, token_id, col = "id", remove = F) %>% 
      dplyr::mutate(across(everything(), as.character)) 
  
    df <- df %>% 
      full_join(conllu, by = join_by(id, doc_id, paragraph_id, sentence_id, sentence, token_id, token, lemma, upos, xpos, feats, head_token_id,
                                     dep_rel, deps, misc))
  
  }

  df %>% 
    write_tsv(file = paste0("output/processed_data/", UD_version, "/", 
                            UD_dir_spec[1,1], ".tsv"), quote = "all", na = "")
  
}
