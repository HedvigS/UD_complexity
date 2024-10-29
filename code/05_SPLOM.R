source("01_requirements.R")

gb_complexity <- read_tsv("output/processed_data/grambank_theo_scores.tsv", show_col_types = F) %>% 
  rename(glottocode = Language_ID)

pop <- read_tsv("output/processed_data/google_pop.tsv") %>% 
  mutate(estimated_number_of_speakers_log = log10(Pop+1))

UD <- read_tsv("output/summaries/counts.tsv") %>% 
  full_join(read_tsv("output/summaries/mean_sum_surprisal_morph_split.tsv")) %>% 
  full_join(read_tsv("output/summaries/TTR.tsv")) 

joined <- gb_complexity %>% 
  full_join(pop) %>% 
  full_join(UD)

png("output/plots/SPLOM.png", width = 15, height = 15, units = "cm", res = 300)
joined %>% 
  dplyr::select(Google_pop_log = "estimated_number_of_speakers_log", 
                GB_Fusion = Fusion, 
                GB_Informativity = Informativity, 
                "UD_TTR" = TTR,
                "mean_sum_\nsurprisal_\nmorph_split" = mean_sum_surprisal_morph_split, 
                "mean_feats_\nper_token" = mean_feats_per_token
                ) %>% 
  pairs.panels(method = "pearson", # correlation method
               hist.col = "#a3afd1",# "#a9d1a3","",""),
               density = TRUE,  # show density plots
               ellipses = F, # show correlation ellipses
               cex.labels= 1,
               #           smoother= T,
               cor=T,
               lm=T,
               ci = T, cex.cor = 0.9,stars = T
  )

x <- dev.off()