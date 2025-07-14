#This script takes the values and languages tables from a cldf-release and combines then and transforms them to a wide data format from a long. It does not take into account the parameter or code tables.

library(readr, lib.loc = "../utility/packages/")
library(dplyr, lib.loc = "../utility/packages/")
library(reshape2, lib.loc = "../utility/packages/")
library(magrittr, lib.loc = "../utility/packages/")

if(!file.exists("output/processed_data/glottolog_5.0_languages.tsv")){

# fetching Glottolog v5.0 LanguageTable and ValueTable from GitHub, specifically the branch tied to the release of 5.0
  if(!file.exists("../data/glottolog/values.csv")){
    readr::read_csv("https://github.com/glottolog/glottolog-cldf/raw/refs/tags/v5.0/cldf/values.csv", 
                    show_col_types = F) %>% 
      readr::write_csv("../data/glottolog/values.csv",quote = "all", na = "")
  }
  
  if(!file.exists("../data/glottolog/languages.csv")){
  
    readr::read_csv("https://github.com/glottolog/glottolog-cldf/raw/refs/tags/v5.0/cldf/languages.csv",
                    show_col_types = F) %>% 
      readr::write_csv("../data/glottolog/languages.csv",quote = "all", na = "")
    }
  
ValueTable_wide <- readr::read_csv("../data/glottolog/values.csv", show_col_types = F) %>% 
  reshape2::dcast(Language_ID ~ Parameter_ID, value.var = "Value")
  
readr::read_csv("../data/glottolog/languages.csv", show_col_types = F) %>% 
  dplyr::rename(Language_level_ID = Language_ID, Language_ID = ID) %>% 
  dplyr::full_join(ValueTable_wide, by = "Language_ID") %>% 
  readr::write_tsv("output/processed_data/glottolog_5.0_languages.tsv")
}
