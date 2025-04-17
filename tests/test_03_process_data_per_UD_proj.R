# Install the released version from CRAN
if (!requireNamespace("testthat", quietly = TRUE)) {
  install.packages("testthat")
}

# Load the library
library("testthat")

# Load the requirements and change the working directory
# Change working directory because the script to be tested expects that
# If the current working directory is "UD_complexity", set it to "code"
if (basename(getwd()) == "UD_complexity") {
  source("tests/requirements_tests.R")
  setwd("code")
} else if (basename(getwd()) == "tests") {
  source("requirements_tests.R")
  setwd("../code")
} else if (basename(getwd()) == "code") {
  source("../tests/requirements_tests.R")
  # Do nothing, already in the correct directory
} else {
  stop("Unexpected working directory. Please run the script from 'UD_complexity' or 'tests' directory.")
}

# Load the function to be tested
# source("01_requirements.R")
source("03_process_data_per_UD_proj.R")

# Set some global variables
# Directories for test data output

# DIR_COUNTS: summary values per sentence
DIR_COUNTS <- "output_test/counts/"

# DIR_S_FEAT: counts, proportions and sum of surprisals for individual feature values
DIR_S_FEAT <- "output_test/surprisal_per_feat/"

# DIR_S_FEAT_LOOKUP: counts, proportions and surprisals for individual feature values
DIR_S_FEAT_LOOKUP <- "output_test/surprisal_per_feat_lookup/"

# DIR_S_FEATSTRING: counts, proportions and surprisals for full feature strings for each token 
# (where the counts and proportions are determined per agg_level, either UPOS, lemma or token)
DIR_S_FEATSTRING <- "output_test/surprisal_per_featstring/"

# DIR_S_FEATSTRING_LOOKUP: counts, proportions and surprisals per feature string, per agg_level (UPOS, lemma or token)
DIR_S_FEATSTRING_LOOKUP <- "output_test/surprisal_per_featstring_lookup/"

# DIR_S_TOKEN: counts, proportions and surprisals for each token regardless of morphological features. 
# Ignores UPOS, so "marks" (English verb) and "marks" (English plural noun) 
# would be counted as two instances of the same token.
DIR_S_TOKEN <- "output_test/surprisal_per_token/"

# DIR_S_TOKEN_SUM: The surprisals from surprisal_per_token summed at the level of "sentence_id"
DIR_S_TOKEN_SUM <- "output_test/surprisal_per_token_sum_sentence/"

# DIR_TTR: Type-Token Ratios of individual tokens.
DIR_TTR <- "output_test/TTR/"

# Create test data.
# First define the filepath for the TSV file that will serve as test data input for the function.
directory_out_test <- paste0("output_test/processed_data/", UD_version, "/")
fpath_out_test <- paste0(directory_out_test, "test_01.tsv")

