# Load the requirements and change the working directory
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

source("../tests/requirements_tests.R")

# Load the function to be tested
source("03_process_data_per_UD_proj.R")

# Create test data.

# Define the dataframe to be saved as TSV file for testing.
# Five tokens with two multiwords.
# Check the following cases:
# 1. Multiwords get concatenated correctly. UPOS's are concatenated and lemmas are set as the token.
# 2. UPOS, core: FakeFeat is dropped. Core values get "unassigned". Like core values get combined; unlike core values get concatenated.
# 3. UPOS, all: FakeFeat is kept. FakeFeat values get "unassigned". Like values get combined; unlike values get concatenated.
test_data <- data.frame(
  id = c("01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12", "13", "14", "15"),
  doc_id = rep("", 15), # leave doc_id column empty for now
  paragraph_id = rep("000", 15), # don't need a real paragraph ID
  sentence_id = c("TEST_01","TEST_01", "TEST_01", "TEST_01", 
  "TEST_02", "TEST_02", "TEST_02", "TEST_02", "TEST_02", "TEST_02", 
  "TEST_03", "TEST_03", "TEST_03",
  "TEST_04", "TEST_04"
  ),
  sentence = c(rep("01 This is a test.",4), rep("02 This is a test.",6), rep("03 Another t'est",3), rep("04 Final test, no multis",2)),
  token_id = c("1", "2", "2-3", "3", "4", "4-5", "5", "6", "6-7", "7", "8", "8-9", "9", "10", "11"),
  token = c("a","b", "bc","c", "d", "de", "e", "d", "de", "e", "t", "t's", "s", "fop", "fip"),
  lemma = c("a","b","","c", "d", "", "e", "d", "", "e", "t", "", "s", "f", "f"),
  upos = c("ADJ","NOUN","","VERB", "NOUN", "", "VERB", "NOUN", "", "VERB", "VERB", "", "NOUN", "ADJ", "ADJ"),
  xpos = c("A","N", "", "V", "N", "", "V", "N", "", "V", "V", "", "N", "A", "A"),
  feats = c(    "Gender=Fem|NounBase=Bound|Number=Sing",  # 1
                "Gender=Fem|NounBase=Bound|Number=Plural|FakeFeatUPOS=BlahBlah", # 2
                "", # 2-3 # should get Gender=Fem|Number=Plural, and FakeFeatUPOS=BlahBlah when features=all
                "Gender=Fem|Number=Plural", # 3
                "Gender=Masc|Number=Sing", # 4
                "", # 4-5 # should get Gender=Masc|Gender=Fem|Number=Sing, and NounBase=unassigned and FakeFeatUPOS=unassigned when features=all
                "Gender=Fem|Number=Sing", # 5
                "Gender=Veg|FakeFeatLemma=BlueBlue", # 6 
                "", # 6-7 # Should get Gender=Veg|Number=Plural|FakeFeatLemma=BlueBlue,Green and FakeFeatUPOS=unassigned when features=all
                "Gender=Veg|FakeFeatLemma=Green", # 7 
                "Gender=Veg|Number=Plural|FakeFeat=BlueBlue", # 8 
                "", # 8-9 # Should get Gender=Veg|Number=Plural|FakeFeat=BlueBlue,Green when features=all
                "Gender=Veg|Number=Plural|FakeFeat=Green", # 9 
                "Gender=Masc|FakeFeat=Based", # 10
                "" # 11
            ), # TOTAL: 15
  head_token_id = c("0","1","2","3", "1", "2", "0", "1", "2", "0", "0", "2", "1", "0", "1"),
  dep_rel = rep("TEST",15),
  deps = rep("", 15), # leave deps column empty for now
  misc = rep("test misc string",15), # leave misc column as test string for now
  stringsAsFactors = FALSE
)

# test_data <- data.frame(
#   id = c("TEST_N01", "TEST_N02", "TEST_V01", "TEST_V02", "TEST_V03"),
#   doc_id = rep("", 5), # leave doc_id column empty for now
#   paragraph_id = rep("000", 5), # don't need a real paragraph ID
#   sentence_id = c("TEST_01","TEST_01", "TEST_01", "TEST_02", "TEST_02"),
#   sentence = c(rep("01 This is a test.",3), rep("02 This is a test.",2)),
#   token_id = c(1, 2, 3, 4, 5),
#   token = c("t_n_one","t_n_two", "t_v_one","t_v_one_suffix", "t_v_two"),
#   lemma = c("t_n_one","t_n_two","t_v_one","t_v_one", "t_v_two"),
#   upos = c("NOUN","NOUN","VERB","VERB", "VERB"),
#   xpos = c("N","N","V","V", "V"),
#   feats = c("Gender=Fem|NounBase=Bound|Number=Sing", 
#             "Gender=Fem|NounBase=Bound|Number=Sing|FakeFeat=BlahBlah", 
#             "Gender=Masc|Number=Sing", 
#             "Gender=Fem|Number=Sing", 
#             ""),
#   head_token_id = c("0","1","2","0", "1"),
#   dep_rel = rep("TEST",5),
#   deps = rep("", 5), # leave deps column empty for now
#   misc = rep("test misc string",5), # leave misc column as test string for now
#   stringsAsFactors = FALSE
# )

