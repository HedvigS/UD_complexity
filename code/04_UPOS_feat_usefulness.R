source("01_requirements.R")

Glottolog <- read_tsv("../data/glottolog_language_table_wide_df_3.0.tsv", show_col_types = F) %>% 
  dplyr::select(glottocode = Glottocode, Longitude, Latitude, Family_ID, Language_level_ID, Name)

UD_langs <- read_tsv("../data/UD_languages.tsv", show_col_types = F) %>% 
  dplyr::select(dir,  glottocode)

fns <- list.files("output/surprisal_per_feat_per_UPOS_lookup/",  full.names = T)

stacked <- SH.misc::stack_tsvs(fns = fns)

stacked$dir <-   stacked$filename%>% basename() %>% str_replace_all(".tsv", "") %>% str_replace_all("surprisal_per_feat_per_UPOS_lookup_", "") 


summed <- stacked %>% 
  group_by(filename, upos, feat) %>% 
  slice_max(prop)

summed$dir <- fct_reorder(summed$dir, summed$prop)

summed %>% 
  filter(upos =="NOUN") %>% 
  filter(feat =="Definite") %>% 
  ggplot() +
  geom_bar(aes(x = dir, y = prop), stat = "identity")
  