# # Now define a dataframe with headers:
# # "id"	"doc_id"	"paragraph_id"	"sentence_id"	"sentence"	"token_id"	"token"	"lemma"	"upos"	"xpos"	"feats"	"head_token_id"	"dep_rel"	"deps"	"misc"
# test_data <- data.frame(
#   id = c("TEST_01_001", "TEST_01_002", "TEST_01_003", "TEST_01_004", "TEST_02_001", "TEST_02_002", "TEST_02_003", "TEST_02_004", "TEST_03_001", "TEST_03_002", "TEST_03_003"),
#   doc_id = rep("", 11), # leave doc_id column empty for now
#   paragraph_id = rep("000", 11), # don't need a real paragraph ID
#   sentence_id = c(rep("TEST_01",4), rep("TEST_02",4), rep("TEST_03",3)),
#   sentence = c(rep("01 This is a test.",4), rep("02 This is a test.",4), rep("03 This is a test.",3)),
#   token_id = c(1, 2, 3, 4, 1, 2, 3, 4, 1, 2, 3),
#   token = c("ēkal","x","mār","Aššur-dan","ēkal","Aššur-naṣir-apli","šar","kiššati","marks","mark","marks"),
#   lemma = c("ēkallu","x","māru","Aššur-dan_II","ēkallu","Aššur-naṣir-apli_II","šarru","kiššatu","mark","mark","mark"),
#   upos = c("NOUN","PROPN","NOUN","PROPN","NOUN","PROPN","NOUN","NOUN","VERB","VERB","NOUN"),
#   xpos = c("N","u","N","RN","N","RN","N","N","V","V","N"),
#   feats = c("Gender=Fem|NounBase=Bound|Number=Sing", "Gender=Masc", "Gender=Masc|NounBase=Bound|Number=Sing", "Gender=Masc", "Gender=Fem|NounBase=Bound|Number=Sing", "Gender=Masc", "Gender=Masc|NounBase=Bound|Number=Sing", "Case=Gen|Gender=Fem|NounBase=Free|Number=Sing", "Person=3|Number=Plural", "Person=2", "Number=Plural"),
#   head_token_id = c("0","1","2","3","0","1","2","3","0","0","0"),
#   dep_rel = c("root", "nmod:poss", "appos", "nmod:poss", "root", "nmod:poss", "appos", "nmod:poss", "TEST","TEST", "TEST"),
#   deps = rep("", 11), # leave deps column empty for now
#   misc = rep("test misc string",11), # leave misc column as test string for now
#   stringsAsFactors = FALSE
# )

# Simpler test for now: 5 tokens
test_data <- data.frame(
  id = c("TEST_N01", "TEST_N02", "TEST_V01", "TEST_V02", "TEST_V03"),
  doc_id = rep("", 5), # leave doc_id column empty for now
  paragraph_id = rep("000", 5), # don't need a real paragraph ID
  sentence_id = c("TEST_01","TEST_01", "TEST_01", "TEST_02", "TEST_02"),
  sentence = c(rep("01 This is a test.",3), rep("02 This is a test.",2)),
  token_id = c(1, 2, 3, 4, 5),
  token = c("t_n_one","t_n_two", "t_v_one","t_v_one_suffix", "t_v_two"),
  lemma = c("t_n_one","t_n_two","t_v_one","t_v_one", "t_v_two"),
  upos = c("NOUN","NOUN","VERB","VERB", "VERB"),
  xpos = c("N","N","V","V", "V"),
  feats = c("Gender=Fem|NounBase=Bound|Number=Sing", "Gender=Fem|NounBase=Bound|Number=Sing|FakeFeat=BlahBlah", "Gender=Masc|Number=Sing", "Gender=Fem|Number=Sing", ""),
  head_token_id = c("0","1","2","0", "1"),
  dep_rel = rep("TEST",5),
  deps = rep("", 5), # leave deps column empty for now
  misc = rep("test misc string",5), # leave misc column as test string for now
  stringsAsFactors = FALSE
)

