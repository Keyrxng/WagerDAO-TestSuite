# WagerDAO-TestSuite

# Requirements
* ```curl -L https://foundry.paradigm.xyz | bash```

## How to run tests
* ```forge test --fork-url https://data-seed-prebsc-1-s1.binance.org:8545/ -vvv```
## How to get coverage 
* ```forge coverage --fork-url https://data-seed-prebsc-1-s1.binance.org:8545/```
## How to get gas reports
* ```forge test --gas-report --fork-url https://data-seed-prebsc-1-s1.binance.org:8545/ -vvv```

## Test Coverage

| File                          | % Lines          | % Statements     | % Branches       | % Funcs         |
|-------------------------------|------------------|------------------|------------------|-----------------|        
| test/FeeDistro.t.sol          | 0.00% (0/11)     | 0.00% (0/11)     | 100.00% (0/0)    | 0.00% (0/1)     |        
| test/mocks/FeeDistributor.sol | 3.85% (1/26)     | 2.70% (1/37)     | 0.00% (0/14)     | 12.50% (1/8)    |        
| test/mocks/Scores.sol         | 90.22% (83/92)   | 91.09% (92/101)  | 62.07% (36/58)   | 72.00% (18/25)  |        
| test/mocks/Treasury.sol       | 97.26% (71/73)   | 96.94% (95/98)   | 50.00% (10/20)   | 100.00% (19/19) |        
| test/mocks/WagerDAO.sol       | 0.00% (0/10)     | 0.00% (0/19)     | 100.00% (0/0)    | 0.00% (0/10)    |        
| test/mocks/WagerPass.sol      | 87.50% (14/16)   | 90.00% (18/20)   | 50.00% (2/4)     | 87.50% (7/8)    |        
| test/mocks/betManager.sol     | 85.79% (157/183) | 86.80% (171/197) | 50.94% (54/106)  | 73.68% (14/19)  |        
| Total                         | 79.32% (326/411) | 78.05% (377/483) | 50.50% (102/202) | 65.56% (59/90)  |

