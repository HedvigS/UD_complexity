source("01_requirements.R")

UD_lgs <- read_tsv("../data/UD_languages.tsv", show_col_types = F)

UD_complexity <- read_tsv("output/sum_dfs/all_sum_df_means.tsv", show_col_types = F) %>% 
  mutate(conllu= basename(fn)) %>% 
  left_join(UD_lgs, by = "conllu")

UD_type_counts <- read_tsv("output/sum_dfs/all_sum_df_counts.tsv", show_col_types = F) %>% 
  mutate(conllu= basename(fn)) %>% 
  left_join(UD_lgs, by = "conllu") %>% 
  dplyr::select(conllu, n_token, n_type, n_unique_lemma, n_sentence, n_feats, fn, glottocode)


gb_complexity <- read_tsv("output/processed_data/grambank_theo_scores.tsv", show_col_types = F) %>% 
  rename(glottocode = Language_ID)

joined <- inner_join(UD_complexity, gb_complexity, by = "glottocode") %>% 
  inner_join(UD_type_counts, by = join_by(fn, conllu, glottocode))

joined %>% 
ggplot(aes(x = mean_morph, y = n_feats_per_token_mean)) +
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

png("output/plots/SPLOM_all.png", width = 30, height = 30, units = "cm", res = 300)
joined %>% 
  dplyr::select(n_feats_per_sent_mean,
                n_feats_per_token_mean,
                n_type,
                n_token, 
                n_feats,
                n_sentence,
                n_unique_lemma, 
                mean_morph,
                Informativity) %>% 
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


  