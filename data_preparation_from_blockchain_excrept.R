library(tidyverse)
library(sqldf)

#a representative form of the site archived: https://web.archive.org/web/20150314200358/http://luckyb.it/
#the original game has been started at 2013 nov
#the blue game have been introduced at ???
#the website has been shut down at 2021 jan 31

#the below table is excrepted from https://papers.ssrn.com/sol3/papers.cfm?abstract_id=3430334
games_table<- tibble(
  "n" = seq(17),
  "blue" = c(3.0, 1.4, 1.3, 1.2, 1.1, 0.2, 1.1, 1.1, 1.1, 1.1, 1.1, 0.2, 1.1, 1.2, 1.3, 1.4, 3.0),
  "green" = c(22.0, 5.0, 3.0, 2.0, 1.4, 1.2, 1.1, 1.0, 0.4, 1.0, 1.1, 1.2, 1.4, 2.0, 3.0, 5.0, 22.0),
  "yellow" = c(111.0, 38.0, 12.0, 5.0, 3.0, 1.4, 1.0, 0.5, 0.3, 0.5, 1.0, 1.4, 3.0, 5.0, 12.0, 38.0, 111.0),
  "red" = c(999.0, 130.0, 24.0, 9.0, 4.0, 2.0, 0.2, 0.2, 0.2, 0.2, 0.2, 2.0, 4.0, 9.0, 24.0, 130.0, 999.0)
) %>%
  mutate(p_win = dbinom(n-1, size=16, prob=0.5))


games_address <- c(
  "red","1LuckyR1fFHEsXYyx5QK4UFzv3PEAepPMK",
  "yellow","1LuckyY9fRzcJre7aou7ZhWVXktxjjBb9S",
  "green","1LuckyG4tMMZf64j6ea7JhCz7sDpk6vdcS",
  "blue","1LuckyB5VGzdZLZSBZvw8DR17iiFCpST7L"
) %>%
  matrix(ncol = 2, byrow = T, dimnames = list(NULL,c("Name","Address"))) %>%
  as_tibble() %>%
  mutate(ExpectedReturn = map(Name,function(x)sum(games_table$p_win*games_table[x])) %>% unlist()) %>%
  mutate(HousePercent = 1-ExpectedReturn) %>%
  mutate(MaxWin = map(Name,function(x)max(games_table[x])-1) %>% unlist()) %>%
  mutate(MaxLoss = map(Name,function(x)1-min(games_table[x])) %>% unlist()) %>%
  mutate(WinProb = map(Name,function(x)sum(games_table$p_win*(games_table[x]>1))) %>% unlist()) %>%
  mutate(LossProb = map(Name,function(x)sum(games_table$p_win*(games_table[x]<1))) %>% unlist())%>%
  mutate(FlatProb = map(Name,function(x)sum(games_table$p_win*(games_table[x]==1))) %>% unlist())


#is there a minimum or maximum bet implied here?

# input datasets are from Kondor et. al. Do the Rich Get Richer?... https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0086197
# dataset available online at https://datadryad.org/stash/dataset/doi:10.5061/dryad.qz612jmcf
# the datasets used below first need to be downloaded manually, you need the 2013 versions
# eol characters may have to be changed dependent on windows/unix systems used

#get addrIDs connected to the adresses in the game table
luckybit_addrIDs <- read.csv.sql(file = "C:\\Users\\sampa\\Documents\\bce-bitluck\\rawdata\\kondor_to_18\\bitcoin_2018_addresses.dat",
                                 header = F,
                                 eol = "\n",
                                 sep = "\t",
                                 sql = "select * from games_address
                                          left join file on games_address.Address = file.v2"
) %>%
  select(V1,V2) %>%
  rename(addrID = V1, Address = V2)

#get bets placed on the game adresses
#use bitcoin_2013_txout.csv.xz
bet_placed_tx <- read.csv.sql(file = "C:\\Users\\sampa\\Documents\\bce-bitluck\\rawdata\\kondor_to_18\\bitcoin_2018_txout.dat",
                              header = F,
                              eol = "\n",
                              sep = "\t",
                              sql = "select * from luckybit_addrIDs
                              inner join file on luckybit_addrIDs.addrID = file.v3"
) %>%
  select(V1, V3, V4) %>%
  rename(txID = V1, addrID = V3, value = V4)

#adding blockids
bet_placed_blocked_tx <- read.csv.sql("C:\\Users\\sampa\\Documents\\bce-bitluck\\rawdata\\kondor_to_18\\bitcoin_2018_tx.dat",
                                      header = F,
                                      eol = "\n",
                                      sep = "\t",
                                      sql = "select * from bet_placed_tx
                                         inner join file on bet_placed_tx.txID = file.v1"
) %>%
  rename(blockID = V2) %>%
  select(-V1)%>%
  select(-V3)%>%
  select(-V4)

#adding block timestamps
bet_placed_timed_tx <- read.csv.sql("C:\\Users\\sampa\\Documents\\bce-bitluck\\rawdata\\kondor_to_18\\bitcoin_2018_bh.dat",
                                    header = F,
                                    eol = "\n",
                                    sep = "\t",
                                    sql = "select * from bet_placed_blocked_tx
                                         inner join file on bet_placed_blocked_tx.blockID = file.v1"
) %>%
  rename(block_timestamp = V3) %>%
  select(-V1)%>%
  select(-V2)%>%
  select(-V4)

# delete big variables of intermittent steps
rm(bet_placed_tx, bet_placed_blocked_tx)
gc()

#adding incoming transaction of bets
bet_placed_timed_tx_in <- read.csv.sql("C:\\Users\\sampa\\Documents\\bce-bitluck\\rawdata\\kondor_to_18\\bitcoin_2018_txin.dat",
                                       header = F, 
                                       eol = "\n",
                                       sep = "\t", 
                                       sql = "select * from bet_placed_timed_tx
                                   left join (
                                            select V1, min(V5) as V5
                                            from file
                                            group by V1
                                       ) as f on bet_placed_timed_tx.txID = f.V1"
) %>% 
  rename(addrID_in = V5) %>%
  select(-V1)



write.csv(games_table, ".\\data\\luckybit_games_table.csv")
games_address %>%
  left_join(luckybit_addrIDs, by = "Address") %>%
  write.csv(".\\data\\luckybit_games_address.csv")
write.csv(bet_placed_timed_tx_in, ".\\data\\luckybit_bets_nousered.csv")

games_table <- read.csv(".\\data\\luckybit_games_table.csv")
luckybit_addrIDs <- read.csv(".\\data\\luckybit_games_address.csv")
bet_placed_timed_tx_in <- read.csv(".\\data\\luckybit_bets_nousered.csv")


addr_map_test <- read.csv("C:\\Users\\sampa\\Documents\\bce-bitluck\\rawdata\\kondor_to_18\\bitcoin_2018_addr_sccs.dat",
                          header = F,
                          sep = "\t",
                          col.names = paste0("V", seq_len(2)),
                          colClasses = c("integer","integer"))

bet_placed_timed_tx_in_usered <- bet_placed_timed_tx_in %>% left_join(addr_map_test, by = c("addrID_in" = "V1"))


bet_placed_timed_tx_in_usered_tosave <- bet_placed_timed_tx_in_usered %>%
  rename(userID = V2) %>%
  mutate(userID = ifelse(!is.na(userID),userID, paste0(addrID_in,"x")))

write.csv(bet_placed_timed_tx_in_usered_tosave, ".\\data\\luckybit_bets_usered.csv")
