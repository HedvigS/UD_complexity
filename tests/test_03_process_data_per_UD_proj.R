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

# DIR_SUMMARISED: Summary statistics e.g. "n_types"	"n_tokens"	"n_sentences"	"n_feat_cats"	"TTR"	"LTR"	"n_feats_per_token_mean"	"suprisal_token_mean"	"sum_surprisal_morph_split_mean"	"surprisal_per_morph_featstring_mean"
DIR_SUMMARISED <- "output_test/summarised/"

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

# DIR_TTR: Type-Token Ratios of individual tokens.
DIR_TTR <- "output_test/TTR/"

# Delete the directories if they exist
# This is to ensure that the test data is always fresh and not affected by previous runs.
dir.remove <- c(DIR_SUMMARISED, DIR_S_FEAT, DIR_S_FEAT_LOOKUP, DIR_S_FEATSTRING, DIR_S_FEATSTRING_LOOKUP, DIR_S_TOKEN, DIR_TTR)
for (dir in dir.remove) {
  if (dir.exists(dir)) {
    unlink(dir, recursive = TRUE)
  }
}

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
  
  # TODO: Check /summarised/

  # Check TSV data exists in 5 different directories.
  # Assert the data exists with testthat.
  expect_true(file.exists(file.path(DIR_SUMMARISED, "test_01_summarised_agg_level_upos_core_features_only.tsv")))
  expect_true(file.exists(file.path(DIR_S_FEAT, "surprisal_per_feat_per_agg_level_upos_core_features_only_test_01.tsv")))
  expect_true(file.exists(file.path(DIR_S_FEAT_LOOKUP, "surprisal_per_feat_lookup_agg_level_upos_core_features_only_test_01.tsv")))
  expect_true(file.exists(file.path(DIR_S_FEATSTRING, "surprisal_per_featstring_per_agg_level_upos_core_features_only_test_01.tsv")))
  expect_true(file.exists(file.path(DIR_S_FEATSTRING_LOOKUP, "surprisal_per_featstring_lookup_agg_level_upos_core_features_only_test_01.tsv")))

  # Check 3 further directories
  # The following should be created by any run of the function, regardless of parameters.
  # We check them here and not in any subsequent tests.
  expect_true(file.exists(file.path(DIR_S_TOKEN, "surprisal_per_token_test_01.tsv")))
  expect_true(file.exists(file.path(DIR_TTR, "test_01_TTR_sum.tsv")))
  expect_true(file.exists(file.path(DIR_TTR, "test_01_TTR_full.tsv")))
  
  # Get sum of surprisals per token
  tsv_data <- read.table(file.path(DIR_S_FEAT, "surprisal_per_feat_per_agg_level_upos_core_features_only_test_01.tsv"), sep = "\t", header = TRUE, stringsAsFactors = FALSE)
  
  # The table should have a column called sum_surprisal_morph_split
  expect_true("sum_surprisal_morph_split" %in% colnames(tsv_data))

  # Round tsv_data$sum_surprisal_morph_split to 2 decimal places for comparison
  tsv_data$sum_surprisal_morph_split <- round(tsv_data$sum_surprisal_morph_split, 2)

  # Set test_data_result vector
  test_data_result = c(
    0, # The first noun has three features, all are identical to the second noun.
    0, # The second noun has four features, three are identical to the second noun and one is not a core feature.
    2.17, # Surprisal of 1/3 plus surprisal of 2/3, rounded
    2.17,  # Surprisal of 1/3 plus surprisal of 2/3, rounded
    3.17 # Surprisal of 1/3 plus surprisal of 1/3, rounded
  )

  # The surprisal column should be as described here:
  expect_true(all(tsv_data$sum_surprisal_morph_split == test_data_result))
  
  # print(tsv_data$sum_surprisal_morph_split) # debug

  # Get summarised data
  tsv_data_summarised <- read.table(file.path(DIR_SUMMARISED, "test_01_summarised_agg_level_upos_core_features_only.tsv"), sep = "\t", header = TRUE, stringsAsFactors = FALSE)

  # The columns to check are:
  # "n_types": number of types in the whole dataset
  # "n_tokens": number of tokens in the whole dataset
  # "n_sentences": number of sentences in the whole dataset
  # "n_feat_cats": number of feature categories in the whole dataset
  # "TTR": type-token ratio
  # "LTR": lemma-token ratio
  # "n_feats_per_token_mean": mean features per token
  # "suprisal_token_mean" mean surprisal per token, ignoring features
  # "sum_surprisal_morph_split_mean": mean token summed surprisal of individual features
  # "surprisal_per_morph_featstring_mean": mean token surprisal of full feature string
  expect_true("n_types" %in% colnames(tsv_data_summarised))
  expect_true("n_tokens" %in% colnames(tsv_data_summarised))
  expect_true("n_sentences" %in% colnames(tsv_data_summarised))
  expect_true("n_feat_cats" %in% colnames(tsv_data_summarised))
  expect_true("TTR" %in% colnames(tsv_data_summarised))
  expect_true("LTR" %in% colnames(tsv_data_summarised))
  expect_true("n_feats_per_token_mean" %in% colnames(tsv_data_summarised))
  expect_true("suprisal_token_mean" %in% colnames(tsv_data_summarised))
  expect_true("sum_surprisal_morph_split_mean" %in% colnames(tsv_data_summarised))
  expect_true("surprisal_per_morph_featstring_mean" %in% colnames(tsv_data_summarised))

  # Now check the values.
  # n_types: there were five distinct tokens in the data.
  expect_true(tsv_data_summarised$n_types == 5)
  
  # n_tokens: there were five tokens in the data.
  expect_true(tsv_data_summarised$n_tokens == 5)

  # n_sentences: there were two sentences in the data.
  expect_true(tsv_data_summarised$n_sentences == 2)

  # n_feat_cats: there are only two core feature categories in the data (Gender and Number).
  expect_true(tsv_data_summarised$n_feat_cats == 2)

  # TTR: there were five tokens and five types, so TTR = 1.
  expect_true(tsv_data_summarised$TTR == 1)

  # LTR: there were five tokens and four lemmas, so LTR = 4/5.
  expect_true(round(tsv_data_summarised$LTR, 2) == round(4/5, 2))

  # n_feats_per_token_mean: there were 2 core features in the first noun, 2 in the second noun, 2 in the first verb and 2 in the second verb.
  # So the mean is (2 + 2 + 2 + 2) / 5 = 8/5.
  expect_true(round(tsv_data_summarised$n_feats_per_token_mean, 2) == round(8/5, 2))

  # suprisal_token_mean: there are five distinct tokens that each appear once, so the mean is just log2(5).
  expect_true(round(tsv_data_summarised$suprisal_token_mean, 2) == round(log2(5), 2))

  # sum_surprisal_morph_split_mean: the mean of test_data_result.
  expect_true(round(tsv_data_summarised$sum_surprisal_morph_split_mean, 2) == round(mean(test_data_result), 2))

  # surprisal_per_morph_featstring_mean: Two featstrings are the same when non-core features are removed (i.e. those of the first two nouns).
  # Aggregated over UPOS, so it's 0, 0, 1/3, 1/3, 1/3.
  result = log2(3)*3/5
  expect_true(round(tsv_data_summarised$surprisal_per_morph_featstring_mean, 2) == round(result, 2))
  
})

