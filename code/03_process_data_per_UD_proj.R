#directory = "output"
#agg_level = "upos" 
#core_features = "core_features_only"

library(dplyr, lib.loc = "../utility/packages/")
library(tidyr, lib.loc = "../utility/packages/")
library(readr, lib.loc = "../utility/packages/")
library(magrittr, lib.loc = "../utility/packages/")
library(stringr, lib.loc = "../utility/packages/")

#########################
#####  FUNCTION  1  #####
#########################

##############################################################################

process_UD_data <- function(input_dir = NULL,
                         output_dir = NULL, 
                         verbose = TRUE,
                         agg_level = NULL, #upos, lemma token,
                         core_features = NULL, #"core_features_only", "all_features"
                         resolve_multiwords_to = "super-word",
                         remove_empty_nodes = TRUE, 
                         bad_UD_morph_feat_cats =  c("Abbr", "Typo", "Foreign"),
                         fill_empty_lemmas_with_tokens = TRUE,
                         make_all_tokens_of_same_agg_level_have_same_feat_cat =  TRUE){
  
  #  input_dir <- paste0("output/processed_data/ud-treebanks-v2.14_collapsed/")
  # output_dir <- "output/processed_data/ud-treebanks-v2.14_processed"
  
  #various checks to make sure that arguments make sense
  if(!(core_features %in% c("core_features_only", "all_features"))){
    stop("core_features has to be either core_features_only or all_features.")
  }
  
  if(!(agg_level %in% c("upos", "lemma", "token"))){
    stop("agg_level has to be either UPOS, lemma or token.")
  }
  
  if(!(resolve_multiwords_to %in% c("super-word", "component-words"))){
    stop("resolve_multiwords_tos has to be either super-word or component-words.")
  }
  
  if(!(dir.exists(input_dir))){
    stop("input_dir does not exist.")
  }

  #set up the output dirs
  if(!(dir.exists(output_dir))){
    dir.create(output_dir)
  }
  
  if(!(dir.exists(paste0(output_dir, "/agg_level_", agg_level, "_", core_features)))){
    dir.create(paste0(output_dir, "/agg_level_", agg_level, "_", core_features))
  }
  
  output_dirs <- c("processed_tsv", #for output files that will serve as input to next function
                   "counts") # for token counts during the process

  
    for(dir_spec in output_dirs ){
    dir_spec <- paste0(output_dir, "/agg_level_", agg_level, "_", core_features, "/", dir_spec)
    if(!dir.exists(dir_spec)){
      dir.create(dir_spec)
    }
  }
  
  fns <- list.files(path = input_dir, pattern = ".tsv", all.files = T, full.names = T)

  if(length(fns) == 0){
    stop("there are no tsv-files in the input_dir.")
  }
  
  UD_core_feats_df <- data.frame(
    feat = c("PronType", "NumType", "Poss", "Reflex", "Abbr", "Typo", "Foreign", "ExtPos", "Gender", "Animacy", "NounClass", "Number", "Case", "Definite", "Deixis", "DeixisRef", "Degree", "VerbForm", "Mood", "Tense", "Aspect", "Voice", "Evident", "Polarity", "Person", "Polite", "Clusivity"),
    type = c("Lexical", "Lexical",  "Lexical",  "Lexical",  "Other", "Other", "Other", "Other",  "Nominal", "Nominal", "Nominal", "Nominal", "Nominal", "Nominal", "Nominal", "Nominal", "Nominal", "Verbal", "Verbal", "Verbal", "Verbal", "Verbal", "Verbal", "Verbal", "Verbal", "Verbal", "Verbal")
  )
  
#saving what the settings were for processing the content
  settings_log <- paste0("resolve_multiwords_to = ", resolve_multiwords_to, "\n", 
                         "remove_empty_nodes =", remove_empty_nodes, "\n",  
                         "agg_level =", agg_level, "\n",
                         "bad_UD_morph_feat_cats =", bad_UD_morph_feat_cats, "\n",
                         "core_features = ", core_features, "\n", 
                         "fill_empty_lemmas_with_tokens = " , fill_empty_lemmas_with_tokens , "\n",
                         "make_all_tokens_of_same_agg_level_have_same_feat_catt = ", make_all_tokens_of_same_agg_level_have_same_feat_cat,  "\n")

  readr::write_lines(x = settings_log, file = paste0(output_dir, "/agg_level_", agg_level, "_", core_features,"/settings_log.txt"))  
  
  #looping through each of the tsv files, the output from 02_collapse_UD_dirs.R
  


  for(i in 1:length(fns)){
    # i <-67
    fn <- fns[i]
    
    dir <- basename(fn)  %>% stringr::str_replace_all(".tsv", "")
    
    if(verbose == TRUE){
      
    cat(paste0("I'm processesing ", dir, " with ", core_features, " and agg_level =", agg_level, ". It is number ", i, " out of ", length(fns) ,". The time is ", format(Sys.time(), "%Y-%m-%d %H:%M"),".\n")) }
    
    #reading in
    conllu <- readr::read_tsv(fn, show_col_types = F, col_types =  cols(.default = "c"))

    #doing some counting of number of tokens
    n_tokens_in_input <- nrow(conllu)
    n_tokens_empty_dropped <- conllu %>% 
      dplyr::filter(!stringr::str_detect(token_id, "\\.")) %>% nrow()
    n_tokens_only_subwords <- conllu %>% 
      dplyr::filter(!stringr::str_detect(token_id, "-")) %>% nrow()
  
    #remove empty node tokens
    # ID contains tokens that represent words not found in the input, but inserted to complete certain syntactic structures. For example, the second "likes" in the sentence "Sarah likes tea and Bill likes coffee". These complete structures according to certain present principles from the dataset designer, but are not actually present in the input. Researchers can choose in this function to remove these inserted tokens. In UD projects, all of these tokens have a period in the token_id, and it is only tokens of this kind that have a period in their token_id. Therefore, removing tokens with a period in their token_id removes these tokens reliably.
    if(remove_empty_nodes == TRUE){
    conllu <- conllu %>% 
      dplyr::filter(!stringr::str_detect(token_id, "\\."))
    }
    
    ### DEAL WITH MULTIWORD WORDS
    # Contracted words, like "don't" are treated in UD in a special fashion. The conllu files contain 3 tokens for such a contraction: "don't", "do" and "n't". The contracted word (from now on: super-word), in this case "don't" does not receive feats, upos, lemma or dependency relation annotations. Instead, these annotations occur on the "sub-words", i.e. "do" and "n't". The schema for doing this is centrally governed, but it is up to each dataset to decide when to do this. In this project, we are intrested in morphology of surface forms, i.e. exactly what is said/written, as opposed to their teased out syntactical sub-parts. For this reason, we want to keep the "super word", i.e. "don't", move the annotations to that token and remove the components (i.e. "do" and "n't"). All contracted words (i.e "don't") have a dash in their token_id (e.g. "6-7") which can be mapped to the sub-words token_ids (e.g. "6" and "7"). We use this relationship to identify contracted words and sub-words and map information.
    
  if(resolve_multiwords_to == "super-word"){
    
    df_contracted <- conllu  %>%
      dplyr::filter(stringr::str_detect(token_id, "-"))
    
    if(nrow(df_contracted) > 0){
      if(verbose == TRUE){ cat("There are multiword tokens in this dataset, disentangling. \n")}
      df_contracted <- conllu  %>%
        dplyr::filter(stringr::str_detect(token_id, "-")) %>% 
        dplyr::mutate(
          token_range = stringr::str_extract(token_id, "\\d+-\\d+"),
          start = as.integer(stringr::str_extract(token_range, "^\\d+")),
          end   = as.integer(stringr::str_extract(token_range, "\\d+$")),
        ) %>% 
        dplyr::rowwise() %>%
        dplyr::mutate(token_num =  list(start:end)) %>% 
        tidyr::unnest(token_num) %>% 
        tidyr::unite(sentence_id, token_num, col = "id", sep = "£") %>% 
        dplyr::select(id, token_id)
      
      df_uncontracted <- conllu  %>%
        dplyr::filter(!stringr::str_detect(token_id, "-")) %>% 
        dplyr::rename(token_num = token_id) %>% 
        tidyr::unite(sentence_id, token_num, col = "id", remove = FALSE, sep = "£") %>% 
        dplyr::filter(id %in% df_contracted$id) %>% 
        dplyr::select(id, feats, upos, sentence_id, token_num)
      
      df_contracts_solved <- df_contracted %>% 
        dplyr::full_join(df_uncontracted, by = c("id"), relationship = "many-to-many") %>% 
        dplyr::filter(!is.na(token_id)) %>% 
        tidyr::separate(id, into = c("sentence_id", "token_num"), remove = TRUE, , sep = "£", fill = "right") %>% 
        dplyr::group_by(sentence_id, token_id) %>% 
        dplyr::summarise(feats_contracted = paste0(feats, collapse = "|"), 
                         upos_contracted = paste0(upos, collapse = "_"), .groups = "drop")
      
      conllu <- conllu  %>% 
        dplyr::anti_join(dplyr::select(df_uncontracted, sentence_id, token_id = token_num), by = c("sentence_id", "token_id")) %>%
        dplyr::left_join(df_contracts_solved, by = join_by(sentence_id, token_id)) %>% 
        mutate(feats = ifelse(!is.na(feats_contracted), feats_contracted, feats)) %>% 
        mutate(upos = ifelse(!is.na(upos_contracted ), upos_contracted , upos)) %>%
        dplyr::select(-feats_contracted, -upos_contracted)
    }
    
  }
    if(resolve_multiwords_to == "component-words"){
      conllu <- conllu %>% 
        dplyr::filter(!stringr::str_detect(token_id, "-")) 
      }
    
    n_tokens_multiwords_resolved <- conllu %>% nrow()
    

    if(fill_empty_lemmas_with_tokens == TRUE){    
    conllu <- conllu %>% 
      dplyr::mutate(lemma = ifelse(is.na(lemma), token, lemma)) } #for multiwords, the lemma is missing. This is also the case for certian other words in some datasets, like proper nouns, adverbs etc. If can be desirable to normalise this annotation by giving all tokens a lemma - if it's missing just using the token itself.
      
    conllu <- conllu %>% 
      dplyr::mutate(lemma = paste0(lemma, "_", upos)) #the same lemma but differen upos should count as different lemmas. e.g. "bow" (weapon) and "bow" (bodily gesture) should be counted as different
    
    ########## SORT OUT TAGGING
    
    # There are inconsistencies in coding of different UD-projects. It is not the case that every token of the same part-of-speech (upos) are tagged for the same information. For example, some ADJ are tagged for NumType but others aren't. This is most likely not a problem for most UD-purposes, but for this project it causes issues. To address that, we find all the unique feat-types for each upos, and if a token isn't tagged for it, we tag it for it and we denote it as "unassigned". So for example, all ADJ that don't have NumType get "NumType == unassigned". Likewise, tokens that have no morph feats at all, and no token for that UPOS have any, get the morph type "unassigned" with the value "unassigned". This is necessary for the way we later compute surprisal and entropy.
  
    #split for morph tags
    conllu_split <- conllu %>%
      dplyr::mutate(feats_split = stringr::str_split(feats, "\\|")) %>% #split the feature cell for each feature
      tidyr::unnest(cols = c(feats_split))  %>% #unravel the feature cell into separate rows for each feature
      tidyr::separate(feats_split, sep = "=", into = c("feat_cat", "feat_value"), remove = T, fill = "right")  %>% #split the feature into its two components: feat_cat and feat_value
      dplyr::mutate(feat_cat = ifelse(feat_cat %in% bad_UD_morph_feat_cats, yes = NA, no = feat_cat)) %>% #if the feat_cat belongs to a set of feat_cats which is not relevant for the study, replace it with NA. the irrelevant set is defined in 01_requirements.R
      {
        if (core_features == "core_features_only") { #if the variable core_features_only is set to TRUE, we only keep features that belong to this core set. UD_core_feats_df is defined in 01_requirements.R
          dplyr::mutate(., feat_cat = ifelse(feat_cat %in% UD_core_feats_df$feat, feat_cat, NA))
        } else {
          .
        }
      } %>% 
      dplyr::mutate(feats_combo = ifelse(!is.na(feat_cat), paste0(feat_cat, "=", feat_value), NA)) %>% #stick feat_cat and feat_value back together, unless the feat_cat was in that previously mentioned irrelevant category
      dplyr::group_by(id, sentence_id, token, lemma, upos) %>% #ironically, we now need to get back to the previous state of feature strings (several features) and then split it again to get everything to line up. Can also be done in two dfs and joins, but this works as well.
      dplyr::summarise(feats_trimmed = paste0(unique(na.exclude(feats_combo)), collapse = "|"), .groups = "keep") %>% 
      dplyr::mutate(feats_trimmed = ifelse(feats_trimmed == "", NA, feats_trimmed)) %>% 
      dplyr::mutate(feats_split = stringr::str_split(feats_trimmed, "\\|")) %>% 
      tidyr::unnest(cols = c(feats_split))  %>%
      tidyr::separate(feats_split, sep = "=", into = c("feat_cat", "feat_value"), remove = T, fill = "right") %>%  
      dplyr::select(-feats_trimmed) %>% 
      dplyr::distinct() %>% 
      dplyr::ungroup()

    if(make_all_tokens_of_same_agg_level_have_same_feat_cat == TRUE){    
    agg_level_feat_cat_df_distinct <- conllu_split %>% 
      dplyr::select(all_of(agg_level), feat_cat) %>% 
      dplyr::filter(!is.na(feat_cat)) %>% 
      dplyr::distinct() 
    
    token_info <- conllu_split %>%
      dplyr::distinct(id, sentence_id, token, lemma, upos)
    
    expanded <- token_info %>%
      dplyr::left_join(agg_level_feat_cat_df_distinct , by = agg_level, relationship = "many-to-many")  # brings in only feat_cats attested for this agg_level
    
    conllu_split  <- expanded %>%
      dplyr::left_join(conllu_split, by = c("id", "token","sentence_id", "lemma", "upos", "feat_cat")) %>%
      dplyr::mutate(feat_value = coalesce(feat_value, "unassigned")) %>% 
      dplyr::mutate(feat_cat = ifelse(is.na(feat_cat), "unassigned", feat_cat))

    }
    
    ####################################
    #for the output, we need the original format with one row per token and all feats cocatenanted. here we render that back again
    conllu <- conllu_split  %>% 
      dplyr::mutate(feats_combo = paste0(feat_cat, "=", feat_value)) %>% 
      dplyr::arrange(feat_cat) %>% 
      dplyr::group_by(id) %>% 
      dplyr::summarise(feats_new = paste0(unique(feats_combo), collapse = "|")) %>% 
      dplyr::full_join(conllu, by = "id") %>% 
      dplyr::select(-feats) %>% 
      dplyr::rename(feats = feats_new) %>% 
      dplyr::distinct(id, sentence_id, token_id, token, lemma, feats, upos) 
    
    ###
    output_fn <- paste0(output_dir,  "/agg_level_", agg_level, "_", core_features, "/processed_tsv/", dir,".tsv")
    conllu %>% 
      readr::write_tsv(file = output_fn, na = "", quote = "all")
    
    
    #making a data-frame of tokens counts at various points in this data processeing pipeline
    
    df_n_tokens <- data.frame(dir  = dir, 
                              n_tokens_in_input = n_tokens_in_input,
                              n_tokens_empty_dropped = n_tokens_empty_dropped,
                              n_tokens_only_subwords = n_tokens_only_subwords ,
                              n_tokens_multiwords_resolved = n_tokens_multiwords_resolved,
                              n_tokens_output = nrow( conllu))
    
    output_fn <- paste0(output_dir, "/agg_level_", agg_level, "_", core_features, "/counts/", dir,".tsv")
    
    df_n_tokens     %>% 
      readr::write_tsv(file = output_fn, na = "", quote = "all")
    
   } #end of for loop

    #end of function
  }


