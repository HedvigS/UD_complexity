
#function to check if a pkg is installed or not, if not it installs it and either way it's loaded.
#inspired by pacman::p_load()

h_load <- function(pkg, 
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
        
        if(version == installed_pkgs[pkg,"Version"]){
          
          if(verbose == T){
            cat(paste0("Package ", pkg," already installed with requested version (", version,").\n"))
            }
        }else{
          
          if(verbose == T){
            cat(paste0("Package ", pkg," already installed but not with requested version (", version,"). Removing existing and reinstalling.\n"))
          }
          remove.packages(pkgs = pkg, lib = lib)
          remotes::install_version(package  = pkg, version = version, lib = lib, dependencies = dependencies, repos = repos,
                                    upgrade = upgrade)
        }
        }
      }
      
      #version end

    if(verbose == T){
      library(pkg, character.only = T, quietly = F, lib.loc = lib)
      cat(paste0("Loaded ", pkg, ", version ",packageVersion(pkg),".\n"))
    }else{
      suppressMessages(library(pkg, character.only = T, quietly = T, verbose = F, warn.conflicts = F, lib.loc = lib))}
}