# Test case 2: lemma, core only
test_that("Test process_data_per_UD_proj: test data, per lemma, core only",{
  process_data_per_UD_proj(directory = "output_test",agg_level = "lemma",core_features = "core_features_only")
  
  # Check TSV data exists in 5 different directories.
  # Assert the data exists with testthat.
  expect_true(file.exists(file.path(DIR_SUMMARISED, "test_01_summarised_agg_level_lemma_core_features_only.tsv")))
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

  # Set the expected result
  test_data_result <- c(
    0, # The first noun has three features, all are identical to the second noun.
    0, # The second noun has four features, three are identical to the second noun and one is not a core feature.
    1, # Only differs from the other token of the same lemma in one feature
    1, # Only differs from the other token of the same lemma in one feature
    0  # No other tokens of the same lemma, so no surprisal
  )

  # The surprisal column should be as described here:
  expect_true(all(tsv_data$sum_surprisal_morph_split == test_data_result))
  
  # print(tsv_data$sum_surprisal_morph_split) # debug

  # Get summarised data
  tsv_data_summarised <- read.table(file.path(DIR_SUMMARISED, "test_01_summarised_agg_level_lemma_core_features_only.tsv"), sep = "\t", header = TRUE, stringsAsFactors = FALSE)

  # The columns to check are:
  # "n_types": number of types in the whole dataset
  # "n_tokens": number of tokens in the whole dataset
  # "n_sentences": number of sentences in the whole dataset
  # "n_feat_cats": number of feature categories in the whole dataset
  # "TTR": type-token ratio
  # "LTR": lemma-token ratio
  # "n_feats_per_token_mean": mean features per token
  # "suprisal_token_mean" mean surprisal per token, ignoring features
  # "sum_surprisal_morph_split_mean": mean token summed surprisal of individual features
  # "surprisal_per_morph_featstring_mean": mean token surprisal of full feature string
  expect_true("n_types" %in% colnames(tsv_data_summarised))
  expect_true("n_tokens" %in% colnames(tsv_data_summarised))
  expect_true("n_sentences" %in% colnames(tsv_data_summarised))
  expect_true("n_feat_cats" %in% colnames(tsv_data_summarised))
  expect_true("TTR" %in% colnames(tsv_data_summarised))
  expect_true("LTR" %in% colnames(tsv_data_summarised))
  expect_true("n_feats_per_token_mean" %in% colnames(tsv_data_summarised))
  expect_true("suprisal_token_mean" %in% colnames(tsv_data_summarised))
  expect_true("sum_surprisal_morph_split_mean" %in% colnames(tsv_data_summarised))
  expect_true("surprisal_per_morph_featstring_mean" %in% colnames(tsv_data_summarised))

  # Now check the values.
  # n_types: there were five distinct tokens in the data.
  expect_true(tsv_data_summarised$n_types == 5)
  
  # n_tokens: there were five tokens in the data.
  expect_true(tsv_data_summarised$n_tokens == 5)

  # n_sentences: there were two sentences in the data.
  expect_true(tsv_data_summarised$n_sentences == 2)

  # n_feat_cats: there are only two core feature categories in the data (Gender and Number).
  expect_true(tsv_data_summarised$n_feat_cats == 2)

  # TTR: there were five tokens and five types, so TTR = 1.
  expect_true(tsv_data_summarised$TTR == 1)

  # LTR: there were five tokens and four lemmas, so LTR = 4/5.
  expect_true(round(tsv_data_summarised$LTR, 2) == round(4/5, 2))

  # n_feats_per_token_mean: there were 2 core features in the first noun, 2 in the second noun, 2 in the first verb and 2 in the second verb.
  # So the mean is (2 + 2 + 2 + 2) / 5 = 8/5.
  expect_true(round(tsv_data_summarised$n_feats_per_token_mean, 2) == round(8/5, 2))

  # suprisal_token_mean: there are five distinct tokens that each appear once, so the mean is just log2(5).
  expect_true(round(tsv_data_summarised$suprisal_token_mean, 2) == round(log2(5), 2))

  # sum_surprisal_morph_split_mean: the mean of test_data_result.
  expect_true(round(tsv_data_summarised$sum_surprisal_morph_split_mean, 2) == round(mean(test_data_result), 2))

  # surprisal_per_morph_featstring_mean: Two featstrings are the same when non-core features are removed (i.e. those of the first two nouns).
  # Aggregated over lemma, so it's 0, 0, 1/2, 1/2, 0.
  # So (0 + 0 + log2(2) + log2(2) + 0)/5 = (1+1)/5 = 2/5.
  expect_true(round(tsv_data_summarised$surprisal_per_morph_featstring_mean, 2) == round(2/5, 2))
  
})

