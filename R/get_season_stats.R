# Extract DOND Season Stats
# https://www.dond.co.uk/deal_or_no_deal_stats.php

# HTML not playing nice, working so far

library(rvest)
library(dplyr)
library(stringr)

season_url <- 'https://www.dond.co.uk/deal_or_no_deal_stats-season-1.php'
season_html <- read_html(season_url)

season_html %>%
  html_nodes('body table td table') %>% 
  html_text()



html_element(html_nodes(season_1_html,"body table tr")) %>%
  html_table()
season_html %>% 
  html_node("body table") %>% 
  html_node("table") %>% 
  html_table()

df <- as.data.frame(html_nodes(season_html,"body table")[3] %>% 
  html_table(fill=TRUE))

