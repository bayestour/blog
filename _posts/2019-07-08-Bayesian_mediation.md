---
layout: post-sidenav
title: "Bayesian mediation을 R과 Python에서 구현하기"
group: "Bayesian Statistics"
author: 박준석
---

지금까지 소벨 테스트와 부트스트랩 방식으로 하는, 단순매개분석에서의 간접효과 추정에 대해 다루었습니다. (참고로 말씀드리자면, 제가 다룬 부트스트랩 방식은 부트스트랩 중에서도 특수한 경우고, 다른 방식의 부트스트랩 추정법들도 많이 있다는 것을 알려드립니다.) 여기서 눈치가 빠른 독자라면, 지금까지 제가 베이지안의 "베" 자도 꺼내지 않았다는 사실을 눈치채셨을 것입니다. 하지만 제가 그냥 지나갈 리가 없지 않겠습니까? 물론 베이지안 방식으로도 매개분석을 할 수 있습니다 [1]. 사실 베이지안 추정은 부트스트랩이라는 별도의 절차를 거쳐야 하는 빈도주의 방식에 비해 간접효과에 대한 신뢰구간을 얻기가 더 쉬운데, 이는 애초에 뭘 하든 샘플링부터 하는 베이지안 추론법의 특성상, 미리 얻어둔 샘플로부터 바로 \\(ab\\) 에 대한 신뢰구간을 얻을 수 있기 때문입니다. 자세한 것은 이따 설명하기로 하고, 일단 예제를 보도록 하겠습니다.

이번에도 다시 iris 데이터를 예제로 사용하도록 하겠습니다. (물론 현실적 의미는 없지만, 여기서의 목적은 일단 어떻게 모델을 핏팅할 것인지 예제를 보여주기 위함이기 때문입니다.) 독립변수는 첫 열인 Sepal.Length, 매개변수는 두 번째 열인 Sepal.Width, 종속변수는 세 변째 열인 Petal.Length인 것으로 가정하겠습니다. 빈도주의 방식으로 단순매개모형을 핏팅하고, \\(ab\\) 에 대한 95% 신뢰구간을 얻는 방법은 이미 지난 시간에 다루었습니다. 사실 베이지안의 경우에도 모형 자체는 완전히 똑같습니다. 다시 말해 다음의 두 회귀식을 핏팅하는 것입니다 (mean-centering이 되었다는 가정 하에):

$$M = aX + e_M, e_M \sim N(0, \sigma_M^2) \cdots (1)$$

$$Y = bM + cX + e_Y, e_M \sim N(0, \sigma_Y^2) \cdots (2)$$

MCMC 등의 방식을 사용하면 \\(a\\)와 \\(b\\)에 대한 샘플은 자연스럽게 나옵니다. 예를 들어 각각 1,000개씩의 샘플을 뽑았다고 해 봅시다. 그러니까 우리가 갖고 있는 것은 \\(\hat{a}^{(1)}, \cdots, \hat{a}^{(1000)}\\) 과 \\(\hat{b}^{(1)}, \cdots, \hat{b}^{(1000)}\\) 입니다. 그러면 생각해 봅시다. 이제 \\(ab\\)에 대한 샘플을 얻고 싶다면 어떻게 하면 될까요? 그렇습니다. 그냥 이 둘을 곱하면 됩니다. 그러면 우리가 얻게 되는 것은 \\(\widehat{ab}^{(1)}, \cdots, \widehat{ab}^{(1000)}\\) 가 되고, 이것의 상/하위 2.5%에 해당하는 값을 끊으면 그게 바로 95% 신용구간 credible interval 이 됩니다. 간단하죠? 샘플링을 할 때 \\(a\\)와 \\(b\\)를 곱한 값만 매번 생성해 주면 되니까요. 아니면 그냥 샘플을 다 얻고 나서 곱해도 됩니다. 뭘 하건 여러분의 선택에 달려 있습니다.