# Test case 3: token, core only
test_that("Test process_data_per_UD_proj: test data, per token, core only",{
  process_data_per_UD_proj(directory = "output_test",agg_level = "token",core_features = "core_features_only")
  
  # Check TSV data exists in 5 different directories.
  # Assert the data exists with testthat.
  expect_true(file.exists(file.path(DIR_SUMMARISED, "test_01_summarised_agg_level_token_core_features_only.tsv")))
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

  # Set expected data
  test_data_result <- c(
    0, # No other identical tokens, so no surprisal
    0, # No other identical tokens, so no surprisal
    0, # No other identical tokens, so no surprisal
    0, # No other identical tokens, so no surprisal
    0  # No other identical tokens, so no surprisal
  )

  # The surprisal column should be as described here:
  expect_true(all(tsv_data$sum_surprisal_morph_split == test_data_result))
  
  # print(tsv_data$sum_surprisal_morph_split) # debug

  # Get summarised data
  tsv_data_summarised <- read.table(file.path(DIR_SUMMARISED, "test_01_summarised_agg_level_token_core_features_only.tsv"), sep = "\t", header = TRUE, stringsAsFactors = FALSE)

  # The columns to check are:
  # "n_types": number of types in the whole dataset
  # "n_tokens": number of tokens in the whole dataset
  # "n_sentences": number of sentences in the whole dataset
  # "n_feat_cats": number of feature categories in the whole dataset
  # "TTR": type-token ratio
  # "LTR": lemma-token ratio
  # "n_feats_per_token_mean": mean features per token
  # "suprisal_token_mean" mean surprisal per token, ignoring features
  # "sum_surprisal_morph_split_mean": mean token summed surprisal of individual features
  # "surprisal_per_morph_featstring_mean": mean token surprisal of full feature string
  expect_true("n_types" %in% colnames(tsv_data_summarised))
  expect_true("n_tokens" %in% colnames(tsv_data_summarised))
  expect_true("n_sentences" %in% colnames(tsv_data_summarised))
  expect_true("n_feat_cats" %in% colnames(tsv_data_summarised))
  expect_true("TTR" %in% colnames(tsv_data_summarised))
  expect_true("LTR" %in% colnames(tsv_data_summarised))
  expect_true("n_feats_per_token_mean" %in% colnames(tsv_data_summarised))
  expect_true("suprisal_token_mean" %in% colnames(tsv_data_summarised))
  expect_true("sum_surprisal_morph_split_mean" %in% colnames(tsv_data_summarised))
  expect_true("surprisal_per_morph_featstring_mean" %in% colnames(tsv_data_summarised))

  # Now check the values.
  # n_types: there were five distinct tokens in the data.
  expect_true(tsv_data_summarised$n_types == 5)
  
  # n_tokens: there were five tokens in the data.
  expect_true(tsv_data_summarised$n_tokens == 5)

  # n_sentences: there were two sentences in the data.
  expect_true(tsv_data_summarised$n_sentences == 2)

  # n_feat_cats: there are only two core feature categories in the data (Gender and Number).
  expect_true(tsv_data_summarised$n_feat_cats == 2)

  # TTR: there were five tokens and five types, so TTR = 1.
  expect_true(tsv_data_summarised$TTR == 1)

  # LTR: there were five tokens and four lemmas, so LTR = 4/5.
  expect_true(round(tsv_data_summarised$LTR, 2) == round(4/5, 2))

  # n_feats_per_token_mean: there were 2 core features in the first noun, 2 in the second noun, 2 in the first verb and 2 in the second verb.
  # So the mean is (2 + 2 + 2 + 2) / 5 = 8/5.
  expect_true(round(tsv_data_summarised$n_feats_per_token_mean, 2) == round(8/5, 2))

  # suprisal_token_mean: there are five distinct tokens that each appear once, so the mean is just log2(5).
  expect_true(round(tsv_data_summarised$suprisal_token_mean, 2) == round(log2(5), 2))

  # sum_surprisal_morph_split_mean: the mean of test_data_result.
  expect_true(round(tsv_data_summarised$sum_surprisal_morph_split_mean, 2) == round(mean(test_data_result), 2))

  # surprisal_per_morph_featstring_mean: All tokens are different so the surprisal is zero.
  expect_true(tsv_data_summarised$surprisal_per_morph_featstring_mean == 0)
  
})

