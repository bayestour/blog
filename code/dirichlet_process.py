import numpy as np
import scipy as sp
import pandas as pd
import pymc3 as pm
import seaborn

blue, *_ = seaborn.color_palette()

N = 20
K = 30
alpha = 2.0
P0 = sp.stats.norm
beta = sp.stats.beta.rvs(1, alpha, size=(N,K))
w = np.empty_like(beta)
w[:, 0] = beta[:, 0]
w[:, 1:] = beta[:, 1:] * (1-beta[:, :-1]).cumprod(axis=1) # w[i,j] = beta[i,j] * \prod_{l=0}^{j-1} (1-beta[i,l])

omega =  
