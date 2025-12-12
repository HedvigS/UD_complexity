R_version_numbers <- paste0(R.version$major, ".", R.version$minor)

if(R_version_numbers != "4.5.0"){
  message("These scripts were written using R version 4.5.0, but you are using ", R_version_numbers, ". This needn't be a problem, but it's worth noting in case the results differ.\n")
}

#creating and setting the library dir 
lib_dir <- paste0("../utility/packages/")
if(!dir.exists(lib_dir)){
  dir.create(lib_dir)
}

.libPaths(lib_dir)

#reading in the function that installs and loads packages
source("../utility/fun_def_h_load.R")

#reading in the table of packages to install and load
pkgs_df <- utils::read.delim(file = "../requirements.tsv", sep = "\t")

# Load packages installed from binary
h_load(pkg = "data.table", lib = lib_dir, verbose = T)
h_load(pkg = "Matrix", lib = lib_dir, verbose = T)

#looping over dataframe to load packages
for(i in 1:nrow(pkgs_df)
){  
  
  pkg <- pkgs_df[i, c("Package")]
  
  cat("I'm trying to load ", pkg, " from ", lib_dir,".\n")
  h_load(pkg = pkg, lib = lib_dir, verbose = T)
}

# UD data info
#https://lindat.mff.cuni.cz/repository/xmlui/handle/11234/1-5287
#https://lindat.mff.cuni.cz/repository/xmlui/bitstream/handle/11234/1-5287/ud-treebanks-v2.13.tgz?sequence=1&isAllowed=y