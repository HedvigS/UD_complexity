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
# TODO

# Create test data.
# First define the filepath for the TSV file that will serve as test data input for the function.
directory_out_test <- paste0("output_test/processed_data/", UD_version, "/") # Or change this to wherever the input TSV will be.

# The dataframe defined in this script will be saved here as a TSV file, then processed by the script to be tested.
fpath_out_test <- paste0(directory_out_test, "test_multiword.tsv") 

# Define the dataframe to be saved as TSV file for testing.
# Five tokens with two multiwords.
test_data <- data.frame(
  id = c("01", "02", "03", "04", "05", "06", "07"),
  doc_id = rep("", 7), # leave doc_id column empty for now
  paragraph_id = rep("000", 7), # don't need a real paragraph ID
  sentence_id = c("TEST_01","TEST_01", "TEST_01", "TEST_01", "TEST_02", "TEST_02", "TEST_02"),
  sentence = c(rep("01 This is a test.",4), rep("02 This is a test.",3)),
  token_id = c("1", "2", "2-3", "3", "4", "4-5", "5"),
  token = c("a","b", "bc","c", "d", "de", "e"),
  lemma = c("a","b","","c", "d", "", "e"),
  upos = c("NOUN","NOUN","","VERB", "VERB", "", "NOUN"),
  xpos = c("N","N", "", "V", "V", "", "N"),
  feats = c(    "Gender=Fem|NounBase=Bound|Number=Sing",  # 1
                "Gender=Fem|NounBase=Bound|Number=Plural|FakeFeat=BlahBlah", # 2
                "", # 2-3
                "Gender=Fem|Number=Plural", # 3
                "Gender=Masc|Number=Sing", # 4
                "", # 4-5
                "Gender=Fem|Number=Sing" # 5
            ),
  head_token_id = c("0","1","2","3", "1", "2", "0"),
  dep_rel = rep("TEST",7),
  deps = rep("", 7), # leave deps column empty for now
  misc = rep("test misc string",7), # leave misc column as test string for now
  stringsAsFactors = FALSE
)

# Create the directory if required
if (!dir.exists(directory_out_test)) {
  dir.create(directory_out_test, recursive = TRUE)
}

# Write the test data to a TSV file
write.table(test_data, fpath_out_test, sep = "\t", row.names = FALSE, quote = FALSE)

# Run the test
# TODO: Call the function with the test data file as input