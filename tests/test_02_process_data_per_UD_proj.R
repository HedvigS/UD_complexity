# Install the released version from CRAN
if (!requireNamespace("testthat", quietly = TRUE)) {
  install.packages("testthat")
}

# Load the library
library("testthat")

# Change working directory because the script to be tested expects that
# If the current working directory is "UD_complexity", set it to "code"
if (basename(getwd()) == "UD_complexity") {
  setwd("code")
} else if (basename(getwd()) == "tests") {
  setwd("../code")
} else if (basename(getwd()) == "code") {
  # Do nothing, already in the correct directory
} else {
  stop("Unexpected working directory. Please run the script from 'UD_complexity' or 'tests' directory.")
}

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

# Create test data.
# First define the filepath for the TSV file that will serve as test data input for the function.
fpath_out_test <- paste0("output_test/processed_data/", UD_version, "/test_01.tsv")

# Now define a dataframe with headers:
# "id"	"doc_id"	"paragraph_id"	"sentence_id"	"sentence"	"token_id"	"token"	"lemma"	"upos"	"xpos"	"feats"	"head_token_id"	"dep_rel"	"deps"	"misc"
test_data <- data.frame(
  id = c("TEST_01_001", "TEST_01_002", "TEST_01_003", "TEST_01_004", "TEST_02_001", "TEST_02_002", "TEST_02_003", "TEST_02_004", "TEST_03_001", "TEST_03_002", "TEST_03_003"),
  doc_id = rep("", 11), # leave doc_id column empty for now
  paragraph_id = rep("000", 11), # don't need a real paragraph ID
  sentence_id = c(rep("TEST_01",4), rep("TEST_02",4), rep("TEST_03",3)),
  sentence = c(rep("01 This is a test.",4), rep("02 This is a test.",4), rep("03 This is a test.",3)),
  token_id = c(1, 2, 3, 4, 1, 2, 3, 4, 1, 2, 3),
  token = c("ēkal","x","mār","Aššur-dan","ēkal","Aššur-naṣir-apli","šar","kiššati","marks","mark","marks"),
  lemma = c("ēkallu","x","māru","Aššur-dan_II","ēkallu","Aššur-naṣir-apli_II","šarru","kiššatu","mark","mark","mark"),
  upos = c("NOUN","PROPN","NOUN","PROPN","NOUN","PROPN","NOUN","NOUN","VERB","VERB","NOUN"),
  xpos = c("N","u","N","RN","N","RN","N","N","V","V","N"),
  feats = c("Gender=Fem|NounBase=Bound|Number=Sing", "Gender=Masc", "Gender=Masc|NounBase=Bound|Number=Sing", "Gender=Masc", "Gender=Fem|NounBase=Bound|Number=Sing", "Gender=Masc", "Gender=Masc|NounBase=Bound|Number=Sing", "Case=Gen|Gender=Fem|NounBase=Free|Number=Sing", "Person=3|Number=Plural", "Person=2", "Number=Plural"),
  head_token_id = c("0","1","2","3","0","1","2","3","0","0","0"),
  dep_rel = c("root", "nmod:poss", "appos", "nmod:poss", "root", "nmod:poss", "appos", "nmod:poss", "TEST","TEST", "TEST"),
  deps = rep("", 11), # leave deps column empty for now
  misc = rep("test misc string",11), # leave misc column as test string for now
  stringsAsFactors = FALSE
)

# Write the test data to a TSV file
write.table(test_data, fpath_out_test, sep = "\t", row.names = FALSE, quote = FALSE)

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