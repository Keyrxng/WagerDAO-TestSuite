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

| File                      | % Lines          | % Statements     | % Branches       | % Funcs         |
|---------------------------|------------------|------------------|------------------|-----------------|   
| test/mocks/Scores.sol     | 80.11% (141/176) | 80.61% (158/196) | 57.29% (55/96)   | 81.25% (39/48)  |
| test/mocks/Treasury.sol   | 100.00% (40/40)  | 100.00% (49/49)  | 50.00% (3/6)     | 100.00% (12/12) |
| test/mocks/WagerDAO.sol   | 0.00% (0/10)     | 0.00% (0/19)     | 100.00% (0/0)    | 0.00% (0/10)    |
| test/mocks/WagerPass.sol  | 100.00% (23/23)  | 100.00% (32/32)  | 75.00% (6/8)     | 100.00% (13/13) |
| test/mocks/betManager.sol | 78.41% (138/176) | 79.26% (149/188) | 45.10% (46/102)  | 77.78% (14/18)  |   
| Total                     | 72.00% (342/475) | 72.39% (388/536) | 50.00% (110/220) | 75.73% (78/103) | 

## Test Results
```
Running 6 tests for test/Scores.t.sol:ScoresTest
[PASS] testFail_TradingMaxTxAmount() (gas: 231953)
Logs:
  User1 balance before trade:  700000000000000000
  Max transaction:  10000001000000000
  Error: Assertion Failed

[PASS] test_AutoSwapMemberFees() (gas: 609866)
[PASS] test_PostLaunch() (gas: 37626)
[PASS] test_TradingBuyFees() (gas: 178352)
[PASS] test_TradingSellFees() (gas: 199550)
[PASS] test_TradingWorks() (gas: 237965)
Test result: ok. 6 passed; 0 failed; 0 skipped; finished in 3.85s

Running 12 tests for test/setups/baseSetup.sol:BaseSetup
[PASS] test_Treasury_NoAuth() (gas: 42337)
[PASS] test_cBetManagerState() (gas: 33177)
[PASS] test_cBetManager_NoAuth() (gas: 58310)
[PASS] test_cBetManager_WAuth() (gas: 1486865)
[PASS] test_cScoresState() (gas: 49498)
[PASS] test_cScores_NoAuth() (gas: 124822)
[PASS] test_cScores_WAuth() (gas: 137371)
[PASS] test_cTreasuryState() (gas: 32501)
[PASS] test_cTreasury_WAuth() (gas: 519911)
[PASS] test_cWagerPassState() (gas: 46840)
[PASS] test_cWagerPass_NoAuth() (gas: 301439)
[PASS] test_cWagerPass_WAuth() (gas: 230623)
Test result: ok. 12 passed; 0 failed; 0 skipped; finished in 3.96s
Ran 2 test suites: 18 tests passed, 0 failed, 0 skipped (18 total tests)
```

## Gas Report

