source("01_requirements.R")

control.compute=list(save.memory=T)

fns <- list.files(path = paste0("output/processed_data/", UD_version), pattern = ".tsv", all.files = T, full.names = T)

#looping through one tsv at a time


df_all <- data.frame(feat_name = as.character(), 
                     feat_value = as.character(), 
                     n = as.numeric(), 
                     files = as.character())


for(i in
    1:length(fns)
    ){
  # i <- 4
  fn <- fns[i]
  dir <- basename(fn)  %>% str_replace_all(".tsv", "")
  
  cat(paste0("I'm on ", dir, ". It is number ", i, " out of ", length(fns) ,". The time is ", Sys.time(),".\n"))
  

    #reading in
    df <- read_tsv(fn, show_col_types = F) %>% 
      dplyr::mutate(feats = str_split(feats, "\\|")) %>% 
      tidyr::unnest(cols = c(feats))  %>%
      tidyr::separate(feats, sep = "=", into = c("feat_name", "feat_value"), remove = F) %>% 
      group_by(feat_name, feat_value) %>% 
      summarise(n = n(), .groups = "drop") %>% 
      mutate(files = basename(dir)) 
     
    df_all <- df %>% full_join(df_all, by = join_by(feat_name, feat_value, n, files))  %>%  
     # filter(!is.na(feat_name)) %>% 
      group_by(feat_name, feat_value) %>% 
      summarise(n = sum(n), 
                files = paste0(files, collapse = "; "), .groups = "drop")

    
}
 odd_marking <- read_tsv("all_feat_names_values.tsv")

df_all %>% 
  full_join(odd_marking) %>%
  filter(!is.na(odd)) %>% View()
  write_tsv("all_feat_names_values_counts.tsv")

df_all %>% 
  distinct(feat_name) %>% nrow()