## Test Results
```
Running 1 test for test/setups/initSetup.sol:InitSetup
[PASS] test_InitSetup() (gas: 24119)
Test result: ok. 1 passed; 0 failed; 0 skipped; finished in 2.78s

Running 4 tests for test/Scores.t.sol:ScoresBasicTest
[PASS] test_InitSetup() (gas: 24075)
[PASS] test_cScoresState() (gas: 78915)
[PASS] test_cScores_NoAuth() (gas: 50794)
[PASS] test_cScores_WAuth() (gas: 221306)
Test result: ok. 4 passed; 0 failed; 0 skipped; finished in 2.89s

Running 4 tests for test/WagerPass.t.sol:WagerPassBasicTest
[PASS] test_InitSetup() (gas: 24119)
[PASS] test_cWagerPassState() (gas: 36714)
[PASS] test_cWagerPass_NoAuth() (gas: 83905)
[PASS] test_cWagerPass_WAuth() (gas: 226440)
Test result: ok. 4 passed; 0 failed; 0 skipped; finished in 2.88s

Running 4 tests for test/FeeDistro.t.sol:FeeDistroBasicTest
[PASS] test_InitSetup() (gas: 24097)
[PASS] test_cFeeDistro_NoAuth() (gas: 16185)
[PASS] test_cFeeDistro_State() (gas: 39700)
[PASS] test_cFeeDistro_WAuth() (gas: 35557)
Test result: ok. 4 passed; 0 failed; 0 skipped; finished in 2.90s

Running 4 tests for test/Treasury.t.sol:TreasuryBasicTest
[PASS] test_InitSetup() (gas: 24097)
[PASS] test_cTreasuryState() (gas: 73258)
[PASS] test_cTreasury_NoAuth() (gas: 64065)
[PASS] test_cTreasury_WAuth() (gas: 686900)
Test result: ok. 4 passed; 0 failed; 0 skipped; finished in 2.90s

Running 4 tests for test/betManager.t.sol:BetManagerBasicTest
[PASS] test_InitSetup() (gas: 24097)
[PASS] test_cBetManager_NoAuth() (gas: 54394)
[PASS] test_cBetManager_State() (gas: 77375)
[PASS] test_cBetManager_WAuth() (gas: 1227545)
Test result: ok. 4 passed; 0 failed; 0 skipped; finished in 2.90s

Running 1 test for test/FeeDistro.t.sol:FeeDistroDeepTest
[PASS] test_InitSetup() (gas: 24119)
Test result: ok. 1 passed; 0 failed; 0 skipped; finished in 3.01s

Running 3 tests for test/betManager.t.sol:BetManagerDeepTest
[PASS] test_InitSetup() (gas: 24119)
[PASS] test_cBetManager_DemoRun() (gas: 2559339)
[PASS] test_cWagerPass_ClaimWinnings() (gas: 2930969)
Test result: ok. 3 passed; 0 failed; 0 skipped; finished in 3.00s

Running 2 tests for test/WagerPass.t.sol:WagerPassDeepTest
[PASS] test_InitSetup() (gas: 24119)
[PASS] test_cWagerPass_MultiMint() (gas: 1454947)
Test result: ok. 2 passed; 0 failed; 0 skipped; finished in 3.23s

Running 7 tests for test/Scores.t.sol:ScoresDeepTest
[PASS] test_InitSetup() (gas: 24097)
[PASS] test_cScores_BuyingFees() (gas: 175400)
[PASS] test_cScores_ClosedAutoLiquidity() (gas: 624616)
[PASS] test_cScores_OpenedAutoLiquidity() (gas: 626828)
[PASS] test_cScores_SellingFees() (gas: 152132)
[PASS] test_cScores_SwapforEthWithShares() (gas: 221840)
[PASS] test_cScores_TradingActivity() (gas: 643181)
Test result: ok. 7 passed; 0 failed; 0 skipped; finished in 3.23s

Running 3 tests for test/Treasury.t.sol:TreasuryDeepTest
[PASS] test_InitSetup() (gas: 24097)
[PASS] test_cTreasury_FeeTokensDistro() (gas: 854620)
[PASS] test_cTreasury_NFTFees() (gas: 1801498)
Test result: ok. 3 passed; 0 failed; 0 skipped; finished in 3.54s
```

## Gas Report

| test/mocks/FeeDistributor.sol:NFTBetFeesDistributor contract |                 |       |        |       |         
|
|--------------------------------------------------------------|-----------------|-------|--------|-------|---------|
| Deployment Cost                                              | Deployment Size |       |        |       |         
|
| 620472                                                       | 2772            |       |        |       |         
|
| Function Name                                                | min             | avg   | median | max   | # calls |
| NFTContract                                                  | 2416            | 2416  | 2416   | 2416  | 1       |
| availableForDistribution                                     | 318             | 1651  | 2318   | 2318  | 3       |
| betManager                                                   | 2393            | 2393  | 2393   | 2393  | 1       |
| oneDay                                                       | 2362            | 2362  | 2362   | 2362  | 1       |
| owner                                                        | 2371            | 2371  | 2371   | 2371  | 1       |
| scoreContract                                                | 2350            | 2350  | 2350   | 2350  | 1       |
| setBetManager                                                | 22644           | 22644 | 22644  | 22644 | 37      |
| syncFees                                                     | 685             | 8035  | 685    | 24585 | 10      |
| threeDays                                                    | 2384            | 2384  | 2384   | 2384  | 1       |
| tokenDecimals                                                | 2340            | 2340  | 2340   | 2340  | 1       |
| totalDistributed                                             | 2383            | 2383  | 2383   | 2383  | 1       |