| test/mocks/Scores.sol:Scores contract       |                 |       |        |        |         |
|---------------------------------------------|-----------------|-------|--------|--------|---------|
| Deployment Cost                             | Deployment Size |       |        |        |         |
| 4548255                                     | 11895           |       |        |        |         |
| Function Name                               | min             | avg   | median | max    | # calls |
| approve(address,uint256)                    | 2723            | 15664 | 24723  | 24723  | 17      |
| approve(address,uint256)(bool)              | 2723            | 14639 | 24723  | 24723  | 24      |
| balanceOf                                   | 689             | 1072  | 689    | 2689   | 73      |
| changeMaxTxAmount                           | 2597            | 4080  | 4080   | 5564   | 2       |
| changeMaxWalletAmount                       | 2576            | 3059  | 3059   | 3543   | 2       |
| changeMemberAddress                         | 799             | 6521  | 6521   | 12243  | 2       |
| changeSwapSettings                          | 2676            | 9517  | 9517   | 16358  | 2       |
| changeTaxes                                 | 851             | 1757  | 1757   | 2663   | 2       |
| changeTreasuryWallet                        | 2695            | 4261  | 4261   | 5827   | 2       |
| currentLimits                               | 475             | 3141  | 4475   | 4475   | 3       |
| currentSwapSettings                         | 8750            | 8750  | 8750   | 8750   | 1       |
| currentTaxes                                | 507             | 3173  | 4507   | 4507   | 3       |
| currentTreasury                             | 2377            | 2377  | 2377   | 2377   | 1       |
| decimals                                    | 245             | 245   | 245    | 245    | 1       |
| excludeFromFee                              | 2784            | 12837 | 12837  | 22891  | 2       |
| isItLaunched                                | 379             | 1379  | 1379   | 2379   | 2       |
| launch                                      | 555             | 2277  | 555    | 7355   | 9       |
| manualSendToTreasury                        | 2498            | 4978  | 4978   | 7458   | 2       |
| maxTxAmount                                 | 407             | 1407  | 1407   | 2407   | 2       |
| member2                                     | 447             | 1447  | 1447   | 2447   | 2       |
| member3                                     | 405             | 1405  | 1405   | 2405   | 2       |
| member4                                     | 383             | 1383  | 1383   | 2383   | 2       |
| member5                                     | 405             | 1405  | 1405   | 2405   | 2       |
| member6                                     | 450             | 1450  | 1450   | 2450   | 2       |
| name                                        | 3268            | 3268  | 3268   | 3268   | 1       |
| owner                                       | 2465            | 2465  | 2465   | 2465   | 1       |
| postLaunch                                  | 2520            | 8590  | 8425   | 14825  | 3       |
| preLaunchTransfer                           | 2696            | 12749 | 12749  | 22803  | 2       |
| receive                                     | 55              | 55    | 55     | 55     | 1       |
| symbol                                      | 3244            | 3244  | 3244   | 3244   | 1       |
| totalSupply                                 | 393             | 1393  | 1393   | 2393   | 2       |
| transfer                                    | 3305            | 21610 | 16293  | 69221  | 16      |
| transferFrom(address,address,uint256)       | 4837            | 24981 | 29721  | 46224  | 14      |
| transferFrom(address,address,uint256)(bool) | 5573            | 44899 | 29721  | 337726 | 17      |
| updatePair                                  | 2695            | 5261  | 5261   | 7827   | 2       |
| withdrawETH                                 | 547             | 1500  | 1500   | 2453   | 2       |


| test/mocks/Treasury.sol:WagerDAOTreasury contract |                 |       |        |        |         |
|---------------------------------------------------|-----------------|-------|--------|--------|---------|
| Deployment Cost                                   | Deployment Size |       |        |        |         |
| 1193470                                           | 5551            |       |        |        |         |
| Function Name                                     | min             | avg   | median | max    | # calls |
| _swapScoreTokensForEth                            | 2471            | 59029 | 59029  | 115588 | 2       |
| addAdministrator                                  | 23159           | 23159 | 23159  | 23159  | 1       |
| checkTokenBalances                                | 5942            | 5942  | 5942   | 5942   | 1       |
| isAdministrator                                   | 2556            | 2556  | 2556   | 2556   | 2       |
| payToMarketingPartnerWithETH                      | 2961            | 86364 | 86364  | 169768 | 2       |
| payToMarketingPartnerWithScore                    | 2983            | 71465 | 71465  | 139948 | 2       |
| receive                                           | 55              | 55    | 55     | 55     | 1       |
| setScoreToken                                     | 977             | 1124  | 977    | 3777   | 19      |
| setSwapReceiver                                   | 2545            | 3150  | 3150   | 3755   | 2       |
| swapAnyTokenForEth                                | 2589            | 2589  | 2589   | 2589   | 1       |
| totalEthSpentForMarketing                         | 2340            | 2340  | 2340   | 2340   | 1       |
| totalInfluencersPaid                              | 2385            | 2385  | 2385   | 2385   | 1       |
| totalScoreSpentForMarketing                       | 2383            | 2383  | 2383   | 2383   | 1       |
| withdrawAnyToken                                  | 2523            | 7232  | 7232   | 11942  | 2       |
| withdrawETH                                       | 2414            | 5005  | 5005   | 7596   | 2       |
| withdrawScoreToken                                | 2370            | 3775  | 3775   | 5180   | 2       |