그 전에 일단 모수치들의 사전분포들을 결정해야 하는데, 여기서는 "넓게 퍼진 사전분포" diffuse prior 를 사용하겠습니다. 이것은 분산이 매우 큰 사전분포를 의미하는 것인데, 이런 사전분포는 사후분포에 거의 영향을 미치지는 않지만 완전히 평평하지는 않은, 다시말해 균등사전분포 uniform prior 는 아닌 사전분포를 의미합니다. 구체적으로는 다음과 같습니다:

$$a, b, c \sim N(0, 1000^2)$$

$$\sigma_M^2, \sigma_Y^2 \sim \Gamma(0.001, 0.001)$$

회귀계수들의 사전분포는 0을 중심으로 하고 분산이 \\(1,000^2\\)인 정규분포입니다. 분산이 매우 크기 때문에 사실상 정보가 거의 없다고 해도 무방합니다. 분산들의 사전분포는 감마분포라는 것인데 [2], 이 분포는 양의 값만을 갖는 분포이며, 위에서 사용한 감마사전분포의 기댓값은 1, 분산은 1,000입니다. 따라서 이 분포도 \\(\sigma_M^2\\), \\(\sigma_Y^2\\) 에 대한 아주 약한 사전정보만을 담고 있다고 할 수 있습니다. 자세한 수학적 디테일은 구글링 등을 참조하시기 바랍니다.

이제 모델을 실제로 핏팅해 보겠습니다. 다행히도 제가 베이지안 모델링에 즐겨 사용하는 Stan은 R과 파이썬 모두로 구현돼 있습니다. R에서는 **rstan** 패키지를, 파이썬에서는 **PyStan** 라이브러리를 사용하면 됩니다. 둘 다 별도의 설치가 필요합니다. 코드는 아래와 같습니다:

```r
# R
# install the 'rstan' package before running

library(rstan)

# 데이터 생성

data <- list(N = nrow(iris), 
             X = iris$Sepal.Length - mean(iris$Sepal.Length),
             M = iris$Sepal.Width - mean(iris$Sepal.Width),
             Y = iris$Petal.Length - mean(iris$Petal.Length))

# Stan 코드

model_code <- '

  data {

    int N;
    vector[N] X;
    vector[N] M;
    vector[N] Y;
  }

  parameters {

    real a;
    real b;
    real c;
    real<lower=0> sigma2_M;
    real<lower=0> sigma2_Y;

  }

  transformed parameters {

    real ab;
    real<lower=0> sigma_M;
    real<lower=0> sigma_Y;

    ab = a*b;
    sigma_M = sqrt(sigma2_M);
    sigma_Y = sqrt(sigma2_Y);

  }

  model {

    a ~ normal(0, 1000);
    b ~ normal(0, 1000);
    c ~ normal(0, 1000);
    sigma2_M ~ gamma(.001, .001);
    sigma2_Y ~ gamma(.001, .001);

    M ~ normal(a*X, sigma_M);
    Y ~ normal(b*M + c*X, sigma_Y);
  }

'

# 모델 핏팅하기

fit <- stan(model_code=model_code, data=data, chains=4, iter=500, warmup=250)

# 결과 시각화

traceplot(fit)

# 간접효과 95% 신용구간 작성

ab <- extract(fit, "ab")$ab
quantile(ab, c(.025, .975))
```
```r
2.5%       97.5% 
-0.03297828  0.20286435 
```