| test/mocks/Scores.sol:Scores contract       |                 |        |        |        |         |
|---------------------------------------------|-----------------|--------|--------|--------|---------|
| Deployment Cost                             | Deployment Size |        |        |        |         |
| 4286877                                     | 11217           |        |        |        |         |
| Function Name                               | min             | avg    | median | max    | # calls |
| _addLiquidity                               | 232532          | 232532 | 232532 | 232532 | 1       |
| _isExcludedFromFee                          | 603             | 2103   | 2603   | 2603   | 4       |
| _swapTokensForEth                           | 334960          | 334960 | 334960 | 334960 | 1       |
| approve(address,uint256)                    | 24723           | 24723  | 24723  | 24723  | 41      |
| approve(address,uint256)(bool)              | 22623           | 24674  | 24723  | 24723  | 43      |
| autoSwapEnabled                             | 366             | 366    | 366    | 366    | 2       |
| balanceOf                                   | 646             | 963    | 646    | 2646   | 170     |
| buyTaxes                                    | 363             | 1363   | 1363   | 2363   | 2       |
| canTransferBeforeLaunch                     | 648             | 1648   | 1648   | 2648   | 2       |
| changeMaxTxAmount                           | 2554            | 3049   | 3049   | 3545   | 2       |
| changeMaxWalletAmount                       | 2532            | 3027   | 3027   | 3523   | 2       |
| changeSwapSettings                          | 2699            | 10552  | 10552  | 18405  | 2       |
| changeTaxes                                 | 853             | 1747   | 1747   | 2641   | 2       |
| changeTreasuryAddress                       | 2650            | 4298   | 4298   | 5947   | 2       |
| decimals                                    | 223             | 223    | 223    | 223    | 1       |
| divider                                     | 2363            | 2363   | 2363   | 2363   | 1       |
| excludeFromFee                              | 2806            | 13871  | 13871  | 24937  | 2       |
| isItLaunched                                | 379             | 1379   | 1379   | 2379   | 2       |
| launch                                      | 1009            | 3801   | 1009   | 19809  | 20      |
| liquidityShare                              | 364             | 1364   | 1364   | 2364   | 2       |
| manualSendToTreasury                        | 2498            | 6536   | 6536   | 10574  | 2       |
| maxTxAmount                                 | 385             | 1885   | 2385   | 2385   | 4       |
| maxWalletAmount                             | 428             | 1928   | 2428   | 2428   | 4       |
| name                                        | 3290            | 3290   | 3290   | 3290   | 1       |
| preLaunchTransfer                           | 2807            | 12872  | 12872  | 22938  | 2       |
| receive                                     | 55              | 55     | 55     | 55     | 6       |
| sellTaxes                                   | 405             | 1405   | 1405   | 2405   | 2       |
| setTreasury                                 | 20695           | 20695  | 20695  | 20695  | 37      |
| setUniPair                                  | 4841            | 4841   | 4841   | 4841   | 1       |
| swapAndAddLiquidity                         | 568613          | 568613 | 568613 | 568613 | 1       |
| swapThrehold                                | 385             | 1385   | 1385   | 2385   | 2       |
| symbol                                      | 3245            | 3245   | 3245   | 3245   | 1       |
| totalSupply                                 | 2405            | 2405   | 2405   | 2405   | 1       |
| transfer                                    | 3184            | 16913  | 23879  | 47861  | 144     |
| transferFrom(address,address,uint256)       | 4481            | 33624  | 19436  | 261421 | 48      |
| transferFrom(address,address,uint256)(bool) | 4481            | 26087  | 29591  | 36789  | 26      |
| treasuryAddress                             | 448             | 1448   | 1448   | 2448   | 2       |
| treasuryShare                               | 406             | 1406   | 1406   | 2406   | 2       |
| uniswapV2Pair                               | 471             | 471    | 471    | 471    | 39      |
| uniswapV2Router                             | 439             | 439    | 439    | 439    | 1       |
| updatePair                                  | 2629            | 3207   | 3207   | 3785   | 2       |
| withdrawETH                                 | 2476            | 4885   | 4885   | 7294   | 2       |


