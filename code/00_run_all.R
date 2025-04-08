
source("01_requirements.R")

source("02_get_grambank_data.R")
source("02_google_pop.R")

source("02_collapse_UD_dirs.R")

source("02_process_data_per_UD_proj.R")
process_data_per_UD_proj(directory = "output", agg_level = "upos", core_features = "core_features_only")
process_data_per_UD_proj(directory = "output", agg_level = "lemma", core_features = "core_features_only")
process_data_per_UD_proj(directory = "output", agg_level = "upos", core_features = "all_features")
process_data_per_UD_proj(directory = "output", agg_level = "lemma", core_features = "all_features")

source("03_summarise_for_plots.R")

source("04_maps_counts.R")
source("04_map_surprisal.R")
source("04_map_TTR.R")
source("04_UPOS_feat_usefulness.R")