# First define the filepath for the TSV file that will serve as test data input for the function.
directory_out_test <- paste0("output_test/processed_data/", UD_version, "_collapsed/") # Or change this to wherever the input TSV will be.

# Create the directory if required
if (!dir.exists(directory_out_test)) {
  dir.create(directory_out_test, recursive = TRUE)
} else { # If the directory already exists, clear its contents to avoid interference with previous test runs.
  cat("Clearing existing test output directory: ", directory_out_test, "\n")
  unlink(file.path(directory_out_test, "*"), recursive = TRUE)
}

# The dataframe defined in this script will be saved here as a TSV file, then processed by the script to be tested.
fpath_out_test <- paste0(directory_out_test, "test_multiword.tsv")

# Write the test data to a TSV file
cat("Writing test data to ", fpath_out_test, "\n")
write.table(test_data, fpath_out_test, sep = "\t", row.names = FALSE, quote = FALSE)

# TEST CASE 1: agg_level upos, core features only.
dir_processed <- "output_test/processed_data/ud-treebanks-v2.14_processed/"
test_that("Test process_UD_data: test data, per upos, core features only",{
  process_UD_data(input_dir = "output_test/processed_data/ud-treebanks-v2.14_collapsed/", 
                  output_dir = dir_processed, 
                  agg_level = "upos", #lemma token,
                  core_features = "core_features_only",
  )

  # Read the processed TSV file and check if the multiwords and features are processed correctly.
  fpath_processed <- paste0(dir_processed, "agg_level_upos_core_features_only/processed_tsv/test_multiword.tsv")

  # Assert that the file exists
  expect_true(file.exists(fpath_processed))

  # Read the file into a dataframe
  processed_data <- read.table(fpath_processed, sep = "\t", header = TRUE, stringsAsFactors = FALSE)

  # There should be 7 rows (after merging multiwords)
  expect_equal(nrow(processed_data), 7)

  # The features should look as follows:
  ls_features_expected <- c(
    "Gender=Fem|Number=Sing", # basic token
    "Gender=Fem|Number=Plural", # multiword 2-3
    "Gender=Masc|Gender=Fem|Number=Sing", # multiword 4-5
    "Gender=Veg|Number=unassigned",  # multiword 6-7
    "Gender=Veg|Number=Plural",  # multiword 8-9
    "Gender=Masc|Number=unassigned",  # basic token no multiword
    "Gender=unassigned|Number=unassigned"  # basic token no multiword
  )

  # Check the features column matches the expected values
  expect_equal(processed_data$feats, ls_features_expected)

  # The UPOS's should have been concatenated as follows:
  ls_upos_expected <- c(
    "ADJ", # basic token
    "NOUN_VERB", # multiword 2-3
    "NOUN_VERB", # multiword 4-5
    "NOUN_VERB", # multiword 6-7
    "VERB_NOUN",  # multiword 8-9
    "ADJ",  # basic token no multiword
    "ADJ"  # basic token no multiword
  )

  # Check the upos column matches the expected values
  expect_equal(processed_data$upos, ls_upos_expected)

  # The multiword's lemmas should be set to the token value.
  # We always concatenate UPOS to the end of lemmas, because the same lemma can have different UPOS's.
  # "bow" (weapon) vs "bow" (to bend forward) are different lemmas in this context and should be marked as such.
  ls_lemmas_expected <- c(
    "a_ADJ", # basic token
    "bc_NOUN_VERB", # multiword 2-3
    "de_NOUN_VERB", # multiword 4-5
    "de_NOUN_VERB", # multiword 6-7
    "t's_VERB_NOUN",  # multiword 8-9
    "f_ADJ",  # basic token no multiword
    "f_ADJ"  # basic token no multiword
  )

  # Check the lemma column matches the expected values
  expect_equal(processed_data$lemma, ls_lemmas_expected)

})

