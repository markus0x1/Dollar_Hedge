# Dollar_Hedge
An simple dapp to hedge exchange rate risk using tokenized interest bearing stablecoins

## Motivation
Stablecoins are a well-known instrument for hedging the volatility of crypto currencies. When  supplied to a lending protocol and they become an attractive alternative to a savings accounts. However, most Stablecoins are demonised in US dollars. This is useful as it allows specialised AMMs such as Curve to trade between them without any wild fluctuations. 
However, US Stablecoins may be unattractive to many people outside the United States. Since their income, expenses and/or tax liabilities are most likely denominated in a currency other than the stablecoin. This creates an exchange rate risk for their savings accounts (which is considered to be the safe part of the household portfolio).  
Even exchange rates between economically developed and large economies are remarkably volatile and can fluctuate widely over several months. For example, the EURO  lost 20% of its value in 2007/2008.
(There are numerous examples of rapid exchange rate movements for small countries. E.g. https://en.wikipedia.org/wiki/Turkish_currency_and_debt_crisis,_2018 or https://en.wikipedia.org/wiki/2018_Argentine_monetary_crisis for sharp declines or a sudden increase https://en.wikipedia.org/wiki/Swiss_franc).
All this makes the latest innovation in DEFI less valuable to people outside the US. 
The entire DEFI sector is still quite small in the global economy, and the US dollar has large network effects. We therefore believe that it is neither feasible nor practical to solve this problem by introducing a large number of alternative stablecoins. Instead, we are creating a risk hedging mechanism.

## Mechanism 
We propose a simple swap mechanism to hedge the currency risk for retail investors using stable USD coins. 
As a first step, the stable coin will be lent through a lending protocol such as Aave or Compound. 
The next step is for the user to wrap the interest-bearing stable coin in our contract. Our platform can be used by two types of market participants. Retail investors mint intEURs - an interest-bearing EUR-stablecoin - via our platform. intEUR can be redeemed on the platform for a fixed amount in EURO. 
Traders mint intEURu. intEURu can be redeemed on the platform at an exchange rate of 1-S_1/S_0, where S_1 and S_0 are the EUR/USD exchange rates at time t=1 and t=0 respectively. 
Traders could be rewarded for the downside risk they take in USD by being paid an interest rate r. Further they gain tokens when the EURO depreciates. In competitive markets, this should bring prices of our service close to the expected change in exchange rates. https://en.wikipedia.org/wiki/Interest_rate_parity 
