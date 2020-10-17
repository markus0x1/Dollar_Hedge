# -*- coding: utf-8 -*-
"""
Created on Tue Oct 13 18:28:16 2020

@author: Markus
"""

import numpy as np


""" parameters"""
n = 10
mu_b = 0.4
mu_s = 0
sigma = 1

""" vectors """
b = mu_b + sigma * np.random.random_sample(n) # buyer bids
s = mu_s + sigma * np.random.random_sample(n) # seller offers

""" sort vectors """
b = np.sort(b)[::-1] # sort in decreasing order
s = np.sort(s) # sort in increasing order

""" find k """
k = max(np.where(b>=s)[0]) # reminder k = k - 1 since python starts counting with 0!

""" average mechansim solution """
p_upper = max(s[k], b[k+1])
p_lower = min(b[k], s[k+1])
pstar_avg = np.mean([p_upper, p_lower])
assert sum(b<=pstar_avg)==sum(s>=pstar_avg), "Both sides must initiate the same number of trades"
n_trade = sum(b<=pstar_avg)
print("The number of share of sucessfull trades is", n_trade/n)


""" McAfee´s mechanism """
pstar_mc = np.mean([b[k+1], s[k+1]])


b[k]>=p>=s[k]

if b[k]>=p>=s[k]:
    p_b = pstar_mc
    p_s = pstar_mc
    n_trade  = sum(b<=pstar_mc) 
    n_buyer_index = np.where(b>=p_b)[0]
    n_seller_index = np.where(s<=p_s)[0]
else:
    p_b = b[k]
    p_s = s[k]
    profit = (k-1)*(p_b-p_s)

