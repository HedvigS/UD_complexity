source("01_requirements.R")

ud_lgs <- read_tsv("../data/UD_languages.tsv", show_col_types = F) %>% 
  mutate(`ISO639-3_individual` = ifelse(!is.na(`ISO 639-3_macrolanguage`), 
                                        `ISO 639-3_macrolanguage`,
                                        `ISO639-3_individual`
                                        )) %>% 
  dplyr::select(ISO639P3code = `ISO639-3_individual`, glottocode_ud = glottocode)

glottolog <- read_tsv("../data/glottolog_language_table_wide_df_3.0.tsv",
                      show_col_types = F) %>% 
  dplyr::select(glottocode_glottolog = Glottocode, ISO639P3code)

right_join(glottolog, ud_lgs) %>% 
  mutate(diff = glottocode_glottolog == glottocode_ud) %>% View()
