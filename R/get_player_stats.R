# Extract DOND Player Stats
# https://www.dond.co.uk/deal_or_no_deal_stats.php
# Creates 'data/player_game_details.csv'

library(rvest)
library(dplyr)
library(stringr)

'%ni%' <- Negate('%in%')

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

get_game_details <- function(player_url){
  player_html <- read_html(player_url)
  
  game_season <- case_when(
    player_url %in% season_1 ~ 1,
    player_url %in% season_2 ~ 2,
    player_url %in% season_3 ~ 3,
    player_url %in% season_4 ~ 4,
    player_url %in% season_5 ~ 5,
    player_url %in% season_6 ~ 6
    )
  
  game_title <- player_html %>% html_nodes('p font strong') %>% html_text()
  game_title <- game_title[length(game_title)]
  game_title <- gsub('Deal or No Deal Game Stats for\n','',game_title)
  game_date <- str_extract(game_title,'(\\d+)\\/(\\d+)\\/(\\d+)')
  game_player <- gsub('(\\d+)\\/(\\d+)\\/(\\d+)','',game_title)
  game_player <- trimws(game_player)
  
  game_tables <- player_html %>% html_nodes('table')
  game_tables <- game_tables[4:10]
  
  for(i in 1:length(game_tables)){
    round_df <- as.data.frame(game_tables[i] %>% html_table(fill = TRUE))
    names(round_df) <- c('Box No.','Amount','Verdict')
    round_df$Round <- i
    
    if(i == 1){
      all_rounds <- round_df
    }
    
    if(i > 1){
      all_rounds <- rbind(all_rounds,round_df)
    }
  }
  
  all_rounds$Player <- game_player
  all_rounds$Date <- game_date
  all_rounds$Season <- game_season
  all_rounds <- filter(all_rounds,all_rounds$Amount != 'Amount')
  
  return(all_rounds)
}

season_1 <- get_player_urls(1)
season_2 <- get_player_urls(2)
season_3 <- get_player_urls(3)
season_4 <- get_player_urls(4)
season_5 <- get_player_urls(5)
season_6 <- get_player_urls(6)

all_player_urls <- c(season_1,season_2,season_3,season_4,season_5)
all_player_urls <- all_player_urls[grepl('php$',all_player_urls)]
all_player_urls <- gsub(' ','%20',all_player_urls)

# Remove broken link 
remove <- c('https://www.dond.co.uk/game-stats/deal_or_no_deal_stats_john_6.php')
all_player_urls <- all_player_urls[all_player_urls %ni% remove]

for(match in 1:length(all_player_urls)){
  player_rounds <- get_game_details(all_player_urls[match])
  
  if(match == 1){
    game_df <- player_rounds
  }
  
  if(match > 1){
    game_df <- rbind(game_df,player_rounds)
  }
  
  if(match %% 50 == 0){
    print(paste0(match,' games parsed'))
  }

  Sys.sleep(1)
}

write.csv(game_df,'data/player_game_details.csv',row.names = F)


