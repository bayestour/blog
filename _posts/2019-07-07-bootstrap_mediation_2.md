---
layout: post-sidenav
title: "부트스트랩 매개분석 (2): 구현하기"
group: "Bayesian Statistics"
author: 박준석
---

이제 앞에서 배운 부트스트랩을 매개분석에서 간접효과를 추정하는 데 써 보도록 하겠습니다. 사실 어려울 것은 하나도 없습니다. 요령은 똑같습니다. 다음을 반복하면 됩니다:

1. 데이터셋에서 복원추출로 원래 데이터셋과 같은 크기의 새로운 데이터셋을 추출한다.
2. 뭔가를 데이터셋에서 계산한다.
3. 1-2를 여러 차례 반복한 뒤 결과를 수집한다.
4. 3. 의 결과를 이용하여 점추정치나 신뢰구간을 구한다.
5. Profit!

하나도 어려울 게 없죠? 그래서 오늘도 우리의 친구 iris 데이터셋을 이용하여 부트스트랩 매개분석을 해 보도록 하겠습니다. 저번에 했던 것처럼 첫 번째 열을 X, 두 번째 열을 M, 세 번째 열을 Y라 가정하겠습니다. iris 데이터셋의 크기는 \\(n=150\\) 이므로, 복원추출을 한 번 할 때마다 이 크기의 데이터셋을 만들고, 매개분석에 사용되는 두 회귀식을 핏팅한 다음, \\(ab\\)를 계산하여 저장하는 것을 충분히 반복하면 됩니다. 여기서는 1,000개의 그러한 샘플 - "부트스트랩 샘플" - 을 만들어 보도록 하겠습니다. 그리고 이것을 이용하여 \\(ab\\)의 95% 신뢰구간을 만들어 보겠습니다.

바로 코드를 보겠습니다. R과 파이썬 구현 코드는 각각 다음과 같습니다. 파이썬에서의 구현을 위해서는 scikit-learn의 LinearRegression() 오브젝트를 사용했습니다.

```r
# R

abs <- vector(length=R)

for(i in 1:R){
  ind <- sample(1:nrow(iris), nrow(iris), replace=T)
  d <- iris[ind,]
  abs[i] <- as.numeric(coef(lm(d[,2] ~ d[,1]))[2]*coef(lm(d[,3] ~ d[,1]+d[,2]))[3])

}

ci <- as.vector(quantile(abs, c(.025, .975)))
ci
```
```r
[1] -0.02142053  0.19575008
```
```python
# Python

import numpy as np
import sklearn as sk
from sklearn.datasets import load_iris
from sklearn.linear_model import LinearRegression as LR

iris = load_iris()

def compute_ab(data):
    
    lr1 = LR()
    lr2 = LR()
    
    X = data[:,0].reshape(-1, 1)
    X2 = data[:,[0,1]]
    M = data[:,1].reshape(-1, 1)
    Y = data[:,2].reshape(-1, 1)
    
    fit1 = lr1.fit(X, M)
    fit2 = lr2.fit(X2, Y)
    
    ab = fit1.coef_ * fit2.coef_[0][1]
    
    return ab.tolist()[0]

R = 10000
res = []

for i in range(R):
    
    indices = np.random.choice(iris['data'].shape[0], iris['data'].shape[0], replace=True)
    res.extend(compute_ab(iris['data'][indices,:]))
    
np.quantile(res, [.025, .975])    
```
```python
array([-0.0205294 ,  0.19509562])
```

결과는 거의 비슷하죠? 95% 신뢰구간이 0을 포함하므로, 유의수준 .05에서 \\(H_0\: ab=0\\) 이라는 영가설을 기각할 수 없습니다.

참고로 R의 경우, 부트스트랩을 위한 별도의 패키지 boot 가 존재합니다. 이것을 이용해서 다음과 같이 구현할 수도 있습니다. 특히 이 패키지가 좋은 점은 코드에서 볼 수 있다시피 병렬화가 가능하다는 점입니다. 부트스트랩은 각각의 표본 추출 및 계산 과정이 완전히 독립적이므로, 손쉽게 병렬화할 수 있고, 병렬화하는 만큼 시간을 절약할 수 있습니다:

```r
# R

ab <- function(data, i) {
  d <- data[i,]
  as.numeric(coef(lm(d[,2] ~ d[,1]))[2]*coef(lm(d[,3] ~ d[,1]+d[,2]))[3])
}

temp <- boot(data=iris, statistic=ab, R=R, parallel="multicore")
res_boot <- boot.ci(temp, conf=.95, type='perc')
boot_ci <- res_boot$percent[4:5]
boot_ci
```
```r
[1] -0.01924195  0.19807247
```

앞에서 얻은 결과와 거의 유사합니다. 사실 R에는 또다른(!), 부트스트랩을 포함한 다양한 방식의 매개분석을 위한 별도의 패키지 mediation 이 존재합니다. 이것을 쓸 수도 있습니다:

```r
# R

m1 <- lm(Sepal.Width ~ Sepal.Length, data=iris)
m2 <- lm(Petal.Length ~ Sepal.Length + Sepal.Width, data=iris)

res_mediate <- mediate(m1, m2, sims=R, treat="Sepal.Length", mediator="Sepal.Width",
               boot = T, boot.ci.type = "perc")

mediate_ci <- as.vector(res_mediate$d0.ci)
mediate_ci
```
```r

```

모두 유사한 결과를 산출합니다.

이렇게 R이나 파이썬에서 비교적 간단하게 부트스트랩 방식의 매개분석 간접효과 검증을 할 수 있었습니다. 사실 현업에서는 Preacher & Hayes 가 만든 SPSS Macro를 쓰는 경우가 많은데, 그 작동 원리 자체는 - 디테일은 좀 다르겠지만 - 동일합니다. 여기까지 잘 따라오셨다면, 이제 SPSS로 하시던 업무를 R이나 파이썬으로 대체하는 데 전혀 어려움을 겪지 않으실 것입니다.
