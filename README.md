# Dollar_Hedge
A smart way to hedge forex exchange rate risks.

## Motivation
Stablecoins are a well-known instrument for hedging the volatility of crypto currencies. When  supplied to a lending protocol and they become an attractive alternative to a savings accounts. However, most Stablecoins are demonised in US dollars. This is useful as it allows specialised AMMs such as Curve to trade between them without any wild fluctuations. 
However, US Stablecoins may be unattractive to many people outside the United States. Since their income, expenses and/or tax liabilities are most likely denominated in a currency other than the stablecoin. This creates an exchange rate risk for their savings accounts (which is considered to be the safe part of the household portfolio).  
Even exchange rates between economically developed and large economies are remarkably volatile and can fluctuate widely over several months. For example, the EURO  lost 20% of its value in 2007/2008.
(There are numerous examples of rapid exchange rate movements for small countries. E.g. [2018 Turkey](https://en.wikipedia.org/wiki/Turkish_currency_and_debt_crisis,_2018), 
[2018 Argentina](https://en.wikipedia.org/wiki/2018_Argentine_monetary_crisis) for sharp declines or a sudden increase 
[2014 Switzerland](https://en.wikipedia.org/wiki/Swiss_franc). All of this makes the latest DEFI innovation less valuable to people outside the US, as your savings portfolio should not be exposed to such volatility.
The entire DEFI sector is still quite small in the global economy, and the US dollar has large network effects. We therefore believe that it is neither feasible nor practical to solve this problem by introducing a large number of alternative stablecoins. Instead, we are creating a **risk hedging mechanism** for retail investors.

## Brief desription
We propose a simple swap mechanism to hedge the currency risk for retail investors using USD stablecoins. 
As a first step, the stable coin will be lent through a lending protocol such as Aave or Compound. 
The next step is for the user to wrap the interest-bearing stable coin in our contract. We leverage the Aave protocoll to produce interest on the deposits.
Our contract works as a platform to connect two types of market participants. Retail investors buy in to receive interest on their deposits while insuring their deposits against exchange rate movements. More specific: They always receive their initital deposit back *in EURO*. Speculators provide their capital to the pool. They benefit from exchange rate movements in their favour and pay retail investors out if the EURO appreciates in value. They can demand a fee from retail investors for this service. 

## Technical description
Our system has 3 main phases in which the actors can interact with the contract. 
1) In the waiting period, speculators deposit aDai in the contract. 
After some time the contract can be called to start the savings period. 
1)->2). In the request we calculate the initial capital amount and call a price oracle to set the initial exchange rate 
e<sub>0</sub> = &euro;/&#36; 


![Alt](/HTML/diagrams/step_1_2.png)

2) During the savings period, speculators claim two coins against their deposits. For 2 aDai they receive 1 aEURu + 1/e<sub>0</sub> aEURs. aEURu and aEURs are ERC20-tokens and can be traded freely. For example, sepculators can keep their aEURu and sell aEURs to a retail investor.
After some time the contract is called to start the redemption period 2)->3. We calculate the total interest payments claimed in the period as capital<sub>1</sub>-capital<sub>0</sub> and set the final exchange e<sub>1</sub> rate by calling a price oracle again.

3) During the redemption period, owners of both aEURs and aEURu can reclaim their tokens. The total interest payments are distributed to the investors/hedge holders according to their share of the total investment. Further, aEURs holders receive aEURs * e<sub>0</sub> = aDai from the contract. aEURu holders receive 1-&delta;<sub>e</sub> times the number of their tokens, where &delta;<sub>e</sub> = (e<sub>1</sub> - e<sub>0</sub>)/e<sub>0</sub>. Hereby they make a profit, if e<sub>1</sub> < e<sub>0</sub>and must otherwise compensate for the losses of retail investors. E.g. they win money if the euro loses value (euro depreciates & dollar appreciates) and loose money if the euro gains value (euro appreciates & dollar depreciates). 

![Alt](/HTML/diagrams/step_3_4.png)

Steps 1-3) show that aEUR holders use their token to make an interest-bearing deposit whose value is linked to the EURO. 
In this respect aEURs works like a euro savings account.

*Note 1) Speculators can extract rent from the customers by selling aDAIs at a higher price than their recoverable proceeds. In addition, they receive a profit when the EURO loses value. In competitive markets this should bring prices close to the [expected exchange rate change] (https://en.wikipedia.org/wiki/Interest_rate_parity).*

*Note 2) Since we use USD as collateral for payouts for both sides, we set a conservative 50% limit for exchange rate fluctuations up/down.
This ensures that both sides are always paid out.*

*Note 3) We expect speculators to be the more sophisticated users and are able to hedge their positions.*
