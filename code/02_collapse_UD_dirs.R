library(dplyr, lib.loc = "../utility/packages/")
library(tidyr, lib.loc = "../utility/packages/")
library(readr, lib.loc = "../utility/packages/")
library(udpipe, lib.loc = "../utility/packages/")
library(magrittr, lib.loc = "../utility/packages/")
library(stringr, lib.loc = "../utility/packages/")

#set cut-off for inclusion. number of tokens minially
minimum_tokens = 13000 # minimum used by Çöltekin & Rama (2023)

dir <- paste0("output/processed_data/ud-treebanks-v2.14")
if(!dir.exists(dir)){
  dir.create(dir)
}

fns <- list.files(path = paste0("../data/ud-treebanks-v2.14"), 
                  pattern = "conllu", 
                  full.names = T, 
                  recursive = T)

UD_langs <- readr::read_tsv("../data/UD_languages.tsv", show_col_types = F) %>% 
  dplyr::select(dir, conllu, glottocode) 

dirs <- list.dirs(path = paste0("../data/ud-treebanks-v2.14"), full.names = F, recursive = F)

#check that the UD_languages.tsv correctly matches the fetched data, i.e. that all dirs and conllu files match
checks <- list(UD_langs$conllu[!UD_langs$conllu %in% basename(fns)],
basename(fns)[!basename(fns) %in% UD_langs$conllu],
UD_langs$dir[!UD_langs$dir %in% dirs],
dirs[!dirs %in% UD_langs$dir])

check <- all(sapply(checks, length) == 0)

if(check == FALSE){
  stop("The file UD_languages.tsv and the fetched files don't match.")
}

UD_dirs <- UD_langs %>% 
  dplyr::group_by(dir) %>% 
  dplyr::summarise(conllus = paste0(conllu, collapse = ";"), .groups = "drop")

#UD_dirs <- UD_dirs[c(1, 2, 3, 4, 16, 41, 53 ,67, 81),]

for(i in 1:nrow(UD_dirs)){
  
  #i <- 67
  
  cat(paste0("I'm on ", UD_dirs[i,1], ". That's ", i, " of ", nrow(UD_dirs)))
  
  UD_dir_spec <- UD_dirs[i,] %>% 
    dplyr::mutate(conllus = str_split(conllus, ";")) %>% 
    tidyr::unnest(conllus)
  
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
    "misc"    = as.character(), 
    "filename"= as.character()
    )
  

  for(y in 1:nrow(UD_dir_spec)){
#      y = 1
     fn <-     paste0("../data/ud-treebanks-v2.14", "/", UD_dir_spec[1,1],"/", UD_dir_spec[y,2] )

    conllu <- udpipe::udpipe_read_conllu(fn) %>%   
      dplyr::filter(!is.na(token)) %>% 
      dplyr::mutate(upos = ifelse(str_detect(token_id, "-") & is.na(lemma), "MULTIWORD", upos)) %>% #making missing value upos for multiword token not missing so that it survives the negative filters below
      dplyr::filter(upos != "PUNCT")  %>% #remove tokens that are tagged with the part-of-speech tag punct for punctuation
      dplyr::filter(upos != "X")  %>%
      dplyr::mutate(filename = fn) %>% 
      dplyr::mutate(upos = ifelse(upos == "MULTIWORD", NA, upos)) #turning missing upos for multiword items back into NA so that the rest of the data-flow works as expected.

    if(all(!is.na(conllu$doc_id))){
      suppressWarnings( conllu$doc_id <- stringr::str_pad(as.numeric(conllu$doc_id), width = 3, pad = "0", side = "left") )
    }
    
    suppressWarnings(conllu$paragraph_id <- stringr::str_pad(as.numeric(conllu$paragraph_id), width = 3, pad = "0", side = "left"))
    suppressWarnings(conllu$token_id <- stringr::str_pad(as.numeric(conllu$token_id), width = 3, pad = "0", side = "left"))
    
    conllu <- conllu %>% 
      tidyr::unite(doc_id, paragraph_id, sentence_id, token_id, col = "id", remove = F) %>% 
      dplyr::mutate(across(everything(), as.character)) 
  
    df <- df %>% 
      dplyr::full_join(conllu, by = dplyr::join_by(id, doc_id, paragraph_id, sentence_id, sentence, token_id, token, lemma, upos, xpos, feats, head_token_id,
                                     dep_rel, deps, misc, filename))
    
  
  }

if(nrow(df) >= minimum_tokens){  
  
  cat("\n It is written to file. There were ", nrow(df), " tokens.\n")
  df %>% 
    readr::write_tsv(file = paste0("output/processed_data/ud-treebanks-v2.14", "/", 
                            UD_dir_spec[1,1], ".tsv"), quote = "all", na = "")}else{
                              cat("\n Too few tokens, not written to file. There were ", nrow(df), " tokens.\n")
                            }
  
}
