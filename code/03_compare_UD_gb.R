source("01_requirements.R")

UD_lgs <- read_tsv("../data/UD_languages.tsv", show_col_types = F)

ud_complexity <- read_tsv("output/sum_dfs/all_sum_df_means.tsv", show_col_types = F) %>% 
  mutate(conllu= basename(fn)) %>% 
  left_join(UD_lgs)

gb_complexity <- read_tsv("output/processed_data/grambank_theo_scores.tsv", ) %>% 
  rename(glottocode = Language_ID)

joined <- inner_join(ud_complexity, gb_complexity)

joined %>% 
ggplot(aes(x = Informativity, y = n_feats_per_sent_mean)) +
  geom_point() +
  ggpubr::stat_cor(method = "pearson", p.digits = 2, geom = "label", color = "blue",
                   label.y.npc="top", label.x.npc = "left", alpha = 0.8) +
  geom_smooth(method='lm', formula = 'y ~ x') +
  theme_classic()

ggsave("output/plots/gb-ud_scatterplot.png")
  
  
  