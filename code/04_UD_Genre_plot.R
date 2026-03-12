# Fix libPaths to our local package directory
.libPaths("../utility/packages/")

library(readr, lib.loc = "../utility/packages/")
library(dplyr, lib.loc = "../utility/packages/")
library(magrittr, lib.loc = "../utility/packages/")
library(stringr, lib.loc = "../utility/packages/")
library(tidyr, lib.loc = "../utility/packages/")
library(ggplot2, lib.loc = "../utility/packages/")

metadata_df <-  readr::read_tsv("output/metadata.df")

ud_dirs_used <- readr::read_tsv("output/results/all_results.tsv", show_col_types = FALSE) %>% dplyr::pull(dir) 

genre_df <- metadata_df %>% 
  dplyr::filter(treebank %in% ud_dirs_used) %>%
  dplyr::mutate(Genre = stringr::str_split(Genre, " ")) %>% 
  tidyr::unnest(Genre) %>%
  dplyr::group_by(Genre) %>% 
  dplyr::summarise(n = dplyr::n()) %>% 
  dplyr::arrange(dplyr::desc(n))

colors_17 <-  c(
  "#FF6F61", "#6B5B95", "purple", "#F7CAC9", "#EFC050",
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
    idx = dplyr::row_number(),
    # fixed distance for first 10, then spiral
    x_label = ifelse(idx <= 10, 5, 5 + (idx - 10)*0.5)
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
  ggplot2::geom_label(ggplot2::aes(x = x_label, y = label_pos, label = Genre),
             size = 4, alpha = 0.7) +
  ggplot2::theme_void() +
  ggplot2::theme(legend.position = "none") +
  ggplot2::scale_fill_manual(values = colors_17)

ggplot2::ggsave(filename = "output/plots/genre_doughnut.png", plot = p, width = 7, height = 7)