# Test case 4: UPOS, all_features
test_that("Test process_data_per_UD_proj: test data, per UPOS, all_features",{
  process_data_per_UD_proj(directory = "output_test",agg_level = "upos",core_features = "all_features")
  
  # Check TSV data exists in 5 different directories.
  # Assert the data exists with testthat.
  expect_true(file.exists(file.path(DIR_SUMMARISED, "test_01_summarised_agg_level_upos_all_features.tsv")))
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

  # Set expected data
  test_data_result <- c(
    1, # The first noun has four features, three are identical to the second noun and one is different.
    1, # The second noun has four features, three are identical to the second noun and one is different
    2.17, # Surprisal of 1/3 plus surprisal of 2/3, rounded
    2.17,  # Surprisal of 1/3 plus surprisal of 2/3, rounded
    3.17 # Surprisal of 1/3 plus surprisal of 1/3, rounded
  )

  # The surprisal column should be as described here:
  expect_true(all(tsv_data$sum_surprisal_morph_split == test_data_result))
  
  # print(tsv_data$sum_surprisal_morph_split) # debug

  # Get summarised data
  tsv_data_summarised <- read.table(file.path(DIR_SUMMARISED, "test_01_summarised_agg_level_upos_all_features.tsv"), sep = "\t", header = TRUE, stringsAsFactors = FALSE)

  # The columns to check are:
  # "n_types": number of types in the whole dataset
  # "n_tokens": number of tokens in the whole dataset
  # "n_sentences": number of sentences in the whole dataset
  # "n_feat_cats": number of feature categories in the whole dataset
  # "TTR": type-token ratio
  # "LTR": lemma-token ratio
  # "n_feats_per_token_mean": mean features per token
  # "suprisal_token_mean" mean surprisal per token, ignoring features
  # "sum_surprisal_morph_split_mean": mean token summed surprisal of individual features
  # "surprisal_per_morph_featstring_mean": mean token surprisal of full feature string
  expect_true("n_types" %in% colnames(tsv_data_summarised))
  expect_true("n_tokens" %in% colnames(tsv_data_summarised))
  expect_true("n_sentences" %in% colnames(tsv_data_summarised))
  expect_true("n_feat_cats" %in% colnames(tsv_data_summarised))
  expect_true("TTR" %in% colnames(tsv_data_summarised))
  expect_true("LTR" %in% colnames(tsv_data_summarised))
  expect_true("n_feats_per_token_mean" %in% colnames(tsv_data_summarised))
  expect_true("suprisal_token_mean" %in% colnames(tsv_data_summarised))
  expect_true("sum_surprisal_morph_split_mean" %in% colnames(tsv_data_summarised))
  expect_true("surprisal_per_morph_featstring_mean" %in% colnames(tsv_data_summarised))

  # Now check the values.
  # n_types: there were five distinct tokens in the data.
  expect_true(tsv_data_summarised$n_types == 5)
  
  # n_tokens: there were five tokens in the data.
  expect_true(tsv_data_summarised$n_tokens == 5)

  # n_sentences: there were two sentences in the data.
  expect_true(tsv_data_summarised$n_sentences == 2)

  # n_feat_cats: there are four feature categories in the data (Gender, NounBase, Number and FakeFeat).
  expect_true(tsv_data_summarised$n_feat_cats == 4)

  # TTR: there were five tokens and five types, so TTR = 1.
  expect_true(tsv_data_summarised$TTR == 1)

  # LTR: there were five tokens and four lemmas, so LTR = 4/5.
  expect_true(round(tsv_data_summarised$LTR, 2) == round(4/5, 2))

  # n_feats_per_token_mean: there were 3 features in the first noun, 4 in the second noun, 2 in the first verb and 2 in the second verb.
  # So the mean is (3 + 4 + 2 + 2) / 5 = 11/5.
  expect_true(round(tsv_data_summarised$n_feats_per_token_mean, 2) == round(11/5, 2))

  # suprisal_token_mean: there are five distinct tokens that each appear once, so the mean is just log2(5).
  expect_true(round(tsv_data_summarised$suprisal_token_mean, 2) == round(log2(5), 2))

  # sum_surprisal_morph_split_mean: the mean of test_data_result.
  expect_true(round(tsv_data_summarised$sum_surprisal_morph_split_mean, 2) == round(mean(test_data_result), 2))

  # surprisal_per_morph_featstring_mean: All featstrings are different, so we have 1/2 for both nouns and 1/3 for each verb.
  # Aggregated over UPOS, so it's 1/2, 1/2, 1/3, 1/3, 1/3.
  result = ((log2(2)*2)+(log2(3)*3))/5
  expect_true(round(tsv_data_summarised$surprisal_per_morph_featstring_mean, 2) == round(result, 2))
  
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
  
  # Check TSV data exists in 5 different directories.
  # Assert the data exists with testthat.
  expect_true(file.exists(file.path(DIR_SUMMARISED, "test_01_summarised_agg_level_lemma_all_features.tsv")))
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

  # Set expected results
  test_data_result <- c(
    1, # The first noun has four features, three are identical to the second noun and one is different.
    1, # The second noun has four features, three are identical to the second noun and one is different
    3.75, # Surprisal of 1/3 plus surprisal of 2/3 plus 1/3, rounded
    2.75, # Surprisal of 1/3 plus surprisal of 2/3 plus 2/3, rounded
    3.75, # Surprisal of 1/3 plus surprisal of 1/3 plus 2/3, rounded
    0     # No other tokens of the same lemma, so no surprisal
  )

  # The surprisal column should be as described here:
  expect_true(all(tsv_data$sum_surprisal_morph_split == test_data_result))
  
  # print(tsv_data$sum_surprisal_morph_split) # debug

  # Get summarised data
  tsv_data_summarised <- read.table(file.path(DIR_SUMMARISED, "test_01_summarised_agg_level_lemma_all_features.tsv"), sep = "\t", header = TRUE, stringsAsFactors = FALSE)

  # The columns to check are:
  # "n_types": number of types in the whole dataset
  # "n_tokens": number of tokens in the whole dataset
  # "n_sentences": number of sentences in the whole dataset
  # "n_feat_cats": number of feature categories in the whole dataset
  # "TTR": type-token ratio
  # "LTR": lemma-token ratio
  # "n_feats_per_token_mean": mean features per token
  # "suprisal_token_mean" mean surprisal per token, ignoring features
  # "sum_surprisal_morph_split_mean": mean token summed surprisal of individual features
  # "surprisal_per_morph_featstring_mean": mean token surprisal of full feature string
  expect_true("n_types" %in% colnames(tsv_data_summarised))
  expect_true("n_tokens" %in% colnames(tsv_data_summarised))
  expect_true("n_sentences" %in% colnames(tsv_data_summarised))
  expect_true("n_feat_cats" %in% colnames(tsv_data_summarised))
  expect_true("TTR" %in% colnames(tsv_data_summarised))
  expect_true("LTR" %in% colnames(tsv_data_summarised))
  expect_true("n_feats_per_token_mean" %in% colnames(tsv_data_summarised))
  expect_true("suprisal_token_mean" %in% colnames(tsv_data_summarised))
  expect_true("sum_surprisal_morph_split_mean" %in% colnames(tsv_data_summarised))
  expect_true("surprisal_per_morph_featstring_mean" %in% colnames(tsv_data_summarised))

  # Now check the values.
  # n_types: there were five distinct tokens in the data.
  expect_true(tsv_data_summarised$n_types == 5)
  
  # n_tokens: there were six tokens in the data.
  expect_true(tsv_data_summarised$n_tokens == 6)

  # n_sentences: there were two sentences in the data.
  expect_true(tsv_data_summarised$n_sentences == 2)

  # n_feat_cats: there are four feature categories in the data (Gender, NounBase, Number and FakeFeat).
  expect_true(tsv_data_summarised$n_feat_cats == 4)

  # TTR: there were six tokens and five types, so TTR = 5/6.
  expect_true(round(tsv_data_summarised$TTR, 2) == round(5/6, 2))

  # LTR: there were six tokens and three lemmas, so LTR = 3/6.
  expect_true(tsv_data_summarised$LTR == 3/6)

  # n_feats_per_token_mean: there were 3 features in the first noun, 4 in the second noun, 3 in the first verb and 2 in the second verb.
  # So the mean is (3 + 4 + 3 + 2 + 0 + 0) / 6 = 12/6 = 2.
  expect_true(tsv_data_summarised$n_feats_per_token_mean == 2)

  # suprisal_token_mean: there are six tokens and two of them are the same.
  # So we have 1/6, 1/6, 2/6, 2/6, 1/6, 1/6.
  # The surprisal sum is log2(6)*4 + log2(3)*2, and the average is this divided by 6.
  expect_true(round(tsv_data_summarised$suprisal_token_mean, 2) == round((log2(6)*4 + log2(3)*2)/6, 2))

  # sum_surprisal_morph_split_mean: the mean of test_data_result.
  expect_true(round(tsv_data_summarised$sum_surprisal_morph_split_mean, 2) == round(mean(test_data_result), 2))

  # surprisal_per_morph_featstring_mean: All featstrings are different except 5 and 6.
  # But we aggregate by lemma, so it's 1/2, 1/2, 1/3, 1/3, 1/3, 0.
  result = ((log2(2)*2)+(log2(3)*3))/6
  expect_true(round(tsv_data_summarised$surprisal_per_morph_featstring_mean, 2) == round(result, 2))
  
})

