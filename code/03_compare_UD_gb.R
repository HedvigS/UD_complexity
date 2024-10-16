source("01_requirements.R")

UD_complexity <- read_tsv("output/processed_data/df_means_feats_per_token_per_sentence.tsv", show_col_types = F) 

gb_complexity <- read_tsv("output/processed_data/grambank_theo_scores.tsv", show_col_types = F) %>% 
  rename(glottocode = Language_ID)

pop <- read_tsv("../data/linguameta.tsv")

joined <- UD_complexity %>% 
  left_join(gb_complexity) %>% 
  left_join(pop)
  
joined %>% 
ggplot(aes(x = mean, y = Fusion)) +
  geom_point() +
  ggpubr::stat_cor(method = "pearson", p.digits = 2, geom = "label", color = "blue",
                   label.y.npc="top", label.x.npc = "left", alpha = 0.8) +
  geom_smooth(method='lm', formula = 'y ~ x') +
  theme_classic()

ggsave("output/plots/gb-ud_scatterplot.png")



joined %>% 
  ggplot(aes(x = n_feats_per_sent_mean, y = n_feats_per_token_mean)) +
  geom_point() +
  ggpubr::stat_cor(method = "pearson", p.digits = 2, geom = "label", color = "blue",
                   label.y.npc="top", label.x.npc = "left", alpha = 0.8) +
  geom_smooth(method='lm', formula = 'y ~ x') +
  theme_classic()

png("output/plots/SPLOM.png", width = 15, height = 15, units = "cm", res = 300)
joined %>% 
  dplyr::select("UD_feats_per_token\n_per_sentence" = mean,
                GB_Fusion = Fusion, 
                GB_Informativity = Informativity, 
                Google_pop = "estimated_number_of_speakers") %>% 
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


  