---
layout: post-sidenav
title: "회귀분석에서 로그변환의 해석상 주의점"
group: "Bayesian Statistics"
author: 박준석
---

젠센 부등식에 대해 꽤 길게 앞 포스팅에서 다루었습니다. 사실 이 이야기를 한 이유는 이 포스팅에서 하는 이야기를 하기 위함이었습니다. 바로 회귀분석에서의 로그변환에 관한 이야기입니다. 로그변환은 종속변수(또는 반응변수)가 skew된 분포일 때 정규분포에 가깝게 만들기 위한 목적으로 자주 활용되곤 합니다. [1] (사실 유명한 [박스-콕스 변환(Box-Cox transformation)](https://en.wikipedia.org/wiki/Power_transform#Box%E2%80%93Cox_transformation)의 일종이기도 하죠) 그런데 여기에는 생각지도 못한 함정이 숨어있습니다. 그리고 이것은 젠센 부등식과 직접적인 관련이 있습니다.

아이디어는 다음과 같습니다. (엄밀한 증명은 아닙니다) 회귀분석의 일반적인 공식을 떠올려 봅시다:

$$
\mathbb{E}[Y\|X] = X\beta
$$

그런데 여기서 \\(Y\\) 대신 \\(\log(Y)\\)를 쓴다면 다음과 같은 모델을 핏팅하는 것과 같습니다:

$$
\mathbb{E}[\log(Y)|X] = X\beta
$$

그런데 젠센 부등식에 의하면 다음이 성립합니다:

$$
\mathbb{E}[\log(Y)|X] \le \log(\mathbb{E}[Y|X])
$$

양변의 \\(\exp(\cdot)\\) 를 취하면 다음과 같습니다:

$$
\exp(\mathbb{E}[\log(Y)|X]) < \mathbb{E}[Y|X]
$$

이게 무슨 뜻일까요? 조금만 생각해 보면 알 수 있습니다. \\(Y\\)에 대한 기댓값 대신 \\(\log(Y)\\)에 대한 기댓값을 회귀모형을 통해 얻은 다음 그것을 \\(\exp(\cdot)\\) 해서 원래 스케일로 돌려놓아도 참 기댓값과 일치하지 않는다는 것입니다. 그런데 많은 사람들이 실제로 이렇게 합니다. 즉 Y가 정규분포가 아닌 상황에서 로그를 취해 정규분포에 가깝게 만든 다음 회귀식을 핏팅하고, 그로부터 얻어진 예측값을 다시 \\(\exp(\cdot)\\) 하여 fitted value를 구하는 것입니다. 하지만 이렇게 하면 참 기댓값보다 평균적으로 작을 것이라 예측할 수 있다는 것입니다.

실제로 R에서 시뮬레이션을 해 보면 이것이 참이라는 것을 알 수 있습니다. 즉 로그변환을 한 후 핏팅한 회귀식으로부터 얻은 예측치를 다시 \\(\exp(\cdot)\\) 한 것은 \\(Y\\)의 참값보다 대체로 작게 나옵니다:

```r
# Generate some data

n <- 10000
beta <- 2

data <- data.frame(X=rnorm(n, 10, 1))
data$y <- data$X*beta + rnorm(n, 0, 2)

# non-transformed model
model <- lm(y ~ X, data=data)

# log-transformed model
logmodel <- lm(log(y) ~ X, data=data)

# Predictions from non-transformed model
predictions1 <- predict(model, newdata=data)

# Predictions from log-transformed model
predictions2 <- exp(predict(logmodel, newdata=data))

# bias from the ordinary model
mean(predictions1-data$y)
[1] -2.254064e-14

# bias from the log-transformed model
mean(predictions2-data$y)
[1] -0.1029511
```

앞에서 예측했던 것과 같이 로그 모형을 사용해 예측한 값을 다시 \\(\exp(\cdot)\\) 한 값은 \\(Y\\)값에 비해 평균적으로 작습니다. 하지만 변환을 하지 않은 모형을 사용한 예측값은 평균적으로 \\(Y\\)와 일치합니다 (bias가 0입니다).

로그변환을 하는 것의 다른 한 – 사실 더 중요할 수도 있는 – 문제점은 모형의 해석이 바뀐다는 것입니다. \\(Y\\)에만 로그를 취하더라도 지금까지 알아본 바와 같이 더 이상 원 스케일에 대한 모형이 아니게 됩니다. 그런데 흔히 \\(Y\\)뿐 아니라 \\(X\\)에도 로그를 취한 모형을 자주 사용합니다. 이렇게 핏팅된 모형을 원 스케일로 돌리기 위해 양변에 \\(\exp(\cdot)\\) 를 취하면 \\(X\\)와 \\(Y\\)의 관계는 더 이상 “더하기”의 관계가 아니라 “곱하기”의 관계가 됩니다. 즉 회귀모형이 가정하는 additive model이 아닌 multiplicative model이 되는 것입니다. 이런 상황에서 회귀계수의 의미는 일반적인 “\\(X\\)가 1 증가할 때 \\(Y\\)의 증가분에 대한 기댓값” 이 더 이상 아니게 됩니다. 따라서 해석을 달리해야 하는데, 이것이 적절한지는 상황에 따라 다를 수 있습니다.

정리하자면, 회귀분석에서 변수를 변환하는 것은 분포 가정을 만족시키기 위한 목적으로 흔히 활용되지만, 그 결과 unbiasedness가 깨지거나 해석이 곤란해지거나 하는 문제들이 있습니다. 변수 변환은 이런 결과들을 충분히 감안하고 활용해야 하지만 현업에서는 충분히 고려되지 않는 감이 있습니다. 참고문헌은 이런 변수변환의 주의사항들에 대해 언급하고 있습니다.


### 참고문헌

[Pek et al. (2017). Confidence intervals for the mean of non-normal distribution: Transform of not transform. Open Journal of Statistics, 7, 405-421. doi: 10.4236/ojs.2017.73029.](https://www.scirp.org/journal/PaperInformation.aspx?PaperID=76758)


[1] 사실 회귀분석에서 정규분포를 따라야 하는 것은 잔차이지 종속변수 자체가 아닙니다. 이 목적 자체도 정당화되기는 조금 힘듭니다. 하지만 많이 쓰이기 때문에 언급했습니다.
