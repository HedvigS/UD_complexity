# Fix libPaths to our local package directory
.libPaths("../utility/packages/")

library(readr, lib.loc = "../utility/packages/")
library(dplyr, lib.loc = "../utility/packages/")
library(magrittr, lib.loc = "../utility/packages/")

parse_ud_metadata <- function(README_fn) {
  lines <- base::readLines(README_fn, warn = FALSE)
  
  # find last line that contains all four words (flexible match)
  # any characters (.*) allowed in between, case-insensitive
  start <- tail(
    grep("machine.*readable.*meta.*data", lines, ignore.case = TRUE),
    1
  )
  
  if (length(start) == 0) {
    stop("No machine-readable metadata block found in ", README_fn)
  }
  
  # candidate lines after header
  rest <- lines[(start + 1):length(lines)]
  
  # keep only lines with a colon
  kv_lines <- rest[grepl(":", rest)]
  
  if (length(kv_lines) == 0) {
    stop("No key-value metadata found in ", README_fn)
  }
  
  # stop at first Contact line (inclusive)
  contact_idx <- grep("^\\s*Contact\\s*:", kv_lines, ignore.case = TRUE)
  
  if (length(contact_idx) == 0) {
    stop("Metadata block has no Contact field in ", README_fn)
  }
  
  kv_lines <- kv_lines[1:contact_idx[1]]
  
  # parse key-value pairs
  kv <- strsplit(kv_lines, ":", fixed = TRUE)
  
  keys <- trimws(vapply(kv, `[`, character(1), 1))
  values <- trimws(vapply(
    kv,
    function(x) paste(x[-1], collapse = ":"),
    character(1)
  ))
  
  out <- as.data.frame(as.list(values), stringsAsFactors = FALSE)
  names(out) <- keys
  out$treebank <- basename(dirname(README_fn))
  
  out
}

README_fns <- list.files(
  path = "../data/ud-treebanks-v2.14/",
  pattern = "README\\.[md$|txt$]",
  recursive = TRUE,
  full.names = TRUE
)

meta_list <- lapply(README_fns, parse_ud_metadata)
all_cols <- unique(unlist(lapply(meta_list, names)))


meta_list_aligned <- lapply(meta_list, function(df) {
  missing <- setdiff(all_cols, names(df))
  if (length(missing) > 0) {
    df[missing] <- NA_character_
  }
  df[all_cols]   # enforce identical order
})


metadata_df <- do.call(rbind, meta_list_aligned) 

metadata_df %>% 
  dplyr::rename(dir = treebank) %>%
  readr::write_tsv("output/metadata.df")
