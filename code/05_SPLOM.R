source("01_requirements.R")

gb_complexity <- read_tsv("output/processed_data/grambank_theo_scores.tsv", show_col_types = F) %>% 
  rename(glottocode = Language_ID)

pop <- read_tsv("output/processed_data/google_pop.tsv") %>% 
  mutate(estimated_number_of_speakers_log = log10(Pop+1))

UD <- read_tsv("output/summaries/counts.tsv") %>% 
  full_join(read_tsv("output/summaries/mean_sum_surprisal_per_lemma_morph_split.tsv")) %>% 
  full_join(read_tsv("output/summaries/mean_sum_surprisal_per_UPOS_morph_split.tsv")) %>% 
  full_join(read_tsv("output/summaries/TTR.tsv")) 

joined <- gb_complexity %>% 
  full_join(pop) %>% 
  full_join(UD)

png("output/plots/SPLOM.png", width = 18, height = 18, units = "cm", res = 300)
joined %>% 
  dplyr::select("UD TTR" = TTR,
                "UD mean feats \nper token" = mean_feats_per_token,
                  "UD mean sum \nsurprisal per token\n(given lemma)" = mean_sum_surprisal_morph_split_per_lemma, 
                "GB v1 \nFusion" = Fusion, 
                "GB v1 \nInformativity" = Informativity 
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