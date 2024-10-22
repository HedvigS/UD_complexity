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
  
  UD_dir_spec <- UD_dirs[i,] %>% 
    mutate(conllus = str_split(conllus, ";")) %>% 
    unnest(conllus)
  
  ######
  df <- data.frame(
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
    dplyr::filter(!str_detect(token, "[[:punct:]]")|
                    upos != "PUNCT")  %>% 
      dplyr::mutate(across(everything(), as.character))
  
    df <- df %>% 
      full_join(conllu, by = join_by(doc_id, paragraph_id, sentence_id, sentence, token_id, token, lemma, upos, xpos, feats, head_token_id,
                                     dep_rel, deps, misc))
  
  }
  
  dir <- paste0("output/processed_data/", UD_version, "/", UD_dir_spec[1,1])
  if(!dir.exists(dir)){
    dir.create(dir)
  }
  
  df %>% 
    write_tsv(file = paste0(dir, "/", basename(dir), ".tsv"))
  
}
