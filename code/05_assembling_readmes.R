# Fix libPaths to our local package directory
.libPaths("../utility/packages/")

library(readr, lib.loc = "../utility/packages/")
library(dplyr, lib.loc = "../utility/packages/")
library(magrittr, lib.loc = "../utility/packages/")

README_fns <- list.files(
  path = "../data/ud-treebanks-v2.14/",
  pattern = "README\\.[md$|txt$]",
  recursive = TRUE,
  full.names = TRUE
)

df <- readr::read_tsv("output/results/all_results.tsv", show_col_types = F)
dirs <- df$dir %>% paste0(collapse = "|")

output_dir <- "output/processed_data/relevant_READMES/"
if(!dir.exists(output_dir)){
  dir.create(output_dir)
  }

README_fns <- README_fns[str_detect(README_fns, dirs)] 

for(fn in README_fns){
#fn <- README_fns[24]
  lines <- base::readLines(fn, warn = FALSE)
  output_fn <- stringr::str_replace(fn, "../data/ud-treebanks-v2.14//", "") %>% stringr::str_replace("/", "_")
  base::writeLines(lines, con = paste0(output_dir, output_fn))
}