| test/mocks/Treasury.sol:WagerDAOTreasury contract |                 |        |        |        |         |        
|---------------------------------------------------|-----------------|--------|--------|--------|---------|        
| Deployment Cost                                   | Deployment Size |        |        |        |         |        
| 1790430                                           | 8128            |        |        |        |         |        
| Function Name                                     | min             | avg    | median | max    | # calls |        
| NFTContract                                       | 450             | 1450   | 1450   | 2450   | 2       |        
| _swapScoreTokensForEth                            | 2700            | 68111  | 68111  | 133522 | 2       |        
| addAdministrator                                  | 2824            | 14940  | 14940  | 27057  | 2       |        
| addTeamMember                                     | 2736            | 23728  | 23728  | 44720  | 2       |        
| changeSwapRouterAddress                           | 2757            | 3215   | 3215   | 3674   | 2       |        
| checkTokenBalances                                | 5972            | 5972   | 5972   | 5972   | 1       |        
| distributeETHfeeTokens                            | 143894          | 143894 | 143894 | 143894 | 1       |        
| distributeFeeTokens                               | 159718          | 176118 | 176118 | 192518 | 2       |        
| isAdministrator                                   | 597             | 597    | 597    | 597    | 1       |        
| owner                                             | 2405            | 2405   | 2405   | 2405   | 1       |        
| payToMarketingPartnerWithETH                      | 3094            | 86351  | 86351  | 169608 | 2       |        
| payToMarketingPartnerWithScore                    | 3116            | 71371  | 71371  | 139627 | 2       |        
| receive                                           | 55              | 55     | 55     | 55     | 22      |        
| receiver                                          | 425             | 1425   | 1425   | 2425   | 2       |        
| removeTeamMember                                  | 2759            | 3465   | 3465   | 4172   | 2       |        
| routerAddress                                     | 383             | 1383   | 1383   | 2383   | 2       |        
| scoreToken                                        | 427             | 1427   | 1427   | 2427   | 2       |        
| setNftContract                                    | 2735            | 4264   | 4264   | 5793   | 2       |        
| setScoreContract                                  | 2779            | 3308   | 3308   | 3837   | 2       |        
| setSwapReceiver                                   | 2736            | 3194   | 3194   | 3653   | 2       |        
| swapAnyTokenForEth                                | 2779            | 40895  | 40895  | 79012  | 2       |        
| teamMembers                                       | 658             | 1450   | 658    | 4658   | 53      |        
| teamShare                                         | 2361            | 2361   | 2361   | 2361   | 1       |        
| totalEthSpentForMarketing                         | 2407            | 2407   | 2407   | 2407   | 1       |        
| totalInfluencersPaid                              | 2385            | 2385   | 2385   | 2385   | 1       |        
| totalScoreSpentForMarketing                       | 2406            | 2406   | 2406   | 2406   | 1       |        
| totalTeamETHPaid                                  | 363             | 1363   | 1363   | 2363   | 2       |        
| totalTeamMembers                                  | 393             | 393    | 393    | 393    | 1       |        
| totalTeamScorePaid                                | 384             | 1050   | 384    | 2384   | 3       |        
| withdrawAnyToken                                  | 2801            | 3888   | 3888   | 4976   | 2       |        
| withdrawETH                                       | 2621            | 5065   | 5065   | 7510   | 2       |        
| withdrawScoreToken                                | 2643            | 3825   | 3825   | 5008   | 2       |        


| test/mocks/WagerPass.sol:Wager_DAO_NFT contract |                 |        |        |        |         |
|-------------------------------------------------|-----------------|--------|--------|--------|---------|
| Deployment Cost                                 | Deployment Size |        |        |        |         |
| 2095566                                         | 10561           |        |        |        |         |
| Function Name                                   | min             | avg    | median | max    | # calls |
| MINTER_ROLE                                     | 306             | 306    | 306    | 306    | 1       |
| balanceOf                                       | 679             | 679    | 679    | 679    | 1       |
| hasRole                                         | 2699            | 2699   | 2699   | 2699   | 1       |
| name                                            | 3330            | 3330   | 3330   | 3330   | 1       |
| price                                           | 384             | 1384   | 1384   | 2384   | 2       |
| safeMint                                        | 0               | 144981 | 147271 | 181671 | 21      |
| setTreasury                                     | 3866            | 22463  | 22966  | 22966  | 38      |
| supportsInterface                               | 912             | 912    | 912    | 912    | 1       |
| symbol                                          | 3306            | 3306   | 3306   | 3306   | 1       |
| tokenOfOwnerByIndex                             | 1020            | 1020   | 1020   | 1020   | 9       |
| tokenURI                                        | 1837            | 1837   | 1837   | 1837   | 1       |
| totalSupply                                     | 371             | 1371   | 1371   | 2371   | 2       |
| treasury                                        | 383             | 1383   | 1383   | 2383   | 2       |
| updateMintPrice                                 | 5749            | 18972  | 18972  | 32196  | 2       |
| updateUri                                       | 8467            | 20539  | 20539  | 32612  | 2       |
| uri                                             | 3319            | 3319   | 3319   | 3319   | 1       |


