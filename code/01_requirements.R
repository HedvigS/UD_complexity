

#creating and setting the library dir 
lib_dir <- paste0("../utility/packages/")
if(!dir.exists(lib_dir)){
  dir.create(lib_dir)
}

.libPaths(lib_dir)

installed_pkgs <- as.data.frame(installed.packages(lib.loc = lib_dir ))[, c("Package", "Version"), drop = FALSE]

#installing data.table version 1.17.8
# the data.table R package is a dependency of other packages used in this project (e.g. ud_pipe)
# installing the most recent version of data.table is relatively easy, this can be done with install.packages.
# however, installing older version of data.table is difficult and may require installing software outside of R such as gettext for macos users due to CRAN not hosting binary files of older versions of data.table and therefore needing to compile them, which in turn requires gettext.
# to faciliate versioning, we have fetched the binary files for data.table version 1.17.8. 
# the code below checks if you are on a mac arm64, mac x86_64 or windows machine and then installs from the binary files provided
# if you are on a linux machine and want to install an older version of data.table, we recommend remotes::install_version("data.table", version = "1.17.8").

if(!("data.table" %in% installed_pkgs[,"Package"] 
     )){
if(grepl("arm64", .Platform$pkgType)){
install.packages(pkgs = "../utility/packages_binary/data.table/macos_arm64/data.table_1.17.8.tgz",  repos = NULL,
                 type = "binary", lib = "../utility/packages/")
}

if(grepl("x86_64", .Platform$pkgType)){
  install.packages(pkgs = "../utility/packages_binary/data.table/macos_x86_64/data.table_1.17.8.tgz",  repos = NULL,
                   type = "binary", lib = "../utility/packages/")
}

if(grepl("win", .Platform$pkgType)){
  install.packages(pkgs = "https://cran.r-project.org/src/contrib/data.table_1.17.8.tar.gz",  repos = NULL,
                   type = "source", lib = "../utility/packages/") 
}
}

#installing Rtsne 0.17
# Similarly to data.table, it is necessary to install Rtsne from a binary file instead of from CRAN. We are using Rtsne version 0.17. It is a dependency of the package randomcoloR

if(!("Rtsne" %in% installed_pkgs[,"Package"] )){
if(grepl("arm64", .Platform$pkgType)){
  install.packages(pkgs = "../utility/packages_binary/Rtsne/macos_arm64/Rtsne_0.17.tgz",  repos = NULL,
                   type = "binary", lib = "../utility/packages/")
}

if(grepl("x86_64", .Platform$pkgType)){
  install.packages(pkgs = "../utility/packages_binary/Rtsne/macos_x86_64/Rtsne_0.17.tgz",  repos = NULL,
                   type = "binary", lib = "../utility/packages/")
}

if(grepl("win", .Platform$pkgType)){
  install.packages(pkgs = "../utility/packages_binary/Rtsne/windows/Rtsne_0.17.zip",  repos = NULL,
                   type = "binary", lib = "../utility/packages/") 
}
}


# installing from binary file: openssl
if(!("openssl" %in% installed_pkgs[,"Package"] )){
  if(grepl("arm64", .Platform$pkgType)){
    install.packages(pkgs = "../utility/packages_binary/openssl/macos_arm64/openssl_2.3.3.tgz",  repos = NULL,
                     type = "binary", lib = "../utility/packages/")
  }
  
  if(grepl("x86_64", .Platform$pkgType)){
    install.packages(pkgs = "../utility/packages_binary/openssl/macos_x86_64/openssl_2.3.3.tgz",  repos = NULL,
                     type = "binary", lib = "../utility/packages/")
  }
  
  if(grepl("win", .Platform$pkgType)){
    install.packages(pkgs = "../utility/packages_binary/openssl/windows/openssl_2.3.3.zip",  repos = NULL,
                     type = "binary", lib = "../utility/packages/") 
  }
}


###########################
#installing rest of packages
###########################

# Set CRAN mirror to avoid "trying to use CRAN without setting a mirror" error
options(repos = c(CRAN = "https://cloud.r-project.org/"))

# Install remotes package if not already installed
if(!"remotes" %in% installed_pkgs[,"Package"]  ){
  install.packages(pkgs = "remotes", source = "https://cran.r-project.org/src/contrib/remotes_2.5.0.tar.gz", lib = "../utility/packages/", upgrade = "default")
}
library(remotes, lib.loc = "../utility/packages/")

#reading in the table of packages to install and load
pkgs_df <- utils::read.delim(file = "../requirements.tsv", sep = "\t")

#reading in the function that installs and loads packages
source("../utility/fun_def_h_load.R")

#looping over dataframe to install packages
for(i in 1:nrow(pkgs_df)
    ){  
  
  pkg <- pkgs_df[i, c("Package")]
  version <- pkgs_df[i, c("Version")]
  
    h_load(pkg = pkg, version = version, lib = lib_dir, verbose = T, dependencies = NA, repos = "https://cloud.r-project.org/")
    }


# rcldf is an R package that is not available via CRAN but only GitHub. We use a particular state of the package on GitHub, as indicated by the commit ref "ab9554e763c646a5ea6a49fc0989cf9277322443"
p <- "rcldf"
if(!(p %in% installed_pkgs[,"Package"])){
  print("rcldf not installed, installing from github now")
remotes::install_github("SimonGreenhill/rcldf", dependencies = NA, ref = "ab9554e763c646a5ea6a49fc0989cf9277322443", 
                        lib = lib_dir, upgrade = "never"
                        )
}

library(package = "rcldf", lib.loc = lib_dir, character.only = T)

# UD data info
#https://lindat.mff.cuni.cz/repository/xmlui/handle/11234/1-5287
#https://lindat.mff.cuni.cz/repository/xmlui/bitstream/handle/11234/1-5287/ud-treebanks-v2.13.tgz?sequence=1&isAllowed=y


#setting up output folders
if(!dir.exists("output")){
  dir.create("output")
}

dir <- paste0("output/processed_data/")
if(!dir.exists(dir)){
  dir.create(dir)
}
  dir <- paste0("output/plots/")
if(!dir.exists(dir)){
  dir.create(dir)
}