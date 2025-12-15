
source("01_requirements_install.R")
source("01_requirements_load.R")
source("01_requirements_dirs.R")

source("02_get_glottolog_language_table.R")
source("02_get_grambank_data.R")
source("02_google_pop.R")

source("02_get_UD.R")
source("02_collapse_UD_dirs.R")

source("03_process_data_per_UD_proj.R")
process_UD_data(input_dir = "output/processed_data/ud-treebanks-v2.14_collapsed/", 
                output_dir = "output/processed_data/ud-treebanks-v2.14_processed/", 
                resolve_multiwords_to = "super-word", 
                remove_empty_nodes = TRUE, 
                agg_level = "upos", #lemma token,
                bad_UD_morph_feat_cats =  c("Abbr", "Typo", "Foreign"),
                core_features = "core_features_only",
                fill_empty_lemmas_with_tokens = TRUE,
                make_all_tokens_of_same_agg_level_have_same_feat_cat =  TRUE
)

process_data_per_UD_proj(directory = "output", agg_level = "upos", core_features = "core_features_only")
process_data_per_UD_proj(directory = "output", agg_level = "lemma", core_features = "core_features_only")
process_data_per_UD_proj(directory = "output", agg_level = "upos", core_features = "all_features")
process_data_per_UD_proj(directory = "output", agg_level = "lemma", core_features = "all_features")

source("04_stack_summaries.R")
source("04_plot_SPLOM.R")
source("04_maps.R")