| test/mocks/betManager.sol:betManager_V01 contract |                 |        |        |        |         |
|---------------------------------------------------|-----------------|--------|--------|--------|---------|        
| Deployment Cost                                   | Deployment Size |        |        |        |         |        
| 2891801                                           | 13061           |        |        |        |         |        
| Function Name                                     | min             | avg    | median | max    | # calls |        
| _owner                                            | 2471            | 2471   | 2471   | 2471   | 1       |        
| addAdministrator                                  | 2845            | 14961  | 14961  | 27078  | 2       |        
| allowBets                                         | 2672            | 19424  | 22912  | 25712  | 5       |        
| bettingAllowed                                    | 439             | 439    | 439    | 439    | 1       |        
| bettingLaunchedAt                                 | 2417            | 2417   | 2417   | 2417   | 1       |        
| changeFees                                        | 2633            | 6594   | 6594   | 10556  | 2       |        
| changeScoreContract                               | 2691            | 3220   | 3220   | 3749   | 2       |        
| claimWinning                                      | 3810            | 62610  | 73143  | 185490 | 18      |        
| contractBalances                                  | 2419            | 2419   | 2419   | 2419   | 1       |        
| contractFees                                      | 2329            | 2329   | 2329   | 2329   | 1       |        
| createBet                                         | 167180          | 209357 | 201057 | 335280 | 22      |        
| createMatch                                       | 3467            | 96055  | 96554  | 118454 | 11      |        
| currentEpoch                                      | 2373            | 2373   | 2373   | 2373   | 1       |        
| declareMatchOutcome                               | 2697            | 48917  | 50488  | 83710  | 8       |        
| deployer                                          | 2426            | 2426   | 2426   | 2426   | 1       |        
| devWallet                                         | 2470            | 2470   | 2470   | 2470   | 1       |        
| divider                                           | 2396            | 2396   | 2396   | 2396   | 1       |        
| feesToDevelopment                                 | 2374            | 2374   | 2374   | 2374   | 1       |        
| feesToTeam                                        | 2351            | 2351   | 2351   | 2351   | 1       |        
| feesToTreasury                                    | 2328            | 2328   | 2328   | 2328   | 1       |        
| manageWalletsAndProportions                       | 3046            | 17140  | 17140  | 31235  | 2       |        
| multiplier                                        | 2397            | 2397   | 2397   | 2397   | 1       |        
| nftFeeDistributor                                 | 2383            | 2383   | 2383   | 2383   | 1       |        
| nftRewardFee                                      | 2353            | 2353   | 2353   | 2353   | 1       |        
| oneDay                                            | 2374            | 2374   | 2374   | 2374   | 1       |        
| refundMultipleBets                                | 2698            | 33906  | 33906  | 65114  | 2       |        
| refundUserBet                                     | 2609            | 14924  | 14924  | 27240  | 2       |        
| rescueStuckFees                                   | 2575            | 11127  | 11127  | 19680  | 2       |        
| scoreContract                                     | 2428            | 2428   | 2428   | 2428   | 1       |        
| setMatchVariables                                 | 2654            | 4141   | 4141   | 5629   | 2       |        
| setNftFeesDistributor                             | 2692            | 4221   | 4221   | 5750   | 2       |        
| teamWallet                                        | 2404            | 2404   | 2404   | 2404   | 1       |        
| timeToDeclareResult                               | 2352            | 2352   | 2352   | 2352   | 1       |        
| totalBets                                         | 2373            | 2373   | 2373   | 2373   | 1       |        
| totalBetsCreated                                  | 2417            | 2417   | 2417   | 2417   | 1       |        
| treasuryWallet                                    | 2405            | 2405   | 2405   | 2405   | 1       |        
| withdrawFee                                       | 2350            | 2350   | 2350   | 2350   | 1       |