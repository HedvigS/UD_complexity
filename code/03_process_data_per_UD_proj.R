
#directory = "output_test"
#agg_level = "upos" 
#core_features = "core_features_only"

source("01_requirements.R")

process_data_per_UD_proj <- function(directory = "output",
         agg_level = "upos", #lemma token
         core_features = "core_features_only"
             ){


if(!(agg_level %in% c("upos", "lemma", "token"))){
  stop("agg_level has to be either UPOS, lemma or token.")
}

if(!(core_features %in% c("core_features_only", "all_features"))){
  stop("core_features has to be either core_features_only or all_features")
}

fns <- list.files(path = paste0(directory, "/processed_data/", UD_version), pattern = ".tsv", all.files = T, full.names = T)

UD_core_feats_df <- data.frame(
  feat = c("PronType", "NumType", "Poss", "Reflex", "Abbr", "Typo", "Foreign", "ExtPos", "Gender", "Animacy", "NounClass", "Number", "Case", "Definite", "Deixis", "DeixisRef", "Degree", "VerbForm", "Mood", "Tense", "Aspect", "Voice", "Evident", "Polarity", "Person", "Polite", "Clusivity"),
  type = c("Lexical", "Lexical",  "Lexical",  "Lexical",  "Other", "Other", "Other", "Other",  "Nominal", "Nominal", "Nominal", "Nominal", "Nominal", "Nominal", "Nominal", "Nominal", "Nominal", "Verbal", "Verbal", "Verbal", "Verbal", "Verbal", "Verbal", "Verbal", "Verbal", "Verbal", "Verbal")
)

bad_UD_morph_feat_cats <-  c("Abbr", "Typo", "Foreign")

#set up the output dirs
output_dirs <- c(
"TTR",
"surprisal_per_token",
"surprisal_per_feat_lookup",
"surprisal_per_featstring_lookup",
"surprisal_per_feat", 
"surprisal_per_featstring", 
"summarised")

for(dir_spec in output_dirs ){
dir_spec <- paste0(directory, "/", dir_spec)
if(!dir.exists(dir_spec)){
  dir.create(dir_spec)
}
}
                  
#looping through one tsv at a time

for(i in 1:length(fns)){
# i <- 1
  fn <- fns[i]
  dir <- basename(fn)  %>% str_replace_all(".tsv", "")

    cat(paste0("I'm on ", dir, " for agg level ", agg_level, " with ", core_features, ". It is number ", i, " out of ", length(fns) ,". The time is ", Sys.time(),".\n"))
    
  #reading in
conllu <- read_tsv(fn, show_col_types = F, col_types =  cols(.default = "c")) %>% 
  mutate(lemma = paste0(lemma, "_", upos)) #the same lemma but differen upos should count as different lemmas. e.g. "bow" (weapon) and "bow" (bodily gesture) should be counted as different

########## SORT OUT TAGGING

# There are inconsistencies in coding of different UD-projects. It is not the case that every token of the same part-of-speech (upos) are tagged for the same information. For example, some ADJ are tagged for NumType but others aren't. This is most likely not a problem for most UD-purposes, but for this project it causes issues. To address that, we find all the unique feat-types for each upos, and if a token isn't tagged for it, we tag it for it and we denote it as "unassigned". So for example, all ADJ that don't have NumType get "NumType == unassigned". Likewise, tokens that have no morph feats at all, and no token for that UPOS have any, get the morph type "unassigned" with the value "unassigned". This is necessary for the way we later compute surprisal and entropy.

#split for morph tags
conllu_split <- conllu %>%
  dplyr::mutate(feats_split = str_split(feats, "\\|")) %>% #split the feature cell for each feature
  tidyr::unnest(cols = c(feats_split))  %>% #unravel the feature cell into separate rows for each feature
  tidyr::separate(feats_split, sep = "=", into = c("feat_cat", "feat_value"), remove = T)  %>% #split the feature into its two components: feat_cat and feat_value
  mutate(feat_cat = ifelse(feat_cat %in% bad_UD_morph_feat_cats, yes = NA, no = feat_cat)) %>% #if the feat_cat belongs to a set of feat_cats which is not relevant for the study, replace it with NA. the irrelevant set is defined in 01_requirements.R
  {
    if (core_features == "core_features_only") { #if the variable core_features_only is set to TRUE, we only keep features that belong to this core set. UD_core_feats_df is defined in 01_requirements.R
      mutate(., feat_cat = ifelse(feat_cat %in% UD_core_feats_df$feat, feat_cat, NA))
    } else {
      .
    }
  } %>%
  mutate(feats_combo = ifelse(!is.na(feat_cat), paste0(feat_cat, "=", feat_value), NA)) %>% #stick feat_cat and feat_value back together, unless the feat_cat was in that previously mentioned irrelevant category
  group_by(id, sentence_id, token, lemma, upos) %>% #ironically, we now need to get back to the previous state of feature strings (several features) and then split it again to get everything to line up. Can also be done in two dfs and joins, but this works as well.
  summarise(feats_trimmed = paste0(unique(na.exclude(feats_combo)), collapse = "|"), .groups = "keep") %>% 
  mutate(feats_trimmed = ifelse(feats_trimmed == "", NA, feats_trimmed)) %>% 
  dplyr::mutate(feats_split = str_split(feats_trimmed, "\\|")) %>% 
  tidyr::unnest(cols = c(feats_split))  %>%
  tidyr::separate(feats_split, sep = "=", into = c("feat_cat", "feat_value"), remove = T) %>%  
  dplyr::select(-feats_trimmed) %>% 
  distinct() %>% 
  ungroup()

n_feat_cats = conllu_split$feat_cat %>% na.omit() %>% unique() %>% length()

n_feats_per_token_df  <- conllu_split %>% 
  group_by(id) %>% 
  mutate(feats_n = n()) %>% 
  mutate(feats_n = ifelse(is.na(feat_cat), 0, feats_n)) %>% 
  distinct(id, feats_n)

# for stepping through Abaza for agg_level upos and core-features
# all tokens with lemma Iанхара_VERB should have polarity = unassigned
# All tokens with UPOS ADJ should have unassigned = unassigned
  
agg_level_feat_cat_df_distinct <- conllu_split %>% 
  dplyr::select(all_of(agg_level), feat_cat) %>% 
  filter(!is.na(feat_cat)) %>% 
  distinct() 

token_info <- conllu_split %>%
  distinct(id, sentence_id, token, lemma, upos)

expanded <- token_info %>%
  left_join(agg_level_feat_cat_df_distinct , by = agg_level, relationship = "many-to-many")  # brings in only feat_cats attested for this agg_level

conllu_split_dummys_inserted  <- expanded %>%
  left_join(conllu_split, by = c("id", "token","sentence_id", "lemma", "upos", "feat_cat")) %>%
  mutate(feat_value = coalesce(feat_value, "unassigned")) %>% 
  mutate(feat_cat = ifelse(is.na(feat_cat), "unassigned", feat_cat))

####################################

#for some computations, we need the original format with one row per token. here we render that back again
conllu <- conllu_split_dummys_inserted  %>% 
  mutate(feats_combo = paste0(feat_cat, "=", feat_value)) %>% 
  arrange(feat_cat) %>% 
  group_by(id) %>% 
  summarise(feats_new = paste0(unique(feats_combo), collapse = "|")) %>% 
  full_join(conllu, by = "id") %>% 
  dplyr::select(-feats) %>% 
  rename(feats = feats_new) %>% 
  dplyr::distinct(id, sentence_id, token_id, token, lemma, feats, upos) 
  
###

## COUNTS
#some simple counts: count number of types, tokens, lemmas and sentences
n_tokens_per_sentence_df <- conllu %>% 
  group_by(sentence_id) %>% 
  summarise(n_tokens = n(), .groups = "drop")

## TTR
n_tokens <- conllu %>% nrow()
n_types <- conllu$token %>% unique() %>%  na.omit() %>% length()
n_lemmas <- conllu$lemma %>% unique() %>%  na.omit() %>% length()
cat(paste0("The lemma-token-ratio is ", round(n_lemmas /  n_tokens, 4) , ".\n"))
cat(paste0("The type-token-ratio is ", round(n_types /  n_tokens, 4) , ".\n"))

data.frame(TTR = n_types /  n_tokens, 
           TTR_lemma = n_lemmas / n_tokens, 
           dir = dir) %>% 
  write_tsv(file = paste0(directory, "/TTR/", dir, "_TTR_sum.tsv"))

conllu %>% 
  group_by(token, lemma, upos) %>% 
  summarise(n = n(), .groups = "drop") %>% 
  mutate(dir = dir) %>% 
  write_tsv(file = paste0(directory, "/TTR/", dir, "_TTR_full.tsv"))

surprisal_all_tokens_lookup <- conllu %>% 
  group_by(token) %>% 
  summarise(n = n(), .groups = "drop") %>%
  mutate(prop = n/nrow(conllu)) %>% 
  mutate(surprisal = log2(1/prop))

surprisal_token <- conllu %>% 
  left_join(surprisal_all_tokens_lookup, by = "token") 

conllu %>% 
  left_join(surprisal_all_tokens_lookup, by = "token") %>%
  mutate(dir = dir) %>% 
  write_tsv(file = paste0(directory, "/surprisal_per_token/surprisal_per_token_", dir,
                          ".tsv"))

n_unique_lemma_per_sentence <- conllu %>% 
  dplyr::filter(!is.na(lemma)) %>% 
  distinct(sentence_id, lemma) %>%
  group_by(sentence_id) %>% 
  summarise(n_lemma = n(), .groups = "drop")

########## custom metrics
#computing the probabilities and surprisal of each morph tag value per lemma

#prop for each morph feat
lookup <- conllu_split_dummys_inserted  %>% 
  group_by(.data[[agg_level]], feat_cat, feat_value) %>% 
  summarise(n = n(), .groups = "drop") %>% 
  group_by(.data[[agg_level]], feat_cat) %>% 
  mutate(sum = sum(n)) %>% 
  ungroup() %>% 
  mutate(prop = n/sum) %>% 
  mutate(surprisal = log2(1/prop)) %>%
  dplyr::select(all_of(agg_level), feat_cat, feat_value, n, prop, surprisal)

lookup %>% 
  mutate(dir = dir) %>% 
  write_tsv(file = paste0(directory, "/surprisal_per_feat_lookup/surprisal_per_feat_lookup_agg_level_",agg_level, "_", core_features, "_", dir, ".tsv"),na = "", quote = "all")

token_surprisal_df <- conllu_split_dummys_inserted  %>% 
  dplyr::distinct(id, token, lemma, feat_cat, feat_value, upos) %>% 
  left_join(lookup, by = c(agg_level, "feat_cat", "feat_value")) %>%
  group_by(id) %>% 
  summarise(sum_surprisal_morph_split = sum(surprisal)) 

token_surprisal_df %>% 
  mutate(dir = dir) %>% 
  write_tsv(file = paste0(directory, "/surprisal_per_feat/surprisal_per_feat_per_agg_level_",agg_level, "_",  core_features, "_", dir, ".tsv"), na = "", quote = "all")

#featstrings
lookup_not_split <- conllu %>% 
  group_by(.data[[agg_level]], feats) %>% 
  summarise(n = n(), .groups = "drop") %>% 
  group_by(.data[[agg_level]]) %>% 
  mutate(sum = sum(n)) %>% 
  ungroup() %>% 
  mutate(prop = n/sum) %>% 
  mutate(surprisal = log2(1/prop)) %>% 
  dplyr::select(all_of(agg_level), feats,n, prop, surprisal_per_morph_featstring = surprisal)

lookup_not_split %>% 
  mutate(dir = dir) %>% 
  write_tsv(file = paste0(directory, "/surprisal_per_featstring_lookup/surprisal_per_featstring_lookup_agg_level_",agg_level, "_", core_features, "_", dir, ".tsv"),na = "", quote = "all")

token_surprisal_df_feat_string <- conllu %>% 
  distinct(id, token, lemma, feats, upos) %>% 
  left_join(lookup_not_split, by = c(agg_level, "feats")) 

token_surprisal_df_feat_string %>% 
  mutate(dir = dir) %>% 
  write_tsv(file = paste0(directory, "/surprisal_per_featstring/surprisal_per_featstring_per_agg_level_",agg_level, "_",  core_features, "_", dir, ".tsv"), na = "", quote = "all")


data.frame(dir = dir, 
           agg_level = agg_level, 
           core_features = core_features,
           n_types = n_types, 
           n_tokens = n_tokens, 
           n_sentences = conllu$sentence_id %>% unique() %>% length(), 
           n_feat_cats = n_feat_cats,
           TTR = n_types /  n_tokens, 
           LTR = n_lemmas / n_tokens, 
           n_feats_per_token_mean = n_feats_per_token_df$feats_n %>% mean(),
           suprisal_token_mean = surprisal_token$surprisal %>% mean(), 
           sum_surprisal_morph_split_mean = token_surprisal_df$sum_surprisal_morph_split %>% mean() ,
           surprisal_per_morph_featstring_mean = token_surprisal_df_feat_string$surprisal_per_morph_featstring  %>% mean()) %>%
  write_tsv(file = paste0(directory, "/summarised/", dir, "_summarised_agg_level_",agg_level, "_",  core_features, ".tsv"), na = "", quote = "all")
}
}
