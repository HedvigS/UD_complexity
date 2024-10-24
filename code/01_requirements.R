### loading 

library(utf8) 
library(Rcpp)
library(plyr)
library(data.table)
library(dplyr)
library(readr)
library(tidyr)
library(stringr)
library(ggplot2)
library(ggpubr)
library(psych)
library(udpipe)
library(reshape2)
library(tibble)
library(purrr)
library(viridis)
library(forcats)
library(ggridges)


UD_version <- "ud-treebanks-v2.14"



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

dir <- "output/count_lookup_per_feat_per_lemma"
if(!dir.exists(dir)){
  dir.create(dir)
}

dir <- "output/count_lookup_per_featstring_per_lemma"
if(!dir.exists(dir)){
  dir.create(dir)
}

dir <- "output/count_lookup_per_feat_per_UPOS"
if(!dir.exists(dir)){
  dir.create(dir)
}

dir <- "output/count_lookup_per_featstring_per_UPOS"
if(!dir.exists(dir)){
  dir.create(dir)
}


dir <- "output/pronoun_freqs"
if(!dir.exists(dir)){
  dir.create(dir)
}


dir <- "output/suprisal_per_lemma"
if(!dir.exists(dir)){
  dir.create(dir)
}

dir <- "output/suprisal_per_UPOS"
if(!dir.exists(dir)){
  dir.create(dir)
}


dir <- "output/counts"
if(!dir.exists(dir)){
  dir.create(dir)
}

dir <- "output/processed_data/"
if(!dir.exists(dir)){
  dir.create(dir)
}

dir <- paste0("output/processed_data/", UD_version)
if(!dir.exists(dir)){
                dir.create(dir)
}

dir <- paste0("output/TTR/")
if(!dir.exists(dir)){
  dir.create(dir)
}
              
              
#if(!file.exists("../data/google_pop.tsv")){

#google_pop_stats <- read_tsv("https://github.com/google-research/url-nlp/raw/226e1a818aa1ce32311ef0931d9d44f2ab7ae084/language_metadata/data.tsv", show_col_types = F) %>% 
#  dplyr::select(Glottocode = `Glottocode (Glottolog)`, 
#                Pop = `Number of speakers (rounded)`)
#google_pop_stats %>% write_tsv(../data/google_pop.tsv, na = )
#}

if(!dir.exists("output/plots")){
  dir.create("output/plots")
}


UD_feats_df <- data.frame(
  feat = c("PronType", "NumType", "Poss", "Reflex", "Abbr", "Typo", "Foreign", "ExtPos", "Gender", "Animacy", "NounClass", "Number", "Case", "Definite", "Deixis", "DeixisRef", "Degree", "VerbForm", "Mood", "Tense", "Aspect", "Voice", "Evident", "Polarity", "Person", "Polite", "Clusivity"),
  type = c("Lexical", "Lexical",  "Lexical",  "Lexical",  "Other", "Other", "Other", "Other",  "Nominal", "Nominal", "Nominal", "Nominal", "Nominal", "Nominal", "Nominal", "Nominal", "Nominal", "Verbal", "Verbal", "Verbal", "Verbal", "Verbal", "Verbal", "Verbal", "Verbal", "Verbal", "Verbal")
  
)
  

