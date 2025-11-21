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

installed_pkgs <- as.data.frame(installed.packages(lib.loc = lib_dir ))[, c("Package", "Version"), drop = FALSE]

#installing data.table version 1.17.8
# the data.table R package is a dependency of other packages used in this project (e.g. ud_pipe)
# installing the most recent version of data.table is relatively easy, this can be done with install.packages.
# however, installing older version of data.table is difficult and may require installing software outside of R such as gettext for macos users due to CRAN not hosting binary files of older versions of data.table and therefore needing to compile them, which in turn requires gettext.
# to faciliate versioning, we have fetched the binary files for data.table version 1.17.8. 
# the code below checks if you are on a mac arm64, mac x86_64 or windows machine and then installs from the binary files provided
# if you are on a linux machine and want to install an older version of data.table, we recommend remotes::install_version("data.table", version = "1.17.8").

#installing data.table 1.17
h_install_from_binary(pkg = "data.table_1.17.8")

#same problem as with data.table, but other packages
#installing Rtsne 0.17
#It is a dependency of the package randomcoloR
h_install_from_binary(pkg = "Rtsne_0.17")

# installing from binary file: Matrix
h_install_from_binary(pkg = "Matrix_1.7-3")

# installing from binary file: ggpubr
h_install_from_binary(pkg = "ggpubr_0.6.1")

# installing from binary file: Rtsne
h_install_from_binary(pkg = "Rtsne_0.17")

# installing from binary file: openssl
h_install_from_binary(pkg = "openssl_2.3.3")

###########################
#installing rest of packages
###########################

# Install remotes package if not already installed
if(!"remotes" %in% installed_pkgs[,"Package"]  ){
  install.packages(pkgs = "remotes", source = "https://cran.r-project.org/src/contrib/remotes_2.5.0.tar.gz", lib = "../utility/packages/", upgrade = "default", repos = "https://cloud.r-project.org/")
}
library(remotes, lib.loc = "../utility/packages/")

#reading in the table of packages to install and load
pkgs_df <- utils::read.delim(file = "../requirements.tsv", sep = "\t")



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
  
  cat("I'm trying to load ", pkg, " from ", lib_dir,".\n")
  h_load(pkg = pkg, lib = lib_dir, verbose = T)
}

# UD data info
#https://lindat.mff.cuni.cz/repository/xmlui/handle/11234/1-5287
#https://lindat.mff.cuni.cz/repository/xmlui/bitstream/handle/11234/1-5287/ud-treebanks-v2.13.tgz?sequence=1&isAllowed=y