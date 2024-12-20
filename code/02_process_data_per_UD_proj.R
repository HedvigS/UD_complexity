source("01_requirements.R")

control.compute=list(save.memory=T)

fns <- list.files(path = paste0("output/processed_data/", UD_version), pattern = ".tsv", all.files = T, full.names = T)
                  
#looping through one tsv at a time

for(i in 1:length(fns)){
# i <- 4
  fn <- fns[i]
  dir <- basename(fn)  %>% str_replace_all(".tsv", "")

    cat(paste0("I'm on ", dir, ". It is number ", i, " out of ", length(fns) ,". The time is ", Sys.time(),".\n"))

    
  if(file.exists(paste0("output/surprisal_per_feat_per_UPOS/surprisal_per_feat_per_UPOS_",  dir, ".tsv"))){
    cat(paste0("Already exists, moving on.\n"))
    
  }else{
    
  #reading in
conllu <- read_tsv(fn, show_col_types = F) 

## COUNTS
#some simple counts: count number of types, tokens, lemmas and sentences
n_tokens_per_sentence_df <- conllu %>% 
  group_by(sentence_id) %>% 
  summarise(n_tokens = n(), .groups = "drop")

## TTR
n_tokens <- sum(n_tokens_per_sentence_df$n_tokens)
n_types <- conllu$token %>% unique() %>%  na.omit() %>% length()
n_lemmas <- conllu$lemma %>% unique() %>%  na.omit() %>% length()
cat(paste0("The lemma-token-ratio is ", round(n_lemmas /  n_tokens, 4) , ".\n"))
cat(paste0("The type-token-ratio is ", round(n_types /  n_tokens, 4) , ".\n"))

data.frame(TTR = n_types /  n_tokens, 
           TTR_lemma = n_lemmas / n_tokens, 
           dir = dir) %>% 
  write_tsv(file = paste0("output/TTR/", dir, "_TTR_sum.tsv"))
  
conllu %>% 
  group_by(token, lemma, upos) %>% 
  summarise(n = n(), .groups = "drop") %>%
  write_tsv(file = paste0("output/TTR/", dir, "_TTR_full.tsv"))

surprisal_all_tokens_lookup <- conllu %>% 
  group_by(token) %>% 
  summarise(n = n()) %>% 
  ungroup() %>% 
  mutate(prop = n/nrow(conllu)) %>% 
  mutate(surprisal = log2(1/prop))

conllu %>% 
  left_join(surprisal_all_tokens_lookup, by = "token") %>% 
  group_by(sentence_id ) %>%
  summarise(surprisal = sum(surprisal), 
            n_token = n()) %>% 
  write_tsv(file = paste0("output/surprisal_per_token_sum_sentence/surprisal_per_token_sum_sentence_", dir,
                          ".tsv"))

conllu %>% 
  left_join(surprisal_all_tokens_lookup, by = "token") %>%
  write_tsv(file = paste0("output/surprisal_per_token/surprisal_per_token_", dir,
                          ".tsv"))

n_unique_lemma_per_sentence <- conllu %>% 
  dplyr::filter(!is.na(lemma)) %>% 
  distinct(sentence_id, lemma) %>%
  group_by(sentence_id) %>% 
  summarise(n_lemma = n(), .groups = "drop")
  
#counts

n_feats_per_token_df  <- conllu %>% 
  mutate(feats_n = str_count(feats, "=")) %>% 
  mutate(feats_n = ifelse(is.na(feats), 0, feats_n)) %>% 
  group_by(sentence_id) %>% 
  summarise(feats_per_token = paste0(feats_n, collapse = ";"), 
            n_tokens = n(), 
            feats_n = sum(feats_n)) 

df <- n_feats_per_token_df  %>% 
  full_join(n_unique_lemma_per_sentence, by = join_by(sentence_id)) %>% 
  dplyr::mutate(feats_ratio_sentence = feats_n / n_tokens) %>% 
  dplyr::mutate(dir = dir)

df %>% write_tsv(file = paste0("output/counts/counts_", dir, "_summarised.tsv"), na = "", quote = "all")

########## SORT OUT TAGGING

# There are inconsistencies in coding of different UD-projects. It is not the case that every token of the same part-of-speech (upos) are tagged for the same information. For example, some ADJ are tagged for NumType but others aren't. This is most likely not a problem for most UD-purposes, but for this project it causes issues. To address that, we find all the unique feat-types for each upos, and if a token isn't tagged for it, we tag it for it and we denote it as "unassigned". So for example, all ADJ that don't have NumType get "NumType == unassigned". Likewise, tokens that have no morph feats at all, and no token for that UPOS have any, get the morph type "unassigned" with the value "unassigned". This is necessary for the way we later compute surprisal and entropy.

#split for morph tags
conllu_split <- conllu %>%
  dplyr::mutate(feats = str_split(feats, "\\|")) %>% 
  tidyr::unnest(cols = c(feats))  %>%
  tidyr::separate(feats, sep = "=", into = c("feat", "feat_value"), remove = F)  %>% 
  mutate(feat = ifelse(feat %in% UD_feats_df$feat, feat, NA)) %>% 
  mutate(feat_value = ifelse(feat %in% UD_feats_df$feat, feat_value, NA)) %>% 
  mutate(feats = ifelse(feat %in% UD_feats_df$feat, feats, NA))  %>% 
  distinct()
  
upos_vec <- conllu$upos %>% unique() 

#empty df to join to in the for-loop
df <- data.frame(id = as.character(), 
                 new_feat = as.character(),
                 new_feat_value = as.character())

for(i in 1:length(upos_vec)){
  
#  i <- 7
  
wide <-  conllu_split %>% 
  filter(upos == upos_vec[i]) %>% 
  reshape2::dcast(id ~ feat, value.var = "feat_value") 
  
wide[is.na(wide)] <- "unassigned"
  
df <- wide %>% 
  melt(id.vars = "id") %>% 
  filter(variable != "NA") %>% 
  dplyr::mutate(across(everything(), as.character)) %>% 
  rename(new_feat = variable, new_feat_value = value) %>% 
  full_join(df, by = join_by(id, new_feat, new_feat_value))
  
}


conllu_split <- conllu_split %>% 
  full_join(df, relationship = "many-to-many", by = join_by(id)) %>% 
  dplyr::select(-feat, -feat_value) %>% 
  dplyr::rename(feat = new_feat, feat_value = new_feat_value) %>% 
  dplyr::distinct(id, sentence_id, token, lemma, feat, feat_value, upos) %>% 
  dplyr::mutate(feat = ifelse(is.na(feat) & is.na(feat_value), "unassigned", feat)) %>% 
  dplyr::mutate(feat_value = ifelse(feat == "unassigned" & is.na(feat_value), "unassigned", feat_value)) 


conllu <- conllu_split %>% 
  arrange(feat, feat_value) %>% 
  mutate(feats_combo = paste0(feat, "=", feat_value)) %>% 
  group_by(id) %>% 
  summarise(feats_new = paste0(unique(feats_combo), collapse = "|")) %>% 
  full_join(conllu, by = "id") %>% 
  dplyr::select(-feats) %>% 
  rename(feats = feats_new) %>% 
  dplyr::distinct(id, sentence_id, token_id, token, lemma, feats, upos) 
  
####
####
####


#computing the probabilities and surprisal of each morph tag value per lemma

#prop for each morph feat
lookup <- conllu_split %>% 
  group_by(lemma, upos, feat, feat_value) %>% 
  summarise(n = n(), .groups = "drop") %>% 
  group_by(lemma, upos, feat) %>% 
  mutate(sum = sum(n)) %>% 
  ungroup() %>% 
  mutate(prop = n/sum) %>% 
  mutate(surprisal = log2(1/prop)) %>%
  dplyr::select(lemma, upos, feat, feat_value, n, prop, surprisal)

lookup %>% 
  write_tsv(file = paste0("output/surprisal_per_feat_per_lemma_lookup/surprisal_per_feat_per_lemma_lookup_", dir, ".tsv"),na = "", quote = "all")


#adding in probs for the combined string of morph feats
lookup_not_split <- conllu %>% 
  group_by(lemma, upos, feats) %>% 
  summarise(n = n(), .groups = "drop") %>% 
  group_by(lemma, upos) %>% 
  mutate(sum = sum(n)) %>% 
  ungroup() %>% 
  mutate(prop = n/sum) %>% 
  mutate(surprisal = log2(1/prop)) %>% 
  dplyr::select(lemma, upos, feats,n, prop, surprisal_per_morph_full_string = surprisal)

lookup %>% 
  write_tsv(file = paste0("output/surprisal_per_featstring_per_lemma_lookup/surprisal_per_featstring_per_lemma_lookup_", dir, ".tsv"),na = "", quote = "all")

token_surprisal_df <- conllu_split %>% 
  dplyr::distinct(id, token, lemma, feat, feat_value, upos) %>% 
  left_join(lookup, by = join_by(lemma, feat, feat_value, upos)) %>% 
 # dplyr::distinct(id, token, lemma, feat, feat_value, upos, surprisal) %>% 
  group_by(id) %>% 
  summarise(sum_surprisal_morph_split = sum(surprisal)) 

token_surprisal_df <- conllu %>% 
  distinct(id, token, lemma, feats, upos) %>% 
  left_join(lookup_not_split, by = join_by(lemma, feats, upos)) %>% 
  full_join(token_surprisal_df, by = join_by(id))

token_surprisal_df %>%
  write_tsv(file = paste0("output/surprisal_per_feat_per_lemma/surprisal_per_feat_per_lemma_",  dir, ".tsv"), na = "", quote = "all")

###surprisal per upos

#computing the probabilities and surprisal of each morph tag value per upos

#prop for each morph feat
lookup <- conllu_split %>% 
  group_by(upos, feat, feat_value) %>% 
  summarise(n = n(), .groups = "drop") %>% 
  group_by(upos, feat) %>% 
  mutate(sum = sum(n)) %>% 
  ungroup() %>% 
  mutate(prop = n/sum) %>% 
  mutate(surprisal = log2(1/prop)) %>%
  dplyr::select(upos, feat, feat_value, n, prop, surprisal)

lookup %>% 
  write_tsv(file = paste0("output/surprisal_per_feat_per_UPOS_lookup/surprisal_per_feat_per_UPOS_lookup_", dir, ".tsv"),na = "", quote = "all")

#adding in probs for the combined string of morph feats
lookup_not_split <- conllu %>% 
  group_by(upos, feats) %>% 
  summarise(n = n(), .groups = "drop") %>% 
  group_by(upos) %>% 
  mutate(sum = sum(n)) %>% 
  ungroup() %>% 
  mutate(prop = n/sum) %>% 
  mutate(surprisal = log2(1/prop)) %>% 
  dplyr::select(upos, feats, n, prop, surprisal_per_morph_full_string = surprisal)

lookup %>% 
  write_tsv(file = paste0("output/surprisal_per_featstring_per_UPOS_lookup/surprisal_per_featstring_per_UPOS_lookup_", dir, ".tsv"), na = "", quote = "all")

token_surprisal_df <- conllu_split %>% 
  dplyr::distinct(id, token, feat, feat_value, upos) %>% 
  left_join(lookup, by = join_by(feat, feat_value, upos)) %>% 
  group_by(id) %>% 
  summarise(sum_surprisal_morph_split = sum(surprisal)) 

token_surprisal_df <- conllu %>% 
  distinct(id, token, feats, upos) %>% 
  left_join(lookup_not_split, by = join_by(feats, upos)) %>% 
  full_join(token_surprisal_df, by = join_by(id))

token_surprisal_df %>%
  write_tsv(file = paste0("output/surprisal_per_feat_per_UPOS/surprisal_per_feat_per_UPOS_",  dir, ".tsv"), na = "", quote = "all")

}
}