#########################
#####  FUNCTION  2  #####
#########################

##############################################################################

calculate_surprisal <- function(input_dir = NULL, 
                                output_dir = NULL,
                                verbose = TRUE,
         agg_level = NULL, #upos,lemma token
         core_features = NULL# core_features_only, all_features
             ){

#input_dir <- "output/processed_data/ud-treebanks-v2.14_processed/agg_level_lemma_all_features/processed_tsv/"
#output_dir <- "output/results/ud-treebanks-v2.14_results"
  
  if(!dir.exists(output_dir)){
    dir.create(output_dir)
  }
  
  if(!(dir.exists(input_dir))){
    stop("input_dir does not exist.")
  }
  
  fns <- list.files(path = input_dir, pattern = ".tsv", all.files = T, full.names = T)
  
  if(length(fns) == 0){
    stop("there are no tsv-files in the input_dir.")
  }
  
  # if the input files from from the function process_UD_data, then they have the arguments agg_level and core_features encoded in the directory name. 
agg_level_inferred <- NULL
  
if(str_detect(input_dir, "agg_level_lemma")){
  agg_level_inferred <- "lemma"
  }

if(str_detect(input_dir, "agg_level_upos")){
  agg_level_inferred <- "upos"
}

if(str_detect(input_dir, "agg_level_token")){
  agg_level_inferred <- "token"
}
 
core_features_inferred  <- NULL 

if(str_detect(input_dir, "all_features")){
  core_features_inferred  <- "all_features"
}

if(str_detect(input_dir, "core_features_only")){
  core_features_inferred  <- "core_features_only"
}

if(is.null(agg_level)){
  agg_level <- agg_level_inferred
}else{
if(!is.null(agg_level_inferred) & agg_level != agg_level_inferred){
  stop("The agg_level specified in the function call and the agg_level denoted in the directory's name do not correspond.")}
}

  if(is.null(core_features)){
    core_features <- core_features_inferred
  }else{
    if(!is.null(core_features_inferred) & core_features != core_features_inferred){
      stop("The core_features specified in the function call and the agg_level denoted in the directory's name do not correspond.")}
  }
  
  #various checks to make sure that arguments make sense
  if(!(agg_level %in% c("upos", "lemma", "token"))){
    stop("agg_level has to be either UPOS, lemma or token.")
  }
  
  if(!(core_features %in% c("core_features_only", "all_features"))){
    stop("core_features has to be either core_features_only or all_features.")
  }
  
#set up the output dirs
if(!dir.exists(output_dir)){
  dir.create(output_dir)
}

if(!dir.exists(paste0(output_dir, "/agg_level_", agg_level, "_", core_features))){
  dir.create(paste0(output_dir, "/agg_level_", agg_level, "_", core_features))
}


output_dirs <- c(
  "TTR",
"surprisal_per_token",
"surprisal_per_feat_lookup",
"surprisal_per_featstring_lookup",
"surprisal_per_feat", 
"surprisal_per_featstring", 
"summarised")

for(dir_spec in output_dirs ){
dir_spec <- paste0(output_dir, "/agg_level_", agg_level, "_", core_features, "/", dir_spec)
if(!dir.exists(dir_spec)){
  dir.create(dir_spec)
}
}
                  
#looping through one tsv at a time

for(i in 1:length(fns)){
# i <-7
  fn <- fns[i]
  dir <- basename(fn)  %>% stringr::str_replace_all(".tsv", "")

  if(verbose == TRUE){
    cat(paste0("I'm on ", dir, " for agg level ", agg_level, " with ", core_features, ". It is number ", i, " out of ", length(fns) ,". The time is ", format(Sys.time(), "%Y-%m-%d %H:%M"),".\n"))}
    
  #reading in
conllu <- readr::read_tsv(fn, show_col_types = F, col_types =  cols(.default = "c"))

conllu_split <- conllu %>% 
  dplyr::mutate(feats_split = stringr::str_split(feats, "\\|")) %>% #split the feature cell for each feature
  tidyr::unnest(cols = c(feats_split)) %>% #unravel the feature cell into separate rows for each feature
  tidyr::separate(feats_split, sep = "=", into = c("feat_cat", "feat_value"), remove = T, fill = "right")  
  
n_feat_cats = conllu_split$feat_cat %>% na.omit() %>% unique()
n_feat_cats <- n_feat_cats[!grepl("unassigned", n_feat_cats)] %>% length()

n_feats_per_token_df  <- conllu_split %>% 
  dplyr::filter(!str_detect(feat_cat, "unassigned")) %>% 
  dplyr::filter(!str_detect(feat_value, "unassigned")) %>% 
  dplyr::group_by(id) %>% 
  dplyr::mutate(feats_n = n()) %>% 
  dplyr::mutate(feats_n = ifelse(is.na(feat_cat), 0, feats_n)) %>% 
  dplyr::distinct(id, feats_n)

## COUNTS
#some simple counts: count number of types, tokens, lemmas and sentences
n_tokens_per_sentence_df <- conllu %>% 
  dplyr::group_by(sentence_id) %>% 
  dplyr::summarise(n_tokens = n(), .groups = "drop")

## TTR
n_tokens <- conllu %>% nrow()
n_types <- conllu$token %>% unique() %>%  na.omit() %>% length()
n_lemmas <- conllu$lemma %>% unique() %>%  na.omit() %>% length()
if(verbose == TRUE){cat(paste0("The lemma-token-ratio is ", round(n_lemmas /  n_tokens, 4) , ".\n")) }
if(verbose == TRUE){cat(paste0("The type-token-ratio is ", round(n_types /  n_tokens, 4) , ".\n")) }
data.frame(TTR = n_types /  n_tokens, 
           TTR_lemma = n_lemmas / n_tokens, 
           dir = dir) %>% 
  readr::write_tsv(file = paste0(output_dir, "/agg_level_", agg_level, "_", core_features, "/TTR/", dir, "_TTR_sum.tsv"))

conllu %>% 
  dplyr::group_by(token, lemma, upos) %>% 
  dplyr::summarise(n = n(), .groups = "drop") %>% 
  dplyr::mutate(dir = dir) %>% 
  readr::write_tsv(file = paste0(output_dir, "/agg_level_", agg_level, "_", core_features, "/TTR/", dir, "_TTR_full.tsv"))

surprisal_all_tokens_lookup <- conllu %>% 
  dplyr::group_by(token) %>% 
  dplyr::summarise(n = n(), .groups = "drop") %>%
  dplyr::mutate(prop = n/nrow(conllu)) %>% 
  dplyr::mutate(surprisal = log2(1/prop))

surprisal_token <- conllu %>% 
  dplyr::left_join(surprisal_all_tokens_lookup, by = "token") 

conllu %>% 
  dplyr::left_join(surprisal_all_tokens_lookup, by = "token") %>%
  dplyr::mutate(dir = dir) %>% 
  readr::write_tsv(file = paste0(output_dir, "/agg_level_", agg_level, "_", core_features, "/surprisal_per_token/surprisal_per_token_", dir,
                          ".tsv"))

n_unique_lemma_per_sentence <- conllu %>% 
  dplyr::filter(!is.na(lemma)) %>% 
  dplyr::distinct(sentence_id, lemma) %>%
  dplyr::group_by(sentence_id) %>% 
  dplyr::summarise(n_lemma = n(), .groups = "drop")

########## custom metrics
#computing the probabilities and surprisal of each morph tag value per lemma

#prop for each morph feat
lookup <- conllu_split  %>% 
  dplyr::group_by(.data[[agg_level]], feat_cat, feat_value) %>% 
  dplyr::summarise(n = n(), .groups = "drop") %>% 
  dplyr::group_by(.data[[agg_level]], feat_cat) %>% 
  dplyr::mutate(sum = sum(n)) %>% 
  dplyr::ungroup() %>% 
  dplyr::mutate(prop = n/sum) %>% 
  dplyr::mutate(surprisal = log2(1/prop)) %>%
  dplyr::select(all_of(agg_level), feat_cat, feat_value, n, prop, surprisal)

lookup %>% 
  dplyr::mutate(dir = dir) %>% 
  readr::write_tsv(file = paste0(output_dir, "/agg_level_", agg_level, "_", core_features, "/surprisal_per_feat_lookup/surprisal_per_feat_lookup_agg_level_",agg_level, "_", core_features, "_", dir, ".tsv"),na = "", quote = "all")

token_surprisal_df <- conllu_split  %>% 
  dplyr::distinct(id, token, lemma, feat_cat, feat_value, upos) %>% 
  dplyr::left_join(lookup, by = c(agg_level, "feat_cat", "feat_value")) %>%
  dplyr::group_by(id) %>% 
  dplyr::summarise(sum_surprisal_morph_split = sum(surprisal)) 

token_surprisal_df %>% 
  dplyr::mutate(dir = dir) %>% 
  readr::write_tsv(file = paste0(output_dir, "/agg_level_", agg_level, "_", core_features, "/surprisal_per_feat/surprisal_per_feat_per_agg_level_",agg_level, "_",  core_features, "_", dir, ".tsv"), na = "", quote = "all")

#featstrings
lookup_not_split <- conllu %>% 
  dplyr::group_by(.data[[agg_level]], feats) %>% 
  dplyr::summarise(n = n(), .groups = "drop") %>% 
  dplyr::group_by(.data[[agg_level]]) %>% 
  dplyr::mutate(sum = sum(n)) %>% 
  dplyr::ungroup() %>% 
  dplyr::mutate(prop = n/sum) %>% 
  dplyr::mutate(surprisal = log2(1/prop)) %>% 
  dplyr::select(all_of(agg_level), feats,n, prop, surprisal_per_morph_featstring = surprisal)

lookup_not_split %>% 
  dplyr::mutate(dir = dir) %>% 
  readr::write_tsv(file = paste0(output_dir, "/agg_level_", agg_level, "_", core_features, "/surprisal_per_featstring_lookup/surprisal_per_featstring_lookup_agg_level_",agg_level, "_", core_features, "_", dir, ".tsv"),na = "", quote = "all")

token_surprisal_df_feat_string <- conllu %>% 
  dplyr::distinct(id, token, lemma, feats, upos) %>% 
  dplyr::left_join(lookup_not_split, by = c(agg_level, "feats")) 

token_surprisal_df_feat_string %>% 
  dplyr::mutate(dir = dir) %>% 
  readr::write_tsv(file = paste0(output_dir, "/agg_level_", agg_level, "_", core_features, "/surprisal_per_featstring/surprisal_per_featstring_per_agg_level_",agg_level, "_",  core_features, "_", dir, ".tsv"), na = "", quote = "all")

data.frame(dir = dir, 
           agg_level = agg_level, 
           core_features = core_features,
           n_types = n_types, 
           n_tokens = n_tokens, 
           n_lemmas = n_lemmas, 
           n_sentences = conllu$sentence_id %>% unique() %>% length(), 
           TTR = n_types /  n_tokens, 
           LTR = n_lemmas / n_tokens, 
           n_feat_cats = n_feat_cats,
           n_feats_per_token_mean = n_feats_per_token_df$feats_n %>% mean(),
           suprisal_token_mean = surprisal_token$surprisal %>% mean(), 
           sum_surprisal_morph_split_mean = token_surprisal_df$sum_surprisal_morph_split %>% mean() ,
           surprisal_per_morph_featstring_mean = token_surprisal_df_feat_string$surprisal_per_morph_featstring  %>% mean()) %>%
  readr::write_tsv(file = paste0(output_dir, "/agg_level_", agg_level, "_", core_features, "/summarised/", dir, "_summarised_agg_level_",agg_level, "_",  core_features, ".tsv"), na = "", quote = "all")
} #end of for-loop


}#end of function
