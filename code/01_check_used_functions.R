source("01_requirements.R")

fns <- list.files(path = ".", all.files = T, full.names = T, recursive = F, pattern = ".R$")

SH.misc::credit_packages(fns = fns, output_dir = "../latex/")
