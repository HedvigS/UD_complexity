

fns <- list.files(path = "output/n_tokens/", full.names = TRUE)
stacked <- SH.misc::stack_delim(fns = fns)

library(tidyverse)

stacked$filename <- fct_reorder(stacked$filename, stacked$n_tokens_whole)
  
stacked %>% 
#  dplyr::filter(n_tokens_whole < 20000) %>%
  ggplot() +
  geom_point(aes(x = filename, y = `n_tokens_whole`), color = "blue", alpha = 0.5) +
  geom_point(aes(x = filename, y = `n_tokens_only_subwords`), color = "red", alpha = 0.5) +
  geom_point(aes(x = filename, y = `n_tokens_multiwords_resolved`), color = "green", alpha = 0.5) +
  geom_hline(yintercept = 13000, linetype = "dashed", color = "black", linewidth = 0.7) +
  geom_hline(yintercept = 500000, linetype = "dashed", color = "black", linewidth = 0.7) +
  geom_hline(yintercept = 1000000, linetype = "dashed", color = "black", linewidth = 0.7)


