
#setting up folders
if(!dir.exists("output")){
  dir.create("output")
}

dir <- paste0("output/processed_data/")
if(!dir.exists(dir)){
  dir.create(dir)
}


dir <- paste0("output/results/")
if(!dir.exists(dir)){
  dir.create(dir)
}

dir <- paste0("output/plots/")
if(!dir.exists(dir)){
  dir.create(dir)
}

dir <- paste0("output/results/correlation_dfs/")
if(!dir.exists(dir)){
  dir.create(dir)
}

dir <- paste0("../data/glottolog")
if(!dir.exists(dir)){
  dir.create(dir)}


dir <- paste0("../data/grambank")
if(!dir.exists(dir)){
  dir.create(dir)}