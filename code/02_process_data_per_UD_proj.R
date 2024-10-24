source("01_requirements.R")

fns <- list.files(path = paste0("output/processed_data/", UD_version), pattern = ".tsv", all.files = T, full.names = T)
                  
#looping through one tsv at a time

for(i in 1:length(fns)){
# i <- 238
  fn <- fns[i]

    cat(paste0("I'm on ", basename(fn), ". It is number ", i, " out of ", length(fns) ,". The time is ", Sys.time(),".\n"))

  #reading in
conllu <- read_tsv(fn, show_col_types = F) 


#some simple counts: count number of types, tokens, lemmas and sentences
n_tokens_per_sentence_df <- conllu %>% 
  group_by(sentence_id) %>% 
  summarise(n_tokens = n(), .groups = "drop")

## TTR
n_tokens <- sum(n_tokens_per_sentence_df$n_tokens)
n_lemmas <- conllu$lemma %>% unique() %>%  na.omit() %>% length()
cat(paste0("The type(lemma)-token-ratio is ", round(n_lemmas /  n_tokens, 4) , ".\n"))

conllu %>% 
  group_by(lemma, upos) %>% 
  summarise(n = n(), .groups = "drop") %>% 
  write_tsv(file = paste0("output/TTR/", basename(fn), "TTR.tsv"))

n_unique_lemma_per_sentence <- conllu %>% 
  dplyr::filter(is.na(lemma)) %>% 
  distinct(sentence_id, lemma) %>%
  group_by(sentence_id) %>% 
  summarise(n_lemma = n(), .groups = "drop")
  

########## SORT OUT TAGGING

# There are inconsistencies in coding of different UD-projects. It is not the case that every token of the same part-of-speech (upos) are tagged for the same information. For example, some ADJ are tagged for NumType but others aren't. This is most likely not a problem for most UD-purposes, but for this project it causes issues. To address that, we find all the unique feat-types for each upos, and if a token isn't tagged for it, we tag it for it and we denote it as "unassigned". So for example, all ADJ that don't have NumType get "NumType == unassigned". Likewise, tokens that have no morph feats at all, and no token for that UPOS have any, get the morph type "unassigned" with the value "unassigned". This is necessary for the way we later compute surprisal and entropy.

#split for morph tags
conllu_split <- conllu %>%
  dplyr::mutate(feats = str_split(feats, "\\|")) %>% 
  tidyr::unnest(cols = c(feats))  %>% 
  tidyr::separate(feats, sep = "=", into = c("feat", "feat_value"), remove = F) 

upos_vec <- conllu$upos %>% unique() 

#empty df to join to in the for-loop
df <- data.frame(id = as.character(), 
                 new_feat = as.character(),
                 new_feat_value = as.character())

for(i in 1:length(upos_vec)){
  
#  i <- 1
  
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

#adding in probs for the combined string of morph feats
lookup_not_split <- conllu %>% 
  group_by(lemma, upos, feats) %>% 
  summarise(n = n(), .groups = "drop") %>% 
  group_by(lemma, upos) %>% 
  mutate(sum = sum(n)) %>% 
  ungroup() %>% 
  mutate(prop = n/sum) %>% 
  mutate(surprisal = log2(1/prop)) %>% 
  dplyr::select(lemma, upos, feats, surprisal_per_morph_full_string = surprisal)

token_surprisal_df <- conllu_split %>% 
  dplyr::distinct(id, token, lemma, feat, feat_value, upos) %>% 
  left_join(lookup, by = join_by(lemma, feat, feat_value, upos)) %>% 
 # dplyr::distinct(id, token, lemma, feat, feat_value, upos, surprisal) %>% 
  group_by(id) %>% 
  summarise(sum_surprisal_per_morph_feat = sum(surprisal)) 

token_surprisal_df <- conllu %>% 
  distinct(id, token, lemma, feats, upos) %>% 
  left_join(lookup_not_split, by = join_by(lemma, feats, upos)) %>% 
  full_join(token_surprisal_df, by = join_by(id))

token_surprisal_df %>% 
  write_tsv(file = paste0("output/suprisal/surprisal",  basename(fn), ".tsv"), na = "", quote = "all")

###


n_feats_per_sentence_df <- conllu_split %>% 
  group_by(sentence_id) %>% 
  summarise(feats_n = n(), .groups = "drop") 

n_feats_per_token_df <- conllu_split %>% 
  group_by(sentence_id, id) %>% 
  summarise(feats_n = n(), .groups = "drop") %>% 
  group_by(sentence_id) %>% 
  summarise(feats_per_token = paste0(feats_n, collapse = ";"),
            mean_feats_per_token = mean(feats_n)) 

df <- n_tokens_per_sentence_df  %>% 
  full_join(n_unique_lemma_per_sentence, by = join_by(sentence_id)) %>% 
  full_join(n_feats_per_sentence_df, by = join_by(sentence_id)) %>% 
  full_join(n_feats_per_token_df , by = join_by(sentence_id)) %>% 
  dplyr::mutate(feats_ratio_sentence = feats_n / n_tokens) %>% 
  dplyr::mutate(fn = fn)

df %>% write_tsv(file = paste0("output/counts/count", basename(fn), "_summarised.tsv"), na = "", quote = "all")

}

