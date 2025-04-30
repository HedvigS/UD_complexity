source("01_requirements.R")

dir <- paste0("../data/")
if(!dir.exists(dir)){
  dir.create(dir)
}

dir <- paste0("../data/UD_zip_files")
if(!dir.exists(dir)){
  dir.create(dir)
}

if(!file.exists("../data/ud-treebanks-v2.14/UD_Abkhaz-AbNC/ab_abnc-ud-test.txt")){

options(timeout = 300) 

  
SH.misc::get_zenodo_dir(url = "https://lindat.mff.cuni.cz/repository/xmlui/handle/11234/1-5502/allzip", 
                        exdir= "../data/UD_zip_files/",drop_dir_level = F)

utils::untar(tarfile =  "../data/UD_zip_files/ud-treebanks-v2.14.tgz", exdir = "../data/")

}

if(283 == list.files("../data/ud-treebanks-v2.14/") %>% length()){
  cat("../data/ud-treebanks-v2.14 contains 283 files, looks good!")
}else{
  warning("../data/ud-treebanks-v2.14 does not contain 283 files, something is wrong!")
  }