# Test case 6: token, all_features
test_that("Test process_data_per_UD_proj: test data, per token, all_features",{
  process_data_per_UD_proj(directory = "output_test",agg_level = "token",core_features = "all_features")
  
  # Check TSV data exists in 5 different directories.
  # Assert the data exists with testthat.
  expect_true(file.exists(file.path(DIR_SUMMARISED, "test_01_summarised_agg_level_token_all_features.tsv")))
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

  # Get expected data
  test_data_result <- c(
    0, # No other identical tokens, so no surprisal
    0, # No other identical tokens, so no surprisal
    2, # Another token with 2 features different
    2, # Another token with 2 features different
    0, # No other tokens of the same lemma, so no surprisal
    0  # No other tokens of the same lemma, so no surprisal
  )

  # The surprisal column should be as described here:
  expect_true(all(tsv_data$sum_surprisal_morph_split == test_data_result))
  
  # print(tsv_data$sum_surprisal_morph_split) # debug

  # Get summarised data
  tsv_data_summarised <- read.table(file.path(DIR_SUMMARISED, "test_01_summarised_agg_level_token_all_features.tsv"), sep = "\t", header = TRUE, stringsAsFactors = FALSE)

  # The columns to check are:
  # "n_types": number of types in the whole dataset
  # "n_tokens": number of tokens in the whole dataset
  # "n_sentences": number of sentences in the whole dataset
  # "n_feat_cats": number of feature categories in the whole dataset
  # "TTR": type-token ratio
  # "LTR": lemma-token ratio
  # "n_feats_per_token_mean": mean features per token
  # "suprisal_token_mean" mean surprisal per token, ignoring features
  # "sum_surprisal_morph_split_mean": mean token summed surprisal of individual features
  # "surprisal_per_morph_featstring_mean": mean token surprisal of full feature string
  expect_true("n_types" %in% colnames(tsv_data_summarised))
  expect_true("n_tokens" %in% colnames(tsv_data_summarised))
  expect_true("n_sentences" %in% colnames(tsv_data_summarised))
  expect_true("n_feat_cats" %in% colnames(tsv_data_summarised))
  expect_true("TTR" %in% colnames(tsv_data_summarised))
  expect_true("LTR" %in% colnames(tsv_data_summarised))
  expect_true("n_feats_per_token_mean" %in% colnames(tsv_data_summarised))
  expect_true("suprisal_token_mean" %in% colnames(tsv_data_summarised))
  expect_true("sum_surprisal_morph_split_mean" %in% colnames(tsv_data_summarised))
  expect_true("surprisal_per_morph_featstring_mean" %in% colnames(tsv_data_summarised))

  # Now check the values.
  # n_types: there were five distinct tokens in the data.
  expect_true(tsv_data_summarised$n_types == 5)
  
  # n_tokens: there were six tokens in the data.
  expect_true(tsv_data_summarised$n_tokens == 6)

  # n_sentences: there were two sentences in the data.
  expect_true(tsv_data_summarised$n_sentences == 2)

  # n_feat_cats: there are four feature categories in the data (Gender, NounBase, Number and FakeFeat).
  expect_true(tsv_data_summarised$n_feat_cats == 4)

  # TTR: there were six tokens and five types, so TTR = 5/6.
  expect_true(round(tsv_data_summarised$TTR, 2) == round(5/6, 2))

  # LTR: there were six tokens and three lemmas, so LTR = 3/6.
  expect_true(tsv_data_summarised$LTR == 3/6)

  # n_feats_per_token_mean: there were 3 features in the first noun, 4 in the second noun, 3 in the first verb and 2 in the second verb.
  # So the mean is (3 + 4 + 3 + 2 + 0 + 0) / 6 = 12/6 = 2.
  expect_true(tsv_data_summarised$n_feats_per_token_mean == 2)

  # suprisal_token_mean: there are six tokens and two of them are the same.
  # So we have 1/6, 1/6, 2/6, 2/6, 1/6, 1/6.
  # The surprisal sum is log2(6)*4 + log2(3)*2, and the average is this divided by 6.
  expect_true(round(tsv_data_summarised$suprisal_token_mean, 2) == round((log2(6)*4 + log2(3)*2)/6, 2))

  # sum_surprisal_morph_split_mean: the mean of test_data_result.
  expect_true(round(tsv_data_summarised$sum_surprisal_morph_split_mean, 2) == round(mean(test_data_result), 2))

  # surprisal_per_morph_featstring_mean: All featstrings are different except 5 and 6.
  # But we aggregate by token, so it's 0, 0, 1/2, 1/2, 0, 0.
  result = (log2(2)*2)/6
  expect_true(round(tsv_data_summarised$surprisal_per_morph_featstring_mean, 2) == round(result, 2))
  
})
  
# Reset working directory
# setwd("../tests")