# Create the directory if required
if (!dir.exists(directory_out_test)) {
  dir.create(directory_out_test, recursive = TRUE)
}

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
  
  # Get sum of surprisals per token
  tsv_data <- read.table(file.path(DIR_S_FEAT, "surprisal_per_feat_per_agg_level_upos_core_features_only_test_01.tsv"), sep = "\t", header = TRUE, stringsAsFactors = FALSE)
  
  # The table should have a column called sum_surprisal_morph_split
  expect_true("sum_surprisal_morph_split" %in% colnames(tsv_data))

  # Round tsv_data$sum_surprisal_morph_split to 2 decimal places for comparison
  tsv_data$sum_surprisal_morph_split <- round(tsv_data$sum_surprisal_morph_split, 2)

  # The surprisal column should be as described here:
  expect_true(all(tsv_data$sum_surprisal_morph_split == c(
    0, # The first noun has three features, all are identical to the second noun.
    0, # The second noun has four features, three are identical to the second noun and one is not a core feature.
    2.17, # Surprisal of 1/3 plus surprisal of 2/3, rounded
    2.17,  # Surprisal of 1/3 plus surprisal of 2/3, rounded
    3.17 # Surprisal of 1/3 plus surprisal of 1/3, rounded
  )))
  
  # print(tsv_data$sum_surprisal_morph_split) # debug
  
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
  
  # Get sum of surprisals per token
  tsv_data <- read.table(file.path(DIR_S_FEAT, "surprisal_per_feat_per_agg_level_lemma_core_features_only_test_01.tsv"), sep = "\t", header = TRUE, stringsAsFactors = FALSE)
  
  # The table should have a column called sum_surprisal_morph_split
  expect_true("sum_surprisal_morph_split" %in% colnames(tsv_data))

  # Round tsv_data$sum_surprisal_morph_split to 2 decimal places for comparison
  tsv_data$sum_surprisal_morph_split <- round(tsv_data$sum_surprisal_morph_split, 2)

  # The surprisal column should be as described here:
  expect_true(all(tsv_data$sum_surprisal_morph_split == c(
    0, # The first noun has three features, all are identical to the second noun.
    0, # The second noun has four features, three are identical to the second noun and one is not a core feature.
    1, # Only differs from the other token of the same lemma in one feature
    1, # Only differs from the other token of the same lemma in one feature
    0  # No other tokens of the same lemma, so no surprisal
  )))
  
  # print(tsv_data$sum_surprisal_morph_split) # debug
  
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
  
  # Get sum of surprisals per token
  tsv_data <- read.table(file.path(DIR_S_FEAT, "surprisal_per_feat_per_agg_level_token_core_features_only_test_01.tsv"), sep = "\t", header = TRUE, stringsAsFactors = FALSE)
  
  # The table should have a column called sum_surprisal_morph_split
  expect_true("sum_surprisal_morph_split" %in% colnames(tsv_data))

  # Round tsv_data$sum_surprisal_morph_split to 2 decimal places for comparison
  tsv_data$sum_surprisal_morph_split <- round(tsv_data$sum_surprisal_morph_split, 2)

  # The surprisal column should be as described here:
  expect_true(all(tsv_data$sum_surprisal_morph_split == c(
    0, # No other identical tokens, so no surprisal
    0, # No other identical tokens, so no surprisal
    0, # No other identical tokens, so no surprisal
    0, # No other identical tokens, so no surprisal
    0  # No other identical tokens, so no surprisal
  )))
  
  # print(tsv_data$sum_surprisal_morph_split) # debug
  
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
  
  # Get sum of surprisals per token
  tsv_data <- read.table(file.path(DIR_S_FEAT, "surprisal_per_feat_per_agg_level_upos_all_features_test_01.tsv"), sep = "\t", header = TRUE, stringsAsFactors = FALSE)
  
  # The table should have a column called sum_surprisal_morph_split
  expect_true("sum_surprisal_morph_split" %in% colnames(tsv_data))

  # Round tsv_data$sum_surprisal_morph_split to 2 decimal places for comparison
  tsv_data$sum_surprisal_morph_split <- round(tsv_data$sum_surprisal_morph_split, 2)

  # The surprisal column should be as described here:
  expect_true(all(tsv_data$sum_surprisal_morph_split == c(
    1, # The first noun has four features, three are identical to the second noun and one is different.
    1, # The second noun has four features, three are identical to the second noun and one is different
    2.17, # Surprisal of 1/3 plus surprisal of 2/3, rounded
    2.17,  # Surprisal of 1/3 plus surprisal of 2/3, rounded
    3.17 # Surprisal of 1/3 plus surprisal of 1/3, rounded
  )))
  
  # print(tsv_data$sum_surprisal_morph_split) # debug
  
})

