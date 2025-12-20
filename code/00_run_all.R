
source("01_requirements_install.R")
source("01_requirements_load.R")
source("01_requirements_dirs.R")

source("02_get_glottolog_language_table.R")
source("02_get_grambank_data.R")
source("02_google_pop.R")

source("02_get_UD.R")
source("02_collapse_UD_dirs.R")

# Calculate C&R's mean feature entropy (MFH) using the Python script
source("03_run_python.R")

source("03_process_data_per_UD_proj.R")
process_UD_data(input_dir = "output/processed_data/ud-treebanks-v2.14_collapsed/", 
                output_dir = "output/processed_data/ud-treebanks-v2.14_processed/", 
                agg_level = "upos", #lemma token,
                core_features = "core_features_only",
)
process_UD_data(input_dir = "output/processed_data/ud-treebanks-v2.14_collapsed/", 
                output_dir = "output/processed_data/ud-treebanks-v2.14_processed/", 
                agg_level = "lemma", #lemma token,
                core_features = "core_features_only",
)
process_UD_data(input_dir = "output/processed_data/ud-treebanks-v2.14_collapsed/", 
                output_dir = "output/processed_data/ud-treebanks-v2.14_processed/", 
                agg_level = "upos", #lemma token,
                core_features = "all_features",
)
process_UD_data(input_dir = "output/processed_data/ud-treebanks-v2.14_collapsed/", 
                output_dir = "output/processed_data/ud-treebanks-v2.14_processed/", 
                agg_level = "lemma", #lemma token,
                core_features = "all_features",
)


calculate_surprisal(input_dir = "output/processed_data/ud-treebanks-v2.14_processed/agg_level_upos_core_features_only/processed_tsv/", 
                    agg_level = "upos",
                    core_features = "core_features_only",
                    output_dir <- "output/results/ud-treebanks-v2.14_results")

calculate_surprisal(input_dir = "output/processed_data/ud-treebanks-v2.14_processed/agg_level_upos_all_features/processed_tsv/", 
                    agg_level = "upos",
                    core_features = "all_features",
                    output_dir <- "output/results/ud-treebanks-v2.14_results")

calculate_surprisal(input_dir = "output/processed_data/ud-treebanks-v2.14_processed/agg_level_lemma_core_features_only/processed_tsv/", 
                    agg_level = "lemma", 
                    core_features = "core_features_only", 
                    output_dir <- "output/results/ud-treebanks-v2.14_results")

calculate_surprisal(input_dir = "output/processed_data/ud-treebanks-v2.14_processed/agg_level_lemma_all_features/processed_tsv/", 
                    agg_level = "lemma", 
                    core_features = "all_features", 
                    output_dir <- "output/results/ud-treebanks-v2.14_results")

source("04_stack_summaries.R")
source("04_combine_all_data.R")
source("04_plot_SPLOM.R")
source("04_maps.R")

source("05_box_plots.R")
