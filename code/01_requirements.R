
### loading 

pkgs <- c(
  "utf8" ,
  "Rcpp",
  "plyr",
  "data.table",
  "dplyr",
  "readr",
  "reader",
  "tidyr",
  "stringr",
  "ggplot2",
  "ggpubr",
  "GGally",
  "curl",
  "randomcoloR",
  "devtools",
  "udpipe",
  "reshape2",
  "archive", #for rcldf
  "bib2df", #for rcldf
  "logger",#for rcldf
  "csvwr",#for rcldf
  "logger",#for rcldf
  "urltools",#for rcldf
  "caper", #for SH.misc
  "tibble",
  "magrittr",
  "purrr",
  "devtools",
  "viridis",
  "forcats",
  "ggridges")

#packages we should load and other set-up


  source("../utility/fun_def_h_load.R")
for(pkg in pkgs){  
  h_load(pkg)
    }


set.seed(72000)
seed <- 72000

UD_version <- "ud-treebanks-v2.14"

# UD data info
#https://lindat.mff.cuni.cz/repository/xmlui/handle/11234/1-5287
#https://lindat.mff.cuni.cz/repository/xmlui/bitstream/handle/11234/1-5287/ud-treebanks-v2.13.tgz?sequence=1&isAllowed=y

p <- "rcldf"
if(!(p %in% rownames(installed.packages()))){
  print("rcldf not installed, installing from github now")
remotes::install_github("SimonGreenhill/rcldf", dependencies = F, ref = "ab9554e763c646a5ea6a49fc0989cf9277322443"
                        )
}
library(rcldf)


if(!dir.exists("output")){
  dir.create("output")
}

dir <- paste0("output/processed_data/")
if(!dir.exists(dir)){
  dir.create(dir)
}
  dir <- paste0("output/plots/")
if(!dir.exists(dir)){
  dir.create(dir)
}

print("Creating basemap for EEZ")
basemap <- SH.misc::basemap_EEZ(, south = "down", colour_border_land = "white",colour_land = "white", colour_border_eez = "lightgray", xlim = c(-25, 150), ylim = c(-40, 75)) 

