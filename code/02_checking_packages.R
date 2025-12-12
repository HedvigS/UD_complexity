library(dplyr) 
library(bib2df)
library(tibble)
library(knitr)
library(magrittr)
library(tidyr)
library(reader)
library(xtable)

source("../../SH.misc/R/credit_packages.R")

fns <- list.files("../", pattern = ".R$", recursive = T, full.names = T)
fns <- fns[stringr::str_detect(fns, "utility/packages/", negate = TRUE)]



credit_packages(fns = fns, output_dir = ".")
