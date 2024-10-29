#This script takes the values and languages tables from a cldf-release and combines then and transforms them to a wide data format from a long. It does not take into account the parameter or code tables.

source("01_requirements.R")

if(!file.exists("output/processed_data/grambank/cldf/codes.csv")){
    
    #checking out specifically v1.0, which is commit 9e0f341
  SH.misc::get_zenodo_dir(url = "https://zenodo.org/records/7740140/files/grambank/grambank-v1.0.zip", 
                   exdir= "output/processed_data/grambank/")
  }
  
grambank <- rcldf::cldf("output/processed_data/grambank/", load_bib = F)

theo_scores <- rgrambank::make_theo_scores(ValueTable = grambank$tables$ValueTable, 
                                           ParameterTable = grambank$tables$ParameterTable)

theo_scores %>% 
  write_tsv("output/processed_data/grambank_theo_scores.tsv")
