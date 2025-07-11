
### loading 

#pkgs <- c(
#  "utf8" ,
#  "Rcpp",
#  "plyr",
#  "data.table",
#  "dplyr",
#  "readr",
#  "reader",
#  "tidyr",
# "stringr",
# "ggplot2",
#  "ggpubr",
#  "GGally",
# "curl",
#  "randomcoloR",
#  "devtools",
# "udpipe",
# "reshape2",
# "archive", #for rcldf
# "bib2df", #for rcldf
# "logger",#for rcldf
# "csvwr",#for rcldf
# "logger",#for rcldf
#  "urltools",#for rcldf
#  "caper", #for SH.misc
#  "tibble",
#  "magrittr",
#  "purrr",
#  "devtools",
#  "viridis",
#  "forcats",
#  "ggridges")

#packages we should load and other set-up

# Set CRAN mirror to avoid "trying to use CRAN without setting a mirror" error
options(repos = c(CRAN = "https://cloud.r-project.org/"))

lib_dir <- paste0("../utility/packages/")
if(!dir.exists(lib_dir)){
  dir.create(lib_dir)
}

.libPaths(lib_dir)

pkgs_df <- utils::read.delim(file = "../requirements.tsv", sep = "\t")

source("../utility/fun_def_h_load.R")

for(i in 1:nrow(pkgs_df)
    ){  
  
#  i <- 10
  pkg <- pkgs_df[i, c("Package")]
  version <- pkgs_df[i, c("Version")]
  
    h_load(pkg = pkg, version = version, lib = lib_dir, dependencies = T, verbose = T)
    }

#install.packages("data.table", lib = lib_dir) #dependency of udpipe
library("data.table", lib.loc = lib_dir)

#install.packages("Rtsne", lib = lib_dir) #depedency of randomcoloR
library("Rtsne", lib.loc = lib_dir)

UD_version <- "ud-treebanks-v2.14"

# UD data info
#https://lindat.mff.cuni.cz/repository/xmlui/handle/11234/1-5287
#https://lindat.mff.cuni.cz/repository/xmlui/bitstream/handle/11234/1-5287/ud-treebanks-v2.13.tgz?sequence=1&isAllowed=y

p <- "rcldf"
if(!(p %in% rownames(installed.packages()))){
  print("rcldf not installed, installing from github now")
remotes::install_github("SimonGreenhill/rcldf", dependencies = F, ref = "ab9554e763c646a5ea6a49fc0989cf9277322443", lib = lib_dir
                        )
}
library(rcldf, lib.loc = lib_dir)


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



