
using_groundhog <- "no"

#set cut-off for inclusion. number of tokens minially
minimum_tokens = 2000

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

if(using_groundhog == "yes"){
  
  if(!"groundhog" %in% installed.packages()){
    print("groundhog not installed, installing now")
    install.packages("groundhog")
  }
  
  library(groundhog)
  
  groundhog_date <- "2025-01-17"
  
  groundhog_dir <- paste0("groundhog_libraries_", groundhog_date)
  
  if(!dir.exists(groundhog_dir)){
    print(paste0("groundhog directory ", groundhog_dir, " does not exist, creating it now"))
    print(paste0("current working directory: ",getwd()))
    dir.create(groundhog_dir)
    print(paste0("groundhog directory ", groundhog_dir, " created"))
  }
  groundhog::set.groundhog.folder(groundhog_dir)
  

print("loading packages via groundhog...")
groundhog::groundhog.library(pkg = pkgs ,
                             date = groundhog_date, tolerate.R.version='4.5.0')
print("packages loaded successfully.")
}

if(using_groundhog == "no"){
  if(!"pacman" %in% installed.packages()){
    install.packages("pacman")
  }

  for(pkg in pkgs){
#    print(pkg)
    pacman::p_load(pkg,character.only = T)
  }
    
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

p <- "rgrambank"
if(!(p %in% rownames(installed.packages()))){
  print("rgrambank not installed, installing from github now")
  devtools::install_github("HedvigS/rgrambank", dependencies = F, ref = "7e7a59fa1c0a99b33d743b5376c2c8441517943c")
}
library(rgrambank)

p <- "SH.misc"
if(!(p %in% rownames(installed.packages()))){
  print("SH.misc not installed, installing from github now")
  devtools::install_github("HedvigS/SH.misc", dependencies = F, ref = "dc530b1cdc1ae4dbe9b29d695c153a6c50247a6e")
}
library(SH.misc)

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

