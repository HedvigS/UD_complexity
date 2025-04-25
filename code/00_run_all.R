
source("01_requirements.R")

source("02_get_glottolog_language_table.R")
source("02_get_grambank_data.R")
source("02_google_pop.R")

source("02_get_UD.R")
source("02_collapse_UD_dirs.R")

source("03_process_data_per_UD_proj.R")
process_data_per_UD_proj(directory = "output", agg_level = "upos", core_features = "core_features_only")
process_data_per_UD_proj(directory = "output", agg_level = "lemma", core_features = "core_features_only")
process_data_per_UD_proj(directory = "output", agg_level = "upos", core_features = "all_features")
process_data_per_UD_proj(directory = "output", agg_level = "lemma", core_features = "all_features")

source("03_stack_summaries.R")
source("04_plot_SPLOM.R")
