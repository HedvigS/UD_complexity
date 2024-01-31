source("01_requirements.R")

UD <- udpipe::udpipe_read_conllu("../data/ud-treebanks-v2.13/UD_Irish-IDT/ga_idt-ud-train.conllu")
UD <- udpipe::udpipe_read_conllu("../data/ud-treebanks-v2.13/UD_English-EWT/en_ewt-ud-train.conllu")

UD_split <- UD %>%
  mutate(feats = str_split(feats, "\\|")) %>% 
  tidyr::unnest(cols = c(feats)) 

UD_split_summarised <- UD_split %>% 
  filter(!is.na(feats)) %>% 
  group_by(sentence_id, token_id) %>% 
  summarise(n = n(), .groups = "drop") %>% 
  group_by(sentence_id) %>% 
  summarise(n = sum(n))

UD_split_summarised$n %>% hist()  