```python
# Python
# PyStan 라이브러리를 실행 전에 설치할 것

import numpy as np
import pystan
from sklearn.datasets import load_iris

# 데이터 불러오기

iris = load_iris()

X = iris['data'][:,0]
M = iris['data'][:,1]
Y = iris['data'][:,2]

data = {'N' : len(X), 'X': X-np.mean(X), 'M': M-np.mean(M), 'Y': Y-np.mean(Y)}

# Stan 코드

model_code = """

  data {

    int N;
    vector[N] X;
    vector[N] M;
    vector[N] Y;
  }

  parameters {

    real a;
    real b;
    real c;
    real<lower=0> sigma2_M;
    real<lower=0> sigma2_Y;

  }

  transformed parameters {

    real ab;
    real<lower=0> sigma_M;
    real<lower=0> sigma_Y;

    ab = a*b;
    sigma_M = sqrt(sigma2_M);
    sigma_Y = sqrt(sigma2_Y);

  }

  model {
  
    a ~ normal(0, 1000);
    b ~ normal(0, 1000);
    c ~ normal(0, 1000);
    sigma2_M ~ gamma(.001, .001);
    sigma2_Y ~ gamma(.001, .001);

    M ~ normal(a*X, sigma_M);
    Y ~ normal(b*M + c*X, sigma_Y);
  }

"""

# 모델 핏팅하기

model = pystan.StanModel(model_code=model_code)
fit = model.sampling(data=data, chains=4, iter=500, warmup=250)

# ab의 신용구간 만들기

ab = fit.extract(permuted=True)['ab']
np.quantile(ab, [.025, .975])

# 결과 플롯팅하기

fit.plot()
```
```python
array([-0.0320145 ,  0.20735748])
```

이와 같이 결과를 얻었습니다. 코드를 잘 보시면 **transformed parameters** 블럭에서 제가 \\(ab\\)라는 새로운 파라미터를 생성하는 걸 보실 수 있는데, Stan에서는 이런 식으로 새로운 모수치를 정의하면 그 모수치에 대해서도 매 샘플링 때마다 따로 계산해서 저장해 주는 편리함이 있습니다. (물론 이렇게 하지 않고 그냥 \\(a\\)와 \\(b\\)의 샘플 자체를 이용해도 상관없습니다.) 4개의 체인에서 500개씩의 샘플을 얻은 뒤, 앞의 절반을 버리고 뒤의 절반을 취해서 총 1,000개의 샘플을 얻었습니다. traceplot을 직접 보시면 아시겠지만, 체인은 충분히 수렴한 것으로 보이며, 자세한 설명은 생략하겠습니다. 맨 끝의 두 줄에서는 ab의 샘플을 fit 객체에서 추출하여 아래위로 2.5%에 해당하는 값을 끊습니다. 그 결과 얻은 95% 베이지안 신용구간은 - R의 결과를 참조하면 - [-0.033, 0.203] 입니다. 이 값은 앞의 빈도주의 매개분석에서 얻은 값과 미묘하게 다른데, 이것은 사전분포의 영향입니다. 사전분포를 정의한 부분을 **model** 블록에서 싹 지우시고 다시 돌리면 빈도주의 결과와 거의 같은 결과를 얻을 수 있습니다. 

사족을 하나 달자면, 이 베이지안 신용구간의 해석은 빈도주의 신뢰구간과 해석이 많이 다릅니다. 후자는 단일 신뢰구간에 대해 확률적 해석이 불가능한 반면, 전자에서는 가능합니다. 그러니까 "ab의 참값이 구간 안에 있을 확률은 95%다" 같은 진술을 할 수 있다는 것입니다. 다만 주의할 것은 여기서 "확률"의 정의가 바뀐다는 것입니다. 즉 이 경우 확률은 "믿음의 정도"를 의미하게 됩니다. 이것이 바람직한지는 개별 분석가가 판단할 문제입니다. 저는 여기서 어느 한 쪽이 옳다고 주장하지 않겠습니다.

지금까지 Stan을 이용하여 R과 Python에서 베이지안 방식으로 단순매개모형을 핏팅하고 간접효과를 검증하는 법을 알아보았습니다. 사실 베이지안 통계에서 \\(ab\\)에 대한 구간추정을 하는 것은 어차피 얻어야 하는 \\(a\\)와 \\(b\\)의 샘플을 한 번 더 활용하는 것에 지나지 않기 때문에, 매우 간편합니다. 이런 식으로 원하는 다른 값들도 얼마든지 추정이 가능합니다.

[1] <a href = "https://psycnet.apa.org/record/2009-22665-001">Yuan, Y., & MacKinnon, D. P. (2009). Bayesian mediation analysis. Psychological methods, 14(4), 301-322.</a>

[2] Stan은 감마분포를 shape와 rate로 parametrize 합니다.
