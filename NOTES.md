* Total Supply is only 1_000_000_000 not 1_000_000_000 * 10**9. Calling totalSupply returns 1_000_000_000 not * 10**9.

* Contract internally uses 9 decimals but decimals() returns 18, non-ERC20 compliant.

* ChangeMaxTx & MaxWallet should not allow a zero input

* ChangeSwapThreshold seems to fail regardless of input
