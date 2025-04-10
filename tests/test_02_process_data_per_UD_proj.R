# Install the released version from CRAN
if (!requireNamespace("testthat", quietly = TRUE)) {
  install.packages("testthat")
}

# Load the library
library("testthat")

# Change working directory because the script to be tested expects that
# setwd("../code")

# Load the function to be tested
source("01_requirements.R")
source("02_process_data_per_UD_proj.R")

# Set some global variables
# Directories for test data output
DIR_COUNTS <- "output_test/counts/"
DIR_S_FEAT <- "output_test/surprisal_per_feat/"
DIR_S_FEAT_LOOKUP <- "output_test/surprisal_per_feat_lookup/"
DIR_S_FEATSTRING <- "output_test/surprisal_per_featstring/"
DIR_S_FEATSTRING_LOOKUP <- "output_test/surprisal_per_featstring_lookup/"
DIR_S_TOKEN <- "output_test/surprisal_per_token/"
DIR_S_TOKEN_SUM <- "output_test/surprisal_per_token_sum_sentence/"
DIR_TTR <- "output_test/TTR/"

# Test case 1: UPOS, core only
test_that("Test process_data_per_UD_proj: test data, per UPOS, core only",{
  process_data_per_UD_proj(directory = "output_test",agg_level = "upos",core_features = "core_features_only")
  
  # Check TSV data exists in 8 different directories.
  # Assert the data exists with testthat.
  expect_true(file.exists(file.path(DIR_COUNTS, "counts_agg_level_upos_core_features_only_test_01_summarised.tsv")))
  expect_true(file.exists(file.path(DIR_S_FEAT, "surprisal_per_feat_per_agg_level_upos_core_features_only_test_01.tsv")))
  expect_true(file.exists(file.path(DIR_S_FEAT_LOOKUP, "surprisal_per_feat_lookup_agg_level_upos_core_features_only_test_01.tsv")))
  expect_true(file.exists(file.path(DIR_S_FEATSTRING, "surprisal_per_featstring_per_agg_level_upos_core_features_only_test_01.tsv")))
  expect_true(file.exists(file.path(DIR_S_FEATSTRING_LOOKUP, "surprisal_per_featstring_lookup_agg_level_upos_core_features_only_test_01.tsv")))

  # The following should be created by any run of the function, regardless of parameters.
  # We check them here and not in any subsequent tests.
  expect_true(file.exists(file.path(DIR_S_TOKEN, "surprisal_per_token_test_01.tsv")))
  expect_true(file.exists(file.path(DIR_S_TOKEN_SUM, "surprisal_per_token_sum_sentence_test_01.tsv"))) 
  expect_true(file.exists(file.path(DIR_TTR, "test_01_TTR_sum.tsv")))
  expect_true(file.exists(file.path(DIR_TTR, "test_01_TTR_full.tsv")))
  
  ############## FUTURE ###############
  # In future we can do more sophisticated tests e.g. check specific values in the TSV files.
  # # Get the counts data using DIR_COUNTS and counts_agg_level_lemma_core_features_only_test_01_summarised.tsv
  # tsv_data <- read.table(file.path(DIR_COUNTS, "counts_agg_level_upos_core_features_only_test_01_summarised.tsv"), sep = "\t", header = TRUE, stringsAsFactors = FALSE)
  #####################################
  
})

# Test case 2: lemma, core only
test_that("Test process_data_per_UD_proj: test data, per lemma, core only",{
  process_data_per_UD_proj(directory = "output_test",agg_level = "lemma",core_features = "core_features_only")
  
  # Check TSV data exists in 8 different directories.
  # Assert the data exists with testthat.
  expect_true(file.exists(file.path(DIR_COUNTS, "counts_agg_level_lemma_core_features_only_test_01_summarised.tsv")))
  expect_true(file.exists(file.path(DIR_S_FEAT, "surprisal_per_feat_per_agg_level_lemma_core_features_only_test_01.tsv")))
  expect_true(file.exists(file.path(DIR_S_FEAT_LOOKUP, "surprisal_per_feat_lookup_agg_level_lemma_core_features_only_test_01.tsv")))
  expect_true(file.exists(file.path(DIR_S_FEATSTRING, "surprisal_per_featstring_per_agg_level_lemma_core_features_only_test_01.tsv")))
  expect_true(file.exists(file.path(DIR_S_FEATSTRING_LOOKUP, "surprisal_per_featstring_lookup_agg_level_lemma_core_features_only_test_01.tsv")))
  
  ############## FUTURE ###############
  # In future we can do more sophisticated tests e.g. check specific values in the TSV files.
  # # Get the counts data using DIR_COUNTS and counts_agg_level_lemma_core_features_only_test_01_summarised.tsv
  # tsv_data <- read.table(file.path(DIR_COUNTS, "counts_agg_level_lemma_core_features_only_test_01_summarised.tsv"), sep = "\t", header = TRUE, stringsAsFactors = FALSE)
  #####################################
  
})