###########################################################
# For the last two test cases we will define new test data.
test_data <- data.frame(
  id = c("TEST_N01", "TEST_N02", "TEST_V01", "TEST_V02", "TEST_V03", "TEST_V04"),
  doc_id = rep("", 6), # leave doc_id column empty for now
  paragraph_id = rep("000", 6), # don't need a real paragraph ID
  sentence_id = c("TEST_01","TEST_01", "TEST_01", "TEST_02", "TEST_02", "TEST_02"),
  sentence = c(rep("01 This is a test.",3), rep("02 This is a test.",3)),
  token_id = c(1, 2, 3, 4, 5, 6),
  token = c("t_n_one","t_n_two", "t_v_one","t_v_one", "t_v_one_suffix", "t_v_two"), # two tokens are now identical
  lemma = c("t_n_one","t_n_one","t_v_one","t_v_one", "t_v_one", "t_v_two"),
  upos = c("NOUN","NOUN","VERB","VERB", "VERB", "VERB"),
  xpos = c("N","N","V","V", "V", "V"),
  feats = c(
    "Gender=Fem|NounBase=Bound|Number=Sing", # 1st noun
    "Gender=Fem|NounBase=Bound|Number=Sing|FakeFeat=BlahBlah", # 2nd noun, same lemma as 1st noun
    "Gender=Masc|Number=Sing|FakeFeat=BlahBlah", # 1st verb, same lemma as 2nd and 3rd verbs, same token as 2nd verb
    "Gender=Fem|Number=Sing", # 2nd verb, same lemma as 1st and 3rd verbs, same token as 1st verb
    "", # 3rd verb, same lemma as 1st and 2nd verbs
    "" # 4th verb
  ),
  head_token_id = c("0","1","2", "0", "1", "2"),
  dep_rel = rep("TEST",6),
  deps = rep("", 6), # leave deps column empty for now
  misc = rep("test misc string",6), # leave misc column as test string for now
  stringsAsFactors = FALSE
)

# Write the new test data to the TSV file
write.table(test_data, fpath_out_test, sep = "\t", row.names = FALSE, quote = FALSE)

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
  
  # Get sum of surprisals per token
  tsv_data <- read.table(file.path(DIR_S_FEAT, "surprisal_per_feat_per_agg_level_lemma_all_features_test_01.tsv"), sep = "\t", header = TRUE, stringsAsFactors = FALSE)
  
  # The table should have a column called sum_surprisal_morph_split
  expect_true("sum_surprisal_morph_split" %in% colnames(tsv_data))

  # Round tsv_data$sum_surprisal_morph_split to 2 decimal places for comparison
  tsv_data$sum_surprisal_morph_split <- round(tsv_data$sum_surprisal_morph_split, 2)

  # The surprisal column should be as described here:
  expect_true(all(tsv_data$sum_surprisal_morph_split == c(
    1, # The first noun has four features, three are identical to the second noun and one is different.
    1, # The second noun has four features, three are identical to the second noun and one is different
    3.75, # Surprisal of 1/3 plus surprisal of 2/3 plus 1/3, rounded
    2.75, # Surprisal of 1/3 plus surprisal of 2/3 plus 2/3, rounded
    3.75, # Surprisal of 1/3 plus surprisal of 1/3 plus 2/3, rounded
    0     # No other tokens of the same lemma, so no surprisal
  )))
  
  # print(tsv_data$sum_surprisal_morph_split) # debug
  
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
  
  # Get sum of surprisals per token
  tsv_data <- read.table(file.path(DIR_S_FEAT, "surprisal_per_feat_per_agg_level_token_all_features_test_01.tsv"), sep = "\t", header = TRUE, stringsAsFactors = FALSE)
  
  # The table should have a column called sum_surprisal_morph_split
  expect_true("sum_surprisal_morph_split" %in% colnames(tsv_data))

  # Round tsv_data$sum_surprisal_morph_split to 2 decimal places for comparison
  tsv_data$sum_surprisal_morph_split <- round(tsv_data$sum_surprisal_morph_split, 2)

  # The surprisal column should be as described here:
  expect_true(all(tsv_data$sum_surprisal_morph_split == c(
    0, # No other identical tokens, so no surprisal
    0, # No other identical tokens, so no surprisal
    2, # Another token with 2 features different
    2, # Another token with 2 features different
    0, # No other tokens of the same lemma, so no surprisal
    0  # No other tokens of the same lemma, so no surprisal
  )))
  
  # print(tsv_data$sum_surprisal_morph_split) # debug
  
})
  
# Reset working directory
# setwd("../tests")