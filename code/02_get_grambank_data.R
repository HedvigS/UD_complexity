library(readr, lib.loc = "../utility/packages/")
library(dplyr, lib.loc = "../utility/packages/")
library(magrittr, lib.loc = "../utility/packages/")

if(!file.exists("../data/grambank/cldf/values.csv")){

  source("../utility/SH_misc/get_zip_from_url.R")
    #checking out specifically v1.0, which is commit 9e0f341
  get_zip_from_url(url = "https://zenodo.org/records/7740140/files/grambank/grambank-v1.0.zip", 
                   exdir= "../data/grambank/")
}
  
if(!file.exists("output/processed_data/grambank_theo_scores.tsv")){
    
ValueTable <- readr::read_csv("../data/grambank/cldf/values.csv", show_col_types = F) 
LanguageTable <- readr::read_csv("../data/grambank/cldf/languages.csv", show_col_types = F)
ParameterTable <- readr::read_csv("../data/grambank/cldf/parameters.csv", show_col_types = F)

#for computing the metric related to word order, it is necessary ot binarise the multistate features. This is done inside make_theo_scores, via other functions. We load all necessary functions here.
source("../utility/rgrambank/make_binary_ParameterTable.R")
source("../utility/rgrambank/make_binary_ValueTable.R")
source("../utility/rgrambank/make_theo_scores.R")
source("../utility/rgrambank/reduce_ValueTable_to_unique_glottocodes.R")

set.seed(72000)

ValueTable_reduced <- reduce_ValueTable_to_unique_glottocodes(ValueTable = ValueTable, LanguageTable = LanguageTable, merge_dialects = TRUE, method = "combine_random") %>% 
  dplyr::select(-Language_ID) %>% 
  dplyr::rename(Language_ID = Glottocode)

theo_scores <- make_theo_scores(ValueTable = ValueTable_reduced, 
                                           ParameterTable = ParameterTable, Fusion_option = "count_one_and_half")

theo_scores %>% 
  readr::write_tsv("output/processed_data/grambank_theo_scores.tsv")
}