# Test case 3: token, core only
test_that("Test process_data_per_UD_proj: test data, per token, core only",{
  process_data_per_UD_proj(directory = "output_test",agg_level = "token",core_features = "core_features_only")
  
  # Check TSV data exists in 8 different directories.
  # Assert the data exists with testthat.
  expect_true(file.exists(file.path(DIR_COUNTS, "counts_agg_level_token_core_features_only_test_01_summarised.tsv")))
  expect_true(file.exists(file.path(DIR_S_FEAT, "surprisal_per_feat_per_agg_level_token_core_features_only_test_01.tsv")))
  expect_true(file.exists(file.path(DIR_S_FEAT_LOOKUP, "surprisal_per_feat_lookup_agg_level_token_core_features_only_test_01.tsv")))
  expect_true(file.exists(file.path(DIR_S_FEATSTRING, "surprisal_per_featstring_per_agg_level_token_core_features_only_test_01.tsv")))
  expect_true(file.exists(file.path(DIR_S_FEATSTRING_LOOKUP, "surprisal_per_featstring_lookup_agg_level_token_core_features_only_test_01.tsv")))
  
  ############## FUTURE ###############
  # In future we can do more sophisticated tests e.g. check specific values in the TSV files.
  # # Get the counts data using DIR_COUNTS and counts_agg_level_token_core_features_only_test_01_summarised.tsv
  # tsv_data <- read.table(file.path(DIR_COUNTS, "counts_agg_level_token_core_features_only_test_01_summarised.tsv"), sep = "\t", header = TRUE, stringsAsFactors = FALSE)
  #####################################
  
})

# Test case 4: UPOS, all_features
test_that("Test process_data_per_UD_proj: test data, per UPOS, all_features",{
  process_data_per_UD_proj(directory = "output_test",agg_level = "upos",core_features = "all_features")
  
  # Check TSV data exists in 8 different directories.
  # Assert the data exists with testthat.
  expect_true(file.exists(file.path(DIR_COUNTS, "counts_agg_level_upos_all_features_test_01_summarised.tsv")))
  expect_true(file.exists(file.path(DIR_S_FEAT, "surprisal_per_feat_per_agg_level_upos_all_features_test_01.tsv")))
  expect_true(file.exists(file.path(DIR_S_FEAT_LOOKUP, "surprisal_per_feat_lookup_agg_level_upos_all_features_test_01.tsv")))
  expect_true(file.exists(file.path(DIR_S_FEATSTRING, "surprisal_per_featstring_per_agg_level_upos_all_features_test_01.tsv")))
  expect_true(file.exists(file.path(DIR_S_FEATSTRING_LOOKUP, "surprisal_per_featstring_lookup_agg_level_upos_all_features_test_01.tsv")))
  
  ############## FUTURE ###############
  # In future we can do more sophisticated tests e.g. check specific values in the TSV files.
  # # Get the counts data using DIR_COUNTS and counts_agg_level_upos_all_features_test_01_summarised.tsv
  # tsv_data <- read.table(file.path(DIR_COUNTS, "counts_agg_level_upos_all_features_test_01_summarised.tsv"), sep = "\t", header = TRUE, stringsAsFactors = FALSE)
  #####################################
  
})

# Test case 5: lemma, all_features
test_that("Test process_data_per_UD_proj: test data, per lemma, all_features",{
  process_data_per_UD_proj(directory = "output_test",agg_level = "lemma",core_features = "all_features")
  
  # Check TSV data exists in 8 different directories.
  # Assert the data exists with testthat.
  expect_true(file.exists(file.path(DIR_COUNTS, "counts_agg_level_lemma_all_features_test_01_summarised.tsv")))
  expect_true(file.exists(file.path(DIR_S_FEAT, "surprisal_per_feat_per_agg_level_lemma_all_features_test_01.tsv")))
  expect_true(file.exists(file.path(DIR_S_FEAT_LOOKUP, "surprisal_per_feat_lookup_agg_level_lemma_all_features_test_01.tsv")))
  expect_true(file.exists(file.path(DIR_S_FEATSTRING, "surprisal_per_featstring_per_agg_level_lemma_all_features_test_01.tsv")))
  expect_true(file.exists(file.path(DIR_S_FEATSTRING_LOOKUP, "surprisal_per_featstring_lookup_agg_level_lemma_all_features_test_01.tsv")))
  
  ############## FUTURE ###############
  # In future we can do more sophisticated tests e.g. check specific values in the TSV files.
  # # Get the counts data using DIR_COUNTS and counts_agg_level_lemma_all_features_test_01_summarised.tsv
  # tsv_data <- read.table(file.path(DIR_COUNTS, "counts_agg_level_lemma_all_features_test_01_summarised.tsv"), sep = "\t", header = TRUE, stringsAsFactors = FALSE)
  #####################################
  
})

# Test case 6: token, all_features
test_that("Test process_data_per_UD_proj: test data, per token, all_features",{
  process_data_per_UD_proj(directory = "output_test",agg_level = "token",core_features = "all_features")
  
  # Check TSV data exists in 8 different directories.
  # Assert the data exists with testthat.
  expect_true(file.exists(file.path(DIR_COUNTS, "counts_agg_level_token_all_features_test_01_summarised.tsv")))
  expect_true(file.exists(file.path(DIR_S_FEAT, "surprisal_per_feat_per_agg_level_token_all_features_test_01.tsv")))
  expect_true(file.exists(file.path(DIR_S_FEAT_LOOKUP, "surprisal_per_feat_lookup_agg_level_token_all_features_test_01.tsv")))
  expect_true(file.exists(file.path(DIR_S_FEATSTRING, "surprisal_per_featstring_per_agg_level_token_all_features_test_01.tsv")))
  expect_true(file.exists(file.path(DIR_S_FEATSTRING_LOOKUP, "surprisal_per_featstring_lookup_agg_level_token_all_features_test_01.tsv")))
  
  ############## FUTURE ###############
  # In future we can do more sophisticated tests e.g. check specific values in the TSV files.
  # # Get the counts data using DIR_COUNTS and counts_agg_level_token_all_features_test_01_summarised.tsv
  # tsv_data <- read.table(file.path(DIR_COUNTS, "counts_agg_level_token_all_features_test_01_summarised.tsv"), sep = "\t", header = TRUE, stringsAsFactors = FALSE)
  #####################################
  
})
  
# Reset working directory
# setwd("../tests")