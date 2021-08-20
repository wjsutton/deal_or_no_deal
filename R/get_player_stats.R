# Extract DOND Player Stats
# https://www.dond.co.uk/deal_or_no_deal_stats.php

library(rvest)
library(dplyr)
library(stringr)

get_player_urls <- function(season){
  season_url <- paste0('https://www.dond.co.uk/deal_or_no_deal_stats-season-',season,'.php')
  season_html <- read_html(season_url)
  
  player_stats <- season_html %>%
    html_nodes('body table td table a') %>%
    html_attr("href")
  
  player_stats <- player_stats[grepl('game-stats',player_stats)]
  player_urls <- ifelse(substr(player_stats,1,1)!='/',paste0('https://www.dond.co.uk/',player_stats),paste0('https://www.dond.co.uk',player_stats))
  return(player_urls)
}

season_1 <- get_player_urls(1)
season_2 <- get_player_urls(2)
season_3 <- get_player_urls(3)
season_4 <- get_player_urls(4)
season_5 <- get_player_urls(5)
season_6 <- get_player_urls(6)

all_player_urls <- c(season_1,season_2,season_3,season_4,season_5)
