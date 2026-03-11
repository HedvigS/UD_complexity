library(dplyr, lib.loc = "../utility/packages/")
library(magrittr, lib.loc = "../utility/packages/")
library(readr, lib.loc = "../utility/packages/")
library(stringr, lib.loc = "../utility/packages/")
library(forcats, lib.loc = "../utility/packages/")
library(ggplot2, lib.loc = "../utility/packages/")
library(reshape2, lib.loc = "../utility/packages/")

df <-   readr::read_tsv("output/results/all_results.tsv", show_col_types = FALSE)

df$dir_for_plot <- paste0(stringr::str_replace(df$dir, "UD_", ""), "_", df$glottocode)
df$dir_for_plot <- forcats::fct_reorder(df$dir_for_plot, df$sum_surprisal_morph_split_mean_upos_all_features_rank)

df_for_plot <- df %>%  
  dplyr::select(dir_for_plot,     
                sum_surprisal_morph_split_mean_upos_all_features_rank,
                sum_surprisal_morph_split_mean_upos_all_features, 
                surprisal_per_morph_featstring_mean_lemma_core_features_only_rank ,
                surprisal_per_morph_featstring_mean_lemma_core_features_only, 
                mfh_rank,
                mfh,
                Fusion_rank,   Fusion,
                Informativity_rank, Informativity)  %>%  
  reshape2::melt(id.vars = "dir_for_plot") %>%  
  dplyr::mutate(variable_group = ifelse(stringr::str_detect(variable, "sum_surprisal_morph_split_mean_upos_all_features"), yes = "sum_surprisal_morph_split_mean_upos_all_features", no = NA)) %>%
  dplyr::mutate(variable_group = ifelse(stringr::str_detect(variable, "surprisal_per_morph_featstring_mean_lemma_core_features"), yes = "surprisal_per_morph_featstring_mean_lemma_core_features", no = variable_group)) %>%
  dplyr::mutate(variable_group = ifelse(stringr::str_detect(variable, "mfh"), yes = "mfh", no = variable_group)) %>%
  dplyr::mutate(variable_group = ifelse(stringr::str_detect(variable, "surprisal_per_morph_featstring_mean_lemma_core_features"), yes = "surprisal_per_morph_featstring_mean_lemma_core_features", no = variable_group)) %>%
  dplyr::mutate(variable_group = ifelse(stringr::str_detect(variable, "Fusion"), yes = "Fusion", no = variable_group)) %>%
  dplyr::mutate(variable_group = ifelse(stringr::str_detect(variable, "Informativity"), yes = "Informativity", no = variable_group))  %>%
  dplyr::mutate(category = ifelse(stringr::str_detect(variable, "rank"), yes = "rank", no = "value"))  %>%
  dplyr::mutate(id = paste0(dir_for_plot, "£££", variable_group))  %>%
  reshape2::dcast(id ~ category, value.var = "value") %>%
  tidyr::separate(id, sep = "£££", into = c("dir_for_plot", "variable"))  %>%
  dplyr::mutate(value_label_for_plot = paste0(rank, " (", round(value, 2), ")")) %>%
  dplyr::mutate(value_label_for_plot = ifelse(value_label_for_plot == "NA (NA)", NA, value_label_for_plot))

df_for_plot <- df_for_plot  %>%  
  dplyr::mutate(variable = ifelse(variable == "sum_surprisal_morph_split_mean_upos_all_features", yes = "morpho-surprisal / \n feat / \n UPOS / \n all features", no = variable))   %>%  
  dplyr::mutate(variable = ifelse(variable == "surprisal_per_morph_featstring_mean_lemma_core_features", yes =  "morpho-surprisal / \n featstring  / \n  lemma / \n core features only", no = variable))  %>%  
  dplyr::mutate(variable = ifelse(variable == "mfh", yes =  "Ç&R's MFH\n(slightly modified\nversion)", no = variable))

df_for_plot$variable <- factor(df_for_plot$variable, levels = c(
  "morpho-surprisal / \n feat / \n UPOS / \n all features",                                                     
  "morpho-surprisal / \n featstring  / \n  lemma / \n core features only", 
  "Ç&R's MFH\n(slightly modified\nversion)",
  "Fusion", "Informativity")) 

df_for_plot <- df_for_plot  %>%  
  dplyr::mutate(dir_for_plot = fct_reorder(
    dir_for_plot,
    ifelse(variable == "morpho-surprisal / \n feat / \n UPOS / \n all features", rank, NA),
    .fun = function(x) x[!is.na(x)],
    .na_rm = TRUE
  ))


p <- df_for_plot  %>%  
  ggplot2::ggplot(ggplot2::aes(x = variable, y = dir_for_plot, fill = rank )) +
  ggplot2::geom_tile(color = "white") +
  ggplot2::geom_text(ggplot2::aes(label = value_label_for_plot), size = 4, na.rm = TRUE, color = "white") +
  ggplot2::scale_fill_viridis_c(option = "viridis", na.value = "grey90") +
  ggplot2::theme_minimal() +
  ggplot2::theme(legend.position = "None", 
                 axis.title = ggplot2::element_blank())

ggplot2::ggsave("output/plots/rank_heat_plot.png", plot = p, width = 10, height = 30)
