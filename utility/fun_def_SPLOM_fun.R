#library(randomcoloR, lib.loc = "../utility/packages/")
library(ggplot2, lib.loc = "../utility/packages/")
library(dplyr, lib.loc = "../utility/packages/")
library(scales, lib.loc = "../utility/packages/")

coloured_SPLOM <- function(df = df,
                           method = "pearson",
                           cor_test_method_exact = TRUE, 
                           pair_colors = "default", #if set to default, then we use randomcoloR::distinctColorPalette to find a set of distinct colors for the number of plots needed. This argument can also be set to a vector of hex-codes for colors (e.g. c("#E55679", "#5FE3B6", "#D447A0")).
                           col_pairs_to_constraint = "None",
                           col_pairs_constraint = "None",
                           hist_label_size  = 3, #font size of the text at the diagonal
                           text_cor_size = 7,
                           text_strip_size = 12,
                           hist_bins = 30,
                           herringbone = FALSE,
                           alpha_point = 0.8){

  method <- match.arg(method, c("pearson", "spearman"))
  
  if(all(col_pairs_constraint != "None")){
  df_without_id_vars <- df %>%
  dplyr::select(-all_of(col_pairs_constraint))
  }else{
    df_without_id_vars <- df
  }

n <- (length(names(df_without_id_vars)) * (length(names(df_without_id_vars)) - 1)) / 2

if(all(pair_colors == "default")){
# Generate a large number of distinct colors (one for each unique pair of variables)
stop("randomcoloR disabled due to package incompatabilities")
  #pair_colors <- randomcoloR::distinctColorPalette(k  = n)
}

if(herringbone == TRUE){

n_herring <- length(names(df_without_id_vars))
pair_colors_herring <- c()

for(i in 1:n_herring){
  spec <- rep(x = pair_colors[i], n_herring-i)
  pair_colors_herring <- c(pair_colors_herring, spec)
}

pair_colors_hist <- pair_colors
names(pair_colors_hist) <- names(df_without_id_vars)
pair_colors <- pair_colors_herring
}


if(n != length(pair_colors)){
  stop("pair_colors is not the right length. The length of pair_colors is ", length(pair_colors), " it should be ", n, ".")
}

# Create a named list to store unique colors for each pair
pair_colors_map <- list()

# Assign colors to each variable combination in the lower triangle
var_names <- names(df_without_id_vars)
index <- 1
for (i in 1:(length(var_names) - 1)) {
  for (j in (i + 1):length(var_names)) {
    pair_key <- paste(sort(c(var_names[i], var_names[j])), collapse = "_")
    pair_colors_map[[pair_key]] <- pair_colors[index]
    index <- index + 1
  }
}

# Custom lower triangle function to use unique colors
custom_lower <- function(data, mapping, pair_colors_map, ...){

  var1 <- ggplot2::as_label(mapping$x)
  var2 <- ggplot2::as_label(mapping$y)


  if(var1 %in% col_pairs_to_constraint &
     var2 %in% col_pairs_to_constraint){

    data_reduced <- dplyr::select(df, all_of(c(var1, var2, col_pairs_constraint))) %>%
      dplyr::distinct()

  }else{
    data_reduced <- dplyr::select(df_without_id_vars, all_of(c(var1, var2)))

  }

  # Select only the relevant variables
  data_reduced <- dplyr::select(data, all_of(c(var1, var2)))

  # Keep only complete cases (no NAs) and distinct rows
  data_reduced <- data_reduced[complete.cases(data_reduced), ]

  # Create a unique pair identifier (ignoring (x, y) vs (y, x))
  pair_key <- paste(sort(c(var1, var2)), collapse = "_")

  # Get the background color for the pair
  bg_color <- pair_colors_map[[pair_key]]

  ggplot2::ggplot(data_reduced, mapping) +
    ggplot2::geom_point(alpha = alpha_point, fill = bg_color,  shape = 21) +
    ggplot2::theme_minimal() +
    ggplot2::theme(
      panel.background = ggplot2::element_rect(fill = scales::alpha(bg_color, 0.5), color = NA),
      plot.background = ggplot2::element_rect(fill = scales::alpha(bg_color, 0.5), color = NA),
      panel.grid = ggplot2::element_blank()
    )
}


# Custom upper triangle function with correlation text and color control
custom_upper <- function(data, mapping, pair_colors_map, ...){
  var1 <- ggplot2::as_label(mapping$x)
  var2 <- ggplot2::as_label(mapping$y)

  if(var1 %in% col_pairs_to_constraint &
     var2 %in% col_pairs_to_constraint){

    data_reduced <- dplyr::select(df, all_of(c(var1, var2, col_pairs_constraint))) %>%
      dplyr::distinct()

  }else{
    data_reduced <- dplyr::select(df_without_id_vars, all_of(c(var1, var2)))

  }

  # Keep only complete cases (no NAs) and distinct rows
  data_reduced <- data_reduced[complete.cases(data_reduced), ]

  x <- data_reduced[[var1]]
  y <- data_reduced[[var2]]

  ct <- cor.test(x, y, method = method, exact = cor_test_method_exact)
  r <- ct$estimate
  p <- ct$p.value

  # Create a unique pair identifier (ignoring (x, y) vs (y, x))
  pair_key <- paste(sort(c(var1, var2)), collapse = "_")

  # Get the background color for the pair
  bg_color <- pair_colors_map[[pair_key]]

  # Set text color based on correlation strength and significance
  if (p < 0.05) {
    color_scale <- scales::col_bin(
      palette = c("grey40", "darkred"),
      bins = c(0, 0.6, 1),
      domain = c(0, 1)
    )

    text_color <- color_scale(abs(r))

    fontface <- if(r > 0.5|r<0.5){"bold"}else{"plain"}

  } else {
    text_color <- "grey60"
    fontface <- "plain"
  }

  label <- paste0(round(r, 2),ifelse(p < 0.05, "*", ""))
   sublabel <- paste0(               "(n=", nrow(data_reduced), ")")

  # Position of the text
  x_center <- 0.5
  y_center <- 0.5

  # Smaller padding values
  pad_x <- 0.4
  pad_y <- 0.3

  ggplot2::ggplot() +
    ggplot2::geom_rect(ggplot2::aes(xmin = x_center - pad_x, xmax = x_center + pad_x,
                  ymin = y_center - pad_y, ymax = y_center + pad_y),
              fill = "white", color = NA, alpha = 0.8) +
    ggplot2::annotate("text", x = x_center, y = y_center+0.1,
             label = label, size = text_cor_size, color = text_color, fontface = fontface) +
    ggplot2::annotate("text", x = x_center, y = y_center - 0.1,
             label = sublabel, size = text_cor_size - 1, color = "grey20") +
    ggplot2::xlim(0, 1) +
    ggplot2::ylim(0, 1) +
    ggplot2::theme_void() +
    ggplot2::theme(
      panel.background = ggplot2::element_rect(fill = scales::alpha(bg_color, 0.5), color = NA),
      plot.background = ggplot2::element_rect(fill = scales::alpha(bg_color, 0.5), color = NA)
    )
}

custom_diag <- function(data, mapping){
  var <- ggplot2::as_label(mapping$x)

  if(herringbone == TRUE){
    hist_col <- pair_colors_hist[[var]]
  }else{
    hist_col <- "gray"
  }

  # Select the relevant variable
  if(var %in% col_pairs_to_constraint){

    data_reduced <- dplyr::select(df, all_of(c(var, col_pairs_constraint))) %>%
      dplyr::distinct()
  }else{
    data_reduced <- dplyr::select(df_without_id_vars, all_of(c(var)))
  }

  data_reduced <- data_reduced[complete.cases(data_reduced), , drop = FALSE]
  x_data <- data_reduced[[var]]

  hist_data <- hist(x_data, plot = FALSE)
  x_center <- mean(hist_data$mids)
  y_center <- max(hist_data$counts)

  ggplot2::ggplot(data_reduced, ggplot2::aes(x = .data[[var]])) +
    ggplot2::geom_histogram(fill = hist_col, color = hist_col, bins =  hist_bins, alpha = 0.6) +
    ggplot2::annotate("text", x = x_center, y = y_center,
             label = var, size = hist_label_size, color = "black",
             hjust = 0.5, vjust = 1.2, fontface = "bold") +
    ggplot2::theme_minimal() +
    ggplot2::theme(
      panel.grid = ggplot2::element_blank(),
      panel.background = ggplot2::element_rect(fill = "white", color = NA)
    )
}


GGally::ggpairs(  df_without_id_vars,
        lower = list(continuous = function(data, mapping, ...) custom_lower(data, mapping, pair_colors_map, ...)),
        upper = list(continuous = function(data, mapping, ...) custom_upper(data, mapping, pair_colors_map, ...)),
        diag = list(continuous = custom_diag)) +
  ggplot2::theme(strip.text = element_text(size = text_strip_size))

}