| test/mocks/WagerPass.sol:WagerPass contract |                 |       |        |       |         |
|---------------------------------------------|-----------------|-------|--------|-------|---------|
| Deployment Cost                             | Deployment Size |       |        |       |         |
| 2293652                                     | 11358           |       |        |       |         |
| Function Name                               | min             | avg   | median | max   | # calls |
| MINTER_ROLE                                 | 239             | 239   | 239    | 239   | 1       |
| STAFF_ROLE                                  | 362             | 362   | 362    | 362   | 1       |
| WHITELIST_ROLE                              | 263             | 263   | 263    | 263   | 1       |
| currentFunds                                | 306             | 306   | 306    | 306   | 1       |
| currentPrice                                | 469             | 469   | 469    | 469   | 2       |
| maxPerAddress                               | 610             | 1260  | 610    | 2560  | 3       |
| maxPerTX                                    | 633             | 1283  | 633    | 2583  | 3       |
| maxSupply                                   | 2463            | 2463  | 2463   | 2463  | 2       |
| maxWhitelistedAddresses                     | 2447            | 2447  | 2447   | 2447  | 1       |
| mint                                        | 10060           | 32471 | 32471  | 54883 | 2       |
| mintPrice                                   | 2506            | 2506  | 2506   | 2506  | 2       |
| numAddressesWhitelisted                     | 436             | 436   | 436    | 436   | 1       |
| safeMint                                    | 32364           | 53527 | 53527  | 74691 | 2       |
| setPause                                    | 32340           | 32340 | 32340  | 32340 | 1       |
| setPresale                                  | 32362           | 32362 | 32362  | 32362 | 1       |
| setPrice                                    | 12831           | 22595 | 22595  | 32359 | 2       |
| setPublic                                   | 32362           | 32362 | 32362  | 32362 | 1       |
| setTreasuryWallet                           | 7801            | 20038 | 20038  | 32275 | 2       |
| setWhitelist                                | 32976           | 44758 | 44758  | 56541 | 2       |
| totalSupply                                 | 2376            | 2376  | 2376   | 2376  | 1       |
| wagerPassURI                                | 3366            | 3366  | 3366   | 3366  | 1       |
| withdraw                                    | 5348            | 21258 | 21258  | 37169 | 2       |


| test/mocks/betManager.sol:betManagerV04 contract |                 |        |        |        |         |
|--------------------------------------------------|-----------------|--------|--------|--------|---------|
| Deployment Cost                                  | Deployment Size |        |        |        |         |
| 2544458                                          | 11460           |        |        |        |         |
| Function Name                                    | min             | avg    | median | max    | # calls |
| addAdministrator                                 | 2778            | 14894  | 14894  | 27011  | 2       |
| allowBets                                        | 2760            | 14280  | 14280  | 25800  | 2       |
| changeFees                                       | 2587            | 2975   | 2975   | 3364   | 2       |
| changeScoreContract                              | 2735            | 3193   | 3193   | 3652   | 2       |
| claimWinning                                     | 3334            | 57216  | 57216  | 111098 | 2       |
| contractBalances                                 | 2308            | 2308   | 2308   | 2308   | 1       |
| createBet                                        | 167505          | 209470 | 189385 | 333551 | 5       |
| createMatch                                      | 3488            | 60981  | 60981  | 118475 | 2       |
| declareMatchOutcome                              | 2675            | 23270  | 23270  | 43865  | 2       |
| getFee                                           | 2392            | 2392   | 2392   | 2392   | 1       |
| manageWalletsAndProportions                      | 3024            | 10968  | 10968  | 18913  | 2       |
| refundMultipleBets                               | 1567            | 2110   | 2110   | 2654   | 2       |
| refundUserBet                                    | 750             | 9063   | 2586   | 23853  | 3       |
| rescueStuckFees                                  | 2553            | 5181   | 5181   | 7810   | 2       |
| setMatchVariables                                | 2610            | 3047   | 3047   | 3485   | 2       |
| totalBets                                        | 2329            | 2329   | 2329   | 2329   | 1       |
| totalBetsCreated                                 | 2373            | 2373   | 2373   | 2373   | 1       |
| totalUserBets                                    | 2640            | 2640   | 2640   | 2640   | 2       |
| totalUserWinnings                                | 2553            | 2553   | 2553   | 2553   | 2       |