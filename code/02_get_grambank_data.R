#This script takes the values and languages tables from a cldf-release and combines then and transforms them to a wide data format from a long. It does not take into account the parameter or code tables.

source("01_requirements.R")

source("../utility/SH_misc/get_zip_from_url.R")
source("../utility/rgrambank/make_binary_ParameterTable.R")
source("../utility/rgrambank/make_binary_ValueTable.R")
source("../utility/rgrambank/make_theo_scores.R")
source("../utility/rgrambank/reduce_ValueTable_to_unique_glottocodes.R")

if(!file.exists("output/processed_data/grambank/cldf/codes.csv")){
    
    #checking out specifically v1.0, which is commit 9e0f341
  get_zip_from_url(url = "https://zenodo.org/records/7740140/files/grambank/grambank-v1.0.zip", 
                   exdir= "output/processed_data/grambank/")
  }
  
grambank <- rcldf::cldf("output/processed_data/grambank/", load_bib = F)

ValueTable <- grambank$tables$ValueTable 
LanguageTable <- grambank$tables$LanguageTable
ParameterTable <- grambank$tables$ParameterTable

ValueTable_binary <- make_binary_ValueTable(ValueTable = ValueTable, keep_multistate = FALSE, keep_raw_binary = TRUE)
ParameterTable_binary <- make_binary_ParameterTable(ParameterTable = ParameterTable,
                                                               keep_multi_state_features = FALSE,
                                                               keep_raw_binary = TRUE)

ValueTable_binary_reduced <- reduce_ValueTable_to_unique_glottocodes(ValueTable = ValueTable_binary, LanguageTable = LanguageTable, merge_dialects = TRUE, method = "combine_random") %>% 
  dplyr::select(-Language_ID) %>% 
  dplyr::rename(Language_ID = Glottocode)

theo_scores <- make_theo_scores(ValueTable = ValueTable_binary_reduced, 
                                           ParameterTable = ParameterTable, Fusion_option = "count_one_and_half")

theo_scores %>% 
  write_tsv("output/processed_data/grambank_theo_scores.tsv")