# TEST CASE 2: agg_level upos, all features.
test_that("Test process_UD_data: test data, per upos, all features",{
  process_UD_data(input_dir = "output_test/processed_data/ud-treebanks-v2.14_collapsed/", 
                  output_dir = dir_processed, 
                  agg_level = "upos", #lemma token,
                  core_features = "all_features",
  )

  # Read the processed TSV file and check if the multiwords and features are processed correctly.
  fpath_processed <- paste0(dir_processed, "agg_level_upos_all_features/processed_tsv/test_multiword.tsv")

  # Assert that the file exists
  expect_true(file.exists(fpath_processed))

  # Read the file into a dataframe
  processed_data <- read.table(fpath_processed, sep = "\t", header = TRUE, stringsAsFactors = FALSE)

  # There should be 7 rows (after merging multiwords)
  expect_equal(nrow(processed_data), 7)

  # The features should look as follows:
  ls_features_expected <- c(
    "FakeFeat=unassigned|Gender=Fem|NounBase=Bound|Number=Sing", # basic token
    "FakeFeatLemma=unassigned|FakeFeatUPOS=BlahBlah|Gender=Fem|NounBase=Bound|Number=Plural", # multiword 2-3
    "FakeFeatLemma=unassigned|FakeFeatUPOS=unassigned|Gender=Masc|Gender=Fem|NounBase=unassigned|Number=Sing", # multiword 4-5
    "FakeFeatLemma=BlueBlue|FakeFeatLemma=Green|FakeFeatUPOS=unassigned|Gender=Veg|NounBase=unassigned|Number=unassigned",  # multiword 6-7
    "FakeFeat=BlueBlue|FakeFeat=Green|Gender=Veg|Number=Plural",  # multiword 8-9
    "FakeFeat=Based|Gender=Masc|NounBase=unassigned|Number=unassigned",  # basic token no multiword
    "FakeFeat=unassigned|Gender=unassigned|NounBase=unassigned|Number=unassigned"  # basic token no multiword
  )

  # Check the features column matches the expected values
  expect_equal(processed_data$feats, ls_features_expected)

  # The UPOS's should have been concatenated as follows:
  ls_upos_expected <- c(
    "ADJ", # basic token
    "NOUN_VERB", # multiword 2-3
    "NOUN_VERB", # multiword 4-5
    "NOUN_VERB", # multiword 6-7
    "VERB_NOUN",  # multiword 8-9
    "ADJ",  # basic token no multiword
    "ADJ"  # basic token no multiword
  )

  # Check the upos column matches the expected values
  expect_equal(processed_data$upos, ls_upos_expected)

  # The multiword's lemmas should be set to the token value.
  # We always concatenate UPOS to the end of lemmas, because the same lemma can have different UPOS's.
  # "bow" (weapon) vs "bow" (to bend forward) are different lemmas in this context and should be marked as such.
  ls_lemmas_expected <- c(
    "a_ADJ", # basic token
    "bc_NOUN_VERB", # multiword 2-3
    "de_NOUN_VERB", # multiword 4-5
    "de_NOUN_VERB", # multiword 6-7
    "t's_VERB_NOUN",  # multiword 8-9
    "f_ADJ",  # basic token no multiword
    "f_ADJ"  # basic token no multiword
  )

  # Check the lemma column matches the expected values
  expect_equal(processed_data$lemma, ls_lemmas_expected)

})

