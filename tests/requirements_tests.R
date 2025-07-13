UD_version <- "ud-treebanks-v2.14"

# Set CRAN mirror
options(repos = c(CRAN = "https://cloud.r-project.org/"))

# Install the required packages if they are not already installed.
required_packages <- c("testthat", "dplyr", "magrittr", "tidyr", "readr", "stringr", "reshape2")
for (pkg in required_packages) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg)
  }
}

# # Load required packages
library(testthat)
library(dplyr)
library(magrittr)
library(tidyr)
library(readr)
library(stringr)
library(reshape2)