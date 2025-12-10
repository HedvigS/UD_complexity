
#function to check if a pkg is installed or not, if not it installs it and either way it's loaded.
#inspired by pacman::p_load()

h_install <- function(pkg, 
                   verbose = FALSE, 
                   version = NULL, 
                   repos = "http://cran.us.r-project.org", 
                   dependencies = NA,
                   upgrade = "never",
                   lib = .libPaths()[1]
                   ){
  
  installed_pkgs <- as.data.frame(installed.packages(lib.loc = lib)[, c("Package", "Version"), drop = FALSE])
  
  

    if(is.null(version) & (!(pkg %in% installed_pkgs[,"Package"]))){ #if no version is specified, check if it's installed and if not then go and install it as normal
      
      install.packages(pkg, dependencies = dependencies, repos = repos, lib = lib, upgrade = upgrade)
      
      if(verbose == T){
        cat(paste0("Installed ", pkg, ".\n"))}
      
    }

  ###########Version install
  
      if(!is.null(version)){
      
#      if(repos  != "http://cran.us.r-project.org"){
#      warning("repos must be set to http://cran.us.r-project.org for installing a specific version to work")
#      }
    
#      .install_version_base <- function(pkg, version) {
#        url <- paste0(
#          "https://cran.r-project.org/src/contrib/Archive/",
#          pkg, "/", pkg, "_", version, ".tar.gz"
#        )
#        install.packages(url, repos = repos, type = "source", lib = lib, dependencies = dependencies)
#      }
      
        
      if(!(pkg %in% installed_pkgs[,"Package"])){
      
        remotes::install_version(package  = pkg, version = version, lib = lib, dependencies = dependencies, 
                                  repos = repos, upgrade = upgrade)
        
      }
      
      if(pkg %in% installed_pkgs[,"Package"]){
        
        # Get the installed version of the package
        installed_version <- installed_pkgs[installed_pkgs$Package == pkg, "Version"]

        # If there's a hyphen, replace it with a dot
        if(grepl("-", installed_version)) {
          installed_version <- gsub("-", ".", installed_version)
        }
        if(grepl("-", version)) {
          requested_version <- gsub("-", ".", version)
        } else {
          requested_version <- version
        }

        # Compare the installed version with the requested version
        if(requested_version == installed_version){
          
          if(verbose == T){
            cat(paste0("Package ", pkg," already installed with requested version (", requested_version,").\n"))
            }
        }else{
          
          if(verbose == T){
            cat(paste0("Package ", pkg," already installed with version ", installed_version, " but not with requested version (", requested_version,"). Removing existing and reinstalling.\n"))
          }
          remove.packages(pkgs = pkg, lib = lib)
          remotes::install_version(package  = pkg, version = version, lib = lib, dependencies = dependencies, repos = repos,
                                    upgrade = upgrade)
        }
        }
      }
      
      #version end

  # FIX: try not unloading for now.
  #in order to avoid issues with installing other packages and their depedencies clashing, let's unload the package from the environment

  # if(pkg %in% loadedNamespaces()){
  #   unloadNamespace(pkg)
    
  # }
  
  cat("I've installed ", pkg, " version ", version," in ", lib, ".\n")
  
}

h_load <- function(pkg,  
                   verbose = FALSE, 
                   lib = .libPaths()[1]){

if(verbose == T){
  library(pkg, character.only = T, quietly = F, lib.loc = lib)
  cat(paste0("Loaded ", pkg, " from", lib ,".\n"))
}else{
  suppressMessages(library(pkg, character.only = T, quietly = T, verbose = F, warn.conflicts = F, lib.loc = lib))}
}


h_install_from_binary <- function(pkg){
  
#  pkg <- "data.table_1.17.8"
  package <- sub("_.*$", "", pkg)
  
  if(!(package %in% installed_pkgs[,"Package"] 
  )){
    
    if(grepl("arm64", .Platform$pkgType)){
      filepath <- find_compressed_file(dir = paste0("../utility/packages_binary/", package, "/macos_arm64/"), pkg = pkg)
      
      install.packages(pkgs = filepath,   repos = NULL,
                       type = "binary", lib = "../utility/packages/")
    }
    
    if(grepl("x86_64", .Platform$pkgType)){
      filepath <- find_compressed_file(dir = paste0("../utility/packages_binary/", package, "/macos_x86_64/"), pkg = pkg)
      
      install.packages(pkgs = filepath,  repos = NULL,
                       repos = NULL,
                       type = "source", lib = "../utility/packages/")
    }
    
    if(grepl("win", .Platform$pkgType)){
      filepath <- find_compressed_file(dir = paste0("../utility/packages_binary/", package, "/windows/"), pkg = pkg)
      
      install.packages(pkgs = filepath,  repos = NULL,
                       type = "source", lib = "../utility/packages/") 
    }
  }
  
}


find_compressed_file <- function(dir, pkg){

  # list possible candidates
  candidates <- list.files(dir,
                           pattern = paste0("^", pkg, "\\.(tgz|zip)$"),
                           full.names = TRUE)
  
  if (length(candidates) == 0) {
    stop("Neither .tgz nor .zip found for package: ", pkg)
  }
  
  # if both happen to exist, take the first
  filepath <- candidates[1]
  filepath
}
