### loading packages

groundhog_date = "2024-01-15"

if(!("groundhog" %in% rownames(installed.packages()))){
  
  install.packages("groundhog")
  library(groundhog)
  
}else{
  
  library(groundhog)
  
}

groundhog_dir <- paste0("groundhog_libraries_", groundhog_date)

if(!dir.exists(groundhog_dir)){
  dir.create(groundhog_dir)
}

groundhog::set.groundhog.folder(groundhog_dir)

pkgs <- c("dplyr",
          "readr",
          "tidyr",
          "stringr",
          "ggplot2",
          "udpipe",
          "reshape2",
          "tibble"
)

groundhog.library(pkgs, groundhog_date)

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
  remotes::install_github("grambank/rgrambank", dependencies = F)
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


