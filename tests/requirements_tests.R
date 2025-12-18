UD_version <- "ud-treebanks-v2.14"

# Set CRAN mirror
options(repos = c(CRAN = "https://cloud.r-project.org/"))

# Set the working directory to /code/
if (basename(getwd()) == "UD_complexity") {
  setwd("code")
} else if (basename(getwd()) == "tests") {
  setwd("../code")
} else if (basename(getwd()) == "code") {
  # Do nothing, already in the correct directory
} else {
  stop("Unexpected working directory. Please run the script from 'UD_complexity' or 'tests' directory.")
}

# Load the requirements.
if (basename(getwd()) == "code") {
  f_requirements <- "../tests/requirements_tests.tsv"
} else {
  stop("Unexpected working directory. Please run the script from 'UD_complexity' or 'tests' directory.")
}

#creating and setting the library dir 
lib_dir <- paste0("../utility/packages/")
if(!dir.exists(lib_dir)){
  dir.create(lib_dir)
}

# Set the library path to our custom library directory
.libPaths(lib_dir)

#reading in the function that installs and loads packages
source("../utility/fun_def_h_load.R")

# Get the already installed packages
installed_pkgs <- as.data.frame(installed.packages(lib.loc = lib_dir ))[, c("Package", "Version"), drop = FALSE]

# Install remotes package if not already installed
if(!"remotes" %in% installed_pkgs[,"Package"]  ){
  install.packages(pkgs = "remotes", source = "https://cran.r-project.org/src/contrib/remotes_2.5.0.tar.gz", lib = "../utility/packages/", upgrade = "default", repos = "https://cloud.r-project.org/")
}
library(remotes, lib.loc = "../utility/packages/")

#reading in the table of packages to install and load
pkgs_df <- utils::read.delim(file = f_requirements, sep = "\t")

####################

#looping over dataframe to install packages
for(i in 1:nrow(pkgs_df)
    ){  
  
  pkg <- pkgs_df[i, c("Package")]
  version <- pkgs_df[i, c("Version")]
  
  cat("I'm trying to install ", pkg, " ", version ,", version.\n")
    h_install(pkg = pkg, version = version, lib = lib_dir, verbose = T, dependencies = NA, repos = "https://cloud.r-project.org/")
    cat("Installed: ", pkg, " version ", version,".\n")
}

#looping over dataframe to load packages
for(i in 1:nrow(pkgs_df)
    ){  
  
  pkg <- pkgs_df[i, c("Package")]
  version <- pkgs_df[i, c("Version")]
  
  cat("I'm trying to load ", pkg, " ", version ,", version.\n")
    h_load(pkg = pkg, verbose = T, lib = lib_dir)
    cat("Loaded: ", pkg, " version ", version,".\n")
}