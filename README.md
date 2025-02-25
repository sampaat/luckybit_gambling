# How Bitcoin’s Ups and Downs Are Changing the Way You Bet
Data preparatory and analytical scripts of "How Bitcoin’s Ups and Downs Are Changing the Way You Bet" by Máté Csaba Sándor and Barna Bakó of Corvinus University of Budapest

This script set reproduces the results presented in (**1**)

To run the scripts use R version 4.2.2 (2022-10-31).

## Producing the gambling dataset

The gambling dataset was created using the transactional data extractable from the bitcoin ledger. To make things simpler we have been using a formated dataset from (**2**), available currently at (**3**). To replicate the dataset, use the script *data_preparation_from_blockchain_excrept.R*. Do not run the script as it is, since first you need to download the appropriate datasets from above which takes considerable time. Also there are some variables that need manual adjustment, to avoid overwhelming most desktop computers.

A representative state of the game's website is observable [as a web archive.](https://web.archive.org/web/20150314200358/http://luckyb.it/) (**5**)

**To acces the dataset, click here:** [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.5600259.svg)](https://doi.org/10.5281/zenodo.5600259)

## The prepared gambling dataset

The excrept created, containing all transactions of the LuckyBit platform are featured in *luckybit_bets_usered.csv*

The columns featured in the dataset (names in the first row):

  * *txID*  transaction ID of the bet transaction [integer]
  * *addrID* recieving address ID of the targeted game (see *luckybit_games_addresses.csv* for mapping them to games) [integer]
  * *addrID_in* reciving/initiating address ID of the bet/answer transaction, the ID gathered from the dataset, not resolved to true bitcoin IDs [integer]
  * *value* bet ammount (or wager) measured in satoshis (1 satoshi = 1e-8 BTC) [integer]
  * *block_timestamp* blockchain block timestamp (UTC unixtime) used to time the bets [integer]
  * *userID*  assigned based on addrID_player using the methods and dataset of (**2**) [integer]

## Supporting datasets

### Luckybit addresses

Mapping table containing basic information about the possible LuckyBit games are featured in *luckybit_games_address.csv*

The columns featured in the dataset (names in the first row):

  * *Name*  color based identification of the game as shown in the web archive. [string]
  * *Address* string format of the game's bitcoin address hash [string]
  * *addrID* recieving address ID of the targeted game (see *luckybit_games_addresses.csv* for mapping them to games) [integer]
  * *ExpectedReturn* expected payout of the game on unit bet [float]
  * *HousePercent* expected loss of the game on unit bet [float]
  * *MaxWin* maximum winning multiplier [integer]
  * *WinProb*  total probability of positive total payout (win) [float]
  * *LossProb*  total probability of negative total payout (loss) [float]
  * *FlatProb*  total probability of bet payback (no win or loss) [float]

### Luckybit game table

Mapping table containing multipliers and probabilites of each game are featured *luckybit_games_table.csv*

The columns featured in the dataset (names in the first row):

  * *n*  label of result 1-17 [integer]
  * *blue* multiplier of the n-th outcome for the game blue [float]
  * *green* multiplier of the n-th outcome for the game green [float]
  * *yellow* multiplier of the n-th outcome for the game yellow [float]
  * *red* multiplier of the n-th outcome for the game red [float]
  * *p_win* maximum winning multiplier [float]

### Clustered users table

Mapping table containing the clusterings assigned to each user are featured *clustered_users.csv*

The columns featured in the dataset (names in the first row):

  * *userID*  assigned based on addrID_player using the methods and dataset of (**2**) [integer]
  * *cluster* calculated in *player_clustering.Rmd* as 1 - All players, 2 - Casual, 3 - Regular, 4 - Extreme [integer]

### Clustered users table

Bitcoin to USD exchange rate data featured in *bitcoin_historical_data_coinmarketcap.csv*.

This dataset has been downloaded as of 2024-09-02 from [Coinmarketcap]([https://web.archive.org/web/20150314200358/http://luckyb.it/](https://coinmarketcap.com/currencies/bitcoin/historical-data/))

The columns featured in the dataset (names in the first row):

  * *timeOpen*  market open, datetime UTC [string]
  * *timeClose*  market close, datetime UTC [string]
  * *timeHigh*  timing of daily high, datetime UTC [string]
  * *timeLow*  timing of daily low, datetime UTC [string]
  * *name*  arbitrary ID from Coinmarketcap, uniform, dropable [integer]
  * *open*  daily opening exchange rate (USD/BTC) [float]
  * *high*  highest daily exchange rate (USD/BTC) [float]
  * *low*  lowest daily exchange rate (USD/BTC) [float]
  * *close*  daily closing exchange rate (USD/BTC) [float]
  * *volume*  daily total traded volume (BTC) [float]
  * *marketCap*  total Bitcoin market capitalization in USD [float]
  * *timeStamp*  timing of data recording, datetime UTC [string]

## Replicating research

Use the R workbook *player_clustering.Rmd* to reproduce clustering results presented in (**1**).

Use the R workbook *analysis.Rmd* to reproduce research results presented in (**1**).

With questions about the dataset or the process, contact Máté Sándor (sampaat at gmail dot com).

## References

  1. Bakó, B., Sándor, M.C. (2025). How Bitcoin’s Ups and Downs Are Changing the Way You Bet
  2. Kondor, D., Pósfai, M., Csabai, I., & Vattay, G. (2014). Do the rich get richer? An empirical analysis of the BitCoin transaction network. PLoS ONE, 9(2), e86197. https://doi.org/10.1371/journal.pone.0086197
  3. https://doi.org/10.5061/dryad.qz612jmcf
  4. [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.5600259.svg)](https://doi.org/10.5281/zenodo.5600259)
  5. [https://web.archive.org/web/20150314200358/http://luckyb.it/](https://web.archive.org/web/20150314200358/http://luckyb.it/)
