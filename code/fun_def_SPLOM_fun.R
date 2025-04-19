coloured_SPLOM <- function(df = df, pair_colors = "default",   hist_label_size  = 3){

#  df = df_for_plot
if(all(pair_colors == "default")){
n <- (length(names(df)) * (length(names(df)) - 1)) / 2
# Generate a large number of distinct colors (one for each unique pair of variables)
pair_colors <- randomcoloR::distinctColorPalette(k  = n)
}
  
# Create a named list to store unique colors for each pair
pair_colors_map <- list()

# Assign colors to each variable combination in the lower triangle
var_names <- names(df)
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
  var1 <- as_label(mapping$x)
  var2 <- as_label(mapping$y)
  
  # Create a unique pair identifier (ignoring (x, y) vs (y, x))
  pair_key <- paste(sort(c(var1, var2)), collapse = "_")
  
  # Get the background color for the pair
  bg_color <- pair_colors_map[[pair_key]]
  
  ggplot(data, mapping) +
    geom_point(alpha = 0.6) +
    theme_minimal() +
    theme(
      panel.background = element_rect(fill = scales::alpha(bg_color, 0.5), color = NA),
      plot.background = element_rect(fill = scales::alpha(bg_color, 0.5), color = NA),
      panel.grid = element_blank()
    )
}


# Custom upper triangle function with correlation text and color control
custom_upper <- function(data, mapping, pair_colors_map, method = "pearson", ...){
  x <- eval_data_col(data, mapping$x)
  y <- eval_data_col(data, mapping$y)
  ct <- cor.test(x, y, method = method)
  r <- ct$estimate
  p <- ct$p.value
  
  var1 <- as_label(mapping$x)
  var2 <- as_label(mapping$y)
  
  # Create a unique pair identifier (ignoring (x, y) vs (y, x))
  pair_key <- paste(sort(c(var1, var2)), collapse = "_")
  
  # Get the background color for the pair
  bg_color <- pair_colors_map[[pair_key]]
  
  # Set text color based on correlation strength and significance
  if (p < 0.05) {
    color_scale <- scales::col_bin(
      palette = c("grey40", "#FF9333", "darkred"),
      bins = c(0, 0.5, 0.8, 1),
      domain = c(0, 1)
    )
    text_color <- color_scale(abs(r))
  } else {
    text_color <- "grey60"
  }
  
  label <- paste0(round(r, 2),ifelse(p < 0.05, "*", ""))
  
  ggplot() +
    annotate("text", x = 0.5, y = 0.5,
             label = label, size = 7.5, color = text_color) +
    theme_void() +
    theme(
      panel.background = element_rect(fill = scales::alpha(bg_color, 0.5), color = NA),
      plot.background = element_rect(fill = scales::alpha(bg_color, 0.5), color = NA)
    )
}


custom_diag <- function(data, mapping, ...){
  var <- as_label(mapping$x)
  
  # Compute the histogram data
  hist_data <- hist(data[[var]], plot = FALSE)
  
  # Get the mid-point for the x-axis (centered)
  x_center <- mean(hist_data$mids)
  
  # Get the midpoint for the y-axis (centered)
  y_center <- max(hist_data$counts) / 2


  ggplot(data, mapping) +
    geom_histogram(fill = "grey80", color = "gray", bins = 30) +
    annotate("text", x = x_center, y = y_center, 
             label = var, size =  hist_label_size , color = "black", hjust = 0.5, vjust = 0.8, fontface = "bold") +
    theme_minimal() +
    theme(
      panel.grid = element_blank(),
      panel.background = element_rect(fill = "white", color = NA)
    )
}


ggpairs(df,
        lower = list(continuous = function(data, mapping, ...) custom_lower(data, mapping, pair_colors_map, ...)),
        upper = list(continuous = function(data, mapping, ...) custom_upper(data, mapping, pair_colors_map, ...)),
        diag = list(continuous = custom_diag))

}