# TEST CASE 3: agg_level lemma, core features only.
test_that("Test process_UD_data: test data, per lemma, core features only",{
  process_UD_data(input_dir = "output_test/processed_data/ud-treebanks-v2.14_collapsed/", 
                  output_dir = dir_processed, 
                  agg_level = "lemma",
                  core_features = "core_features_only",
  )

  # Read the processed TSV file and check if the multiwords and features are processed correctly.
  fpath_processed <- paste0(dir_processed, "agg_level_lemma_core_features_only/processed_tsv/test_multiword.tsv")

  # Assert that the file exists
  expect_true(file.exists(fpath_processed))

  # Read the file into a dataframe
  processed_data <- read.table(fpath_processed, sep = "\t", header = TRUE, stringsAsFactors = FALSE)

  # There should be 7 rows (after merging multiwords)
  expect_equal(nrow(processed_data), 7)

  # The features should look as follows:
  ls_features_expected <- c(
    "Gender=Fem|Number=Sing", # basic token
    "Gender=Fem|Number=Plural", # multiword 2-3
    "Gender=Masc|Gender=Fem|Number=Sing", # multiword 4-5
    "Gender=Veg|Number=unassigned",  # multiword 6-7
    "Gender=Veg|Number=Plural",  # multiword 8-9
    "Gender=Masc",  # basic token no multiword
    "Gender=unassigned"  # basic token no multiword
  )

  # Check the features column matches the expected values
  expect_equal(processed_data$feats, ls_features_expected)

  # The UPOS's should have been concatenated as follows:
  ls_upos_expected <- c(
    "ADJ", # basic token
    "NOUN_VERB", # multiword 2-3
    "NOUN_VERB", # multiword 4-5
    "NOUN_VERB", # multiword 6-7
    "VERB_NOUN",  # multiword 8-9
    "ADJ",  # basic token no multiword
    "ADJ"  # basic token no multiword
  )

  # Check the upos column matches the expected values
  expect_equal(processed_data$upos, ls_upos_expected)

  # The multiword's lemmas should be set to the token value.
  # We always concatenate UPOS to the end of lemmas, because the same lemma can have different UPOS's.
  # "bow" (weapon) vs "bow" (to bend forward) are different lemmas in this context and should be marked as such.
  ls_lemmas_expected <- c(
    "a_ADJ", # basic token
    "bc_NOUN_VERB", # multiword 2-3
    "de_NOUN_VERB", # multiword 4-5
    "de_NOUN_VERB", # multiword 6-7
    "t's_VERB_NOUN",  # multiword 8-9
    "f_ADJ",  # basic token no multiword
    "f_ADJ"  # basic token no multiword
  )

  # Check the lemma column matches the expected values
  expect_equal(processed_data$lemma, ls_lemmas_expected)

})

# # TEST CASE 4: agg_level lemma, all features.
test_that("Test process_UD_data: test data, per lemma, all features",{
  process_UD_data(input_dir = "output_test/processed_data/ud-treebanks-v2.14_collapsed/", 
                  output_dir = dir_processed, 
                  agg_level = "lemma",
                  core_features = "all_features",
  )

  # Read the processed TSV file and check if the multiwords and features are processed correctly.
  fpath_processed <- paste0(dir_processed, "agg_level_lemma_all_features/processed_tsv/test_multiword.tsv")

  # Assert that the file exists
  expect_true(file.exists(fpath_processed))

  # Read the file into a dataframe
  processed_data <- read.table(fpath_processed, sep = "\t", header = TRUE, stringsAsFactors = FALSE)

  # There should be 7 rows (after merging multiwords)
  expect_equal(nrow(processed_data), 7)

  # The features should look as follows:
  ls_features_expected <- c(
    "Gender=Fem|NounBase=Bound|Number=Sing", # basic token
    "FakeFeatUPOS=BlahBlah|Gender=Fem|NounBase=Bound|Number=Plural", # multiword 2-3
    "FakeFeatLemma=unassigned|Gender=Masc|Gender=Fem|Number=Sing", # multiword 4-5
    "FakeFeatLemma=BlueBlue|FakeFeatLemma=Green|Gender=Veg|Number=unassigned",  # multiword 6-7
    "FakeFeat=BlueBlue|FakeFeat=Green|Gender=Veg|Number=Plural",  # multiword 8-9
    "FakeFeat=Based|Gender=Masc",  # basic token no multiword
    "FakeFeat=unassigned|Gender=unassigned"  # basic token no multiword
  )

  # Check the features column matches the expected values
  expect_equal(processed_data$feats, ls_features_expected)

  # The UPOS's should have been concatenated as follows:
  ls_upos_expected <- c(
    "ADJ", # basic token
    "NOUN_VERB", # multiword 2-3
    "NOUN_VERB", # multiword 4-5
    "NOUN_VERB", # multiword 6-7
    "VERB_NOUN",  # multiword 8-9
    "ADJ",  # basic token no multiword
    "ADJ"  # basic token no multiword
  )

  # Check the upos column matches the expected values
  expect_equal(processed_data$upos, ls_upos_expected)

  # The multiword's lemmas should be set to the token value.
  # We always concatenate UPOS to the end of lemmas, because the same lemma can have different UPOS's.
  # "bow" (weapon) vs "bow" (to bend forward) are different lemmas in this context and should be marked as such.
  ls_lemmas_expected <- c(
    "a_ADJ", # basic token
    "bc_NOUN_VERB", # multiword 2-3
    "de_NOUN_VERB", # multiword 4-5
    "de_NOUN_VERB", # multiword 6-7
    "t's_VERB_NOUN",  # multiword 8-9
    "f_ADJ",  # basic token no multiword
    "f_ADJ"  # basic token no multiword
  )

  # Check the lemma column matches the expected values
  expect_equal(processed_data$lemma, ls_lemmas_expected)

})