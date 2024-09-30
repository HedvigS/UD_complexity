### loading packages

groundhog_date <- "2024-01-17"

if (!'groundhog' %in% installed.packages()) install.packages('groundhog')
library('groundhog')

groundhog_dir <- paste0("groundhog_libraries_", groundhog_date)

groundhog::set.groundhog.folder(groundhog_dir)

pkgs <- c("utf8", 
          "Rcpp",
          "plyr",
          "data.table",
        "dplyr",
          "readr",
          "tidyr",
          "stringr",
          "ggplot2",
          "ggpubr",
        "psych",
          "udpipe",
          "reshape2",
          "tibble")

groundhog.library(pkgs, groundhog_date)

#source("fun_def_h_load.R")
#h_load(pkg = pkgs)

# UD data info
#https://lindat.mff.cuni.cz/repository/xmlui/handle/11234/1-5287
#https://lindat.mff.cuni.cz/repository/xmlui/bitstream/handle/11234/1-5287/ud-treebanks-v2.13.tgz?sequence=1&isAllowed=y

library(remotes)
p <- "rcldf"
if(!(p %in% rownames(installed.packages()))){
remotes::install_github("SimonGreenhill/rcldf", dependencies = F)
}

p <- "rgrambank"
if(!(p %in% rownames(installed.packages()))){
  remotes::install_github("HedvigS/rgrambank", dependencies = F)
  }

if(!dir.exists("output")){
  dir.create("output")
}

if(!dir.exists("output/sum_dfs")){
  dir.create("output/sum_dfs")
}

if(!dir.exists("output/processed_data/")){
  dir.create("output/processed_data/")
}

if(!dir.exists("output/UD_conllu/")){
  dir.create("output/UD_conllu/")
}


if(!file.exists("../data/google_pop.tsv")){

google_pop_stats <- read_tsv("https://github.com/google-research/url-nlp/raw/226e1a818aa1ce32311ef0931d9d44f2ab7ae084/language_metadata/data.tsv", show_col_types = F) %>% 
  dplyr::select(Glottocode = `Glottocode (Glottolog)`, 
                Pop = `Number of speakers (rounded)`)
google_pop_stats %>% write_tsv("../data/google_pop.tsv", na = "")
}

if(!dir.exists("output/plots")){
  dir.create("output/plots")
}


UD_feats_df <- data.frame(
  feat = c("PronType", "NumType", "Poss", "Reflex", "Abbr", "Typo", "Foreign", "ExtPos", "Gender", "Animacy", "NounClass", "Number", "Case", "Definite", "Deixis", "DeixisRef", "Degree", "VerbForm", "Mood", "Tense", "Aspect", "Voice", "Evident", "Polarity", "Person", "Polite", "Clusivity="),
  type = c("Lexical", "Lexical", "Lexical", "Lexical", "Other","Other","Other","Other", "Nominal","Nominal","Nominal","Nominal","Nominal","Nominal","Nominal","Nominal","Nominal","Verbal","Verbal","Verbal","Verbal","Verbal","Verbal","Verbal","Verbal","Verbal","Verbal")
  
)
  

