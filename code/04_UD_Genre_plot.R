library(readr, lib.loc = "../utility/packages/")
library(dplyr, lib.loc = "../utility/packages/")
library(magrittr, lib.loc = "../utility/packages/")
library(stringr, lib.loc = "../utility/packages/")
library(tidyr, lib.loc = "../utility/packages/")

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

ud_dirs_used <- readr::read_tsv("output/results/all_results.tsv", show_col_types = FALSE) %>% dplyr::pull(dir) 

metadata_df <- do.call(rbind, meta_list_aligned) %>% 
  dplyr::filter(treebank %in% ud_dirs_used) %>%
  dplyr::mutate(Genre = stringr::str_split(Genre, " ")) %>% 
  tidyr::unnest(Genre) 

genre_df <- metadata_df %>% 
  dplyr::group_by(Genre) %>% 
  dplyr::summarise(n = dplyr::n()) %>% 
  dplyr::arrange(dplyr::desc(n))

colors_17 <-  c(
  "#FF6F61", "#6B5B95", "#88B04B", "#F7CAC9", "#EFC050",
  "#955251", "#009B77", "#B565A7", "#DD4124", "#45B8AC",
  "#92A8D1", "#5B5EA6", "#9B2335", "#DFCFBE", "#BC243C",
  "#C3447A", "#9AD0EC"
)


# compute slice positions
df <- genre_df %>% 
  dplyr::mutate(Genre = paste0(Genre, " (", n, ")")) %>% 
  dplyr::mutate(
    fraction = n / sum(n),
    ymax = cumsum(fraction),
    ymin = c(0, head(ymax, n = -1)),
    label_pos = (ymax + ymin)/2,
    x_slice = 4,
    # row index
    idx = row_number(),
    # fixed distance for first 10, then spiral
    x_label = ifelse(idx <= 10, 5, 5 + (idx - 10) + 0.03)
  )

# plot
p <- ggplot2::ggplot(df, ggplot2::aes(ymax = ymax, ymin = ymin, xmax = x_slice, xmin = 2, fill = Genre)) +
  ggplot2::geom_rect(color = "white") +
  ggplot2::coord_polar(theta = "y") +
  ggplot2::xlim(0, max(df$x_label) + 0.2) +
  # connecting lines
  ggplot2::geom_segment(ggplot2::aes(x = x_slice, xend = x_label, y = label_pos, yend = label_pos),
               color = "grey40") +
  # labels
  ggplot2::geom_label(aes(x = x_label, y = label_pos, label = Genre),
             size = 4, alpha = 0.7) +
  ggplot2::theme_void() +
  ggplot2::theme(legend.position = "none") +
  ggplot2::scale_fill_manual(values = colors_17)

ggsave(filename = "output/plots/genre_doughnut.png", plot = p, width = 10, height = 10)

