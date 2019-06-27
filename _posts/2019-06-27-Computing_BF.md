[Bayes Factor 쉽게 계산하기: BIC와 BayesFactor 패키지]

Bayes Factor (BF) 에 대해 지난 두 포스팅 (하단 링크 참조) 에서 설명했습니다. 아주 짧게 요약하자면, BF는 두 가설이 각각 가정하는 사전분포에 대한 likelihood의 기댓값들의 비율, 즉 marginal likelihood의 비율이라고 했습니다. 그런데 BF를 실제로 계산하는 것은 때로 꽤 어렵습니다. 특히 데이터가 클 때는 더욱 그렇습니다. MCMC 같은 방법은 데이터가 매우 클 때는 느리고 비효율적입니다. 그런데 이런 시뮬레이션 방법을 할 줄 모르면 아예 BF를 계산하는 걸 시도하는 것조차 어렵죠. 그래서 이 글에서는 좀 더 간단한 방법으로 BF를 계산 또는 근사하는 방법에 대해 설명하겠습니다. (이 방법들은 특별히 베이지안 통계에 트레이닝받지 않은 사람들도 할 수 있습니다.)

첫 번째 방법은 BIC를 사용하는 것입니다. BIC는 marginal log-likelihood에 대한 근삿값 곱하기 -2로 정의되니까, 거꾸로 BIC를 -2로 나누면 marginal log-likelihood에 대한 추정값이 나옵니다. 이 값을 exp() 해 주면 marginal likelihood가 되겠지요? 이 값을 비교하려 하는 두 모형에 대해 계산한 후 나누거나, 아니면 애초에 그냥 marginal log-likelihood의 차를 계산한 후 exp()해 줘도 됩니다. 정리하자면 이렇습니다.

\\( BF_{01} = exp(\frac{BIC_0}{(-2)} - \frac{BIC_1}{(-2)}) \\)

물론 여기서 등호는 정확하지 않고 근삿값입니다. 예제로 R의 ToothGrowth 자료를 사용해 설명하겠습니다. 이 자료는 비타민 C를 쥐들에게 투약 방식(오렌지쥬스/약제), 투약량(0.5/1.0/2.0 mg)을 달리해 주면서 이빨의 성장량(len)을 측정한 자료인데, 여기서 투약 방식 (supp) 이 유의한 차이를 낳는지 확인해 보겠습니다. 물론 여기서 dose는 통제 목적으로 함께 투입되는 공변량 covariate 입니다. 비교할 두 회귀모형은 따라서 다음과 같습니다:

\\( H_0 \\) : len ~ dose
\\( H_1 \\) : len ~ supp + dose

이제 두 회귀모형을 각각 핏팅합니다. R에서 기본적으로 제공하는 lm() 함수만 있어도 충분합니다:

```r

fit0 <- lm(len ~ factor(dose), data=ToothGrowth)
fit1 <- lm(len ~ factor(supp) + factor(dose), data=ToothGrowth)

```

이제 이 두 모형의 BIC를 각각 구해 (-2)로 나눈 후, 그 차를 exp() 하여 BF의 근삿값을 구합니다:

```r
approx_BF <- exp(BIC(fit0)/(-2) - BIC(fit1)/(-2))
approx_BF

[1] 0.009520919

```

\\( BF_{01} \\) 의 값은 0.01 가량입니다. 이것은 분모, 즉 \\( H_1 \\) 의 marginal likelihood가 분자, 즉 \\( H_0 \\) 의 marginal likelihood보다 약 100배 크다는 뜻입니다. 이는 \\(H_1\\)이 가정하는 모형, 즉 len ~ supp + dose 에 대한 강한 지지 증거로 볼 수 있습니다.

두 번째 방법은 R의 BayesFactor 패키지를 직접 쓰는 것입니다. 이 패키지에는 generalTestBF() 라는 함수가 있는데, 이것을 이용하면 각종 베이즈 팩터를 계산할 수 있습니다. 위 모형 비교를 위해서는 다음을 실행하면 됩니다:

```r
data <- ToothGrowth
data$dose <- factor(data$dose)
generalTestBF(len ~ supp + dose, data=data, whichModels = "top")
```

함수 안의 whichModels = "top" 부분은 제가 제공한 full model (len ~ supp + dose) 에서 predictor를 하나씩만 뺀 모형을 full model과 비교하겠다는 의미입니다. 결과는 다음과 같습니다:

```r
Bayes factor top-down analysis
--------------
When effect is omitted from supp + dose , BF is...
[1] Omit dose : 4.351722e-15 ±1.15%
[2] Omit supp : 0.01809158   ±1.15%

Against denominator:
  len ~ supp + dose 
---
Bayes factor type: BFlinearModel, JZS
```

우리가 필요로 하는 것은 두 번째 결과 (Omit supp) 입니다. supp를 공변량에서 제외한 모델과 full model의 BF는 0.018로, 위에서 계산한 값인 0.01과는 다소 차이가 있지만 대략적인 패턴은 비슷합니다. [2] 역시 자료는 supp가 들어간 모형을 그렇지 않은 모형에 비해 50배 가량 지지하므로, 우리는 supp가 유의한 공변량이라 결론내릴 수 있습니다.

BF가 계산하기 썩 쉽진 않지만, 이런 식으로 근사해서 사용할 수 있습니다. 특히 데이터가 아주 큰 경우에 유용한 방식들입니다.

[1] Wagenmakers, E. J. (2007). A practical solution to the pervasive problems ofp values. Psychonomic bulletin & review, 14(5), 779-804.

https://link.springer.com/article/10.3758/BF03194105

[2] 이 차이는 크게 두 군데서 오는데, 첫 번째는 사용된 사전분포가 다르다는 것이고, 두 번째는 여기서 계산된 BF는 근사치가 아니라 정확한 값에 가깝다는 것입니다. 두 값이 많이 벌어지면 어느 쪽이 더 합리적 선택인지 생각을 좀 해 봐야 하겠죠?

지난 포스팅들

Bayes Factor: https://www.facebook.com/fisherinohio/posts/312990499642338?__xts__%5B0%5D=68.ARBzszLgycJ5_WalQU9zzDfhsEK2h_Db5eCYOtM6U33mlUDO0EYHIPMDF5dQTAGgL2kSOgkL7mbcr0URARymlJJo0E8LHV3m8usQ5V7eVo08j-h2H1R3AdiMXLMEUVrvDYZ8rWcjvFXGDYUFFALsvhLWmqDinmjb2lMgJIV-KWgEm-0Yy6iyeKafVCtGVk88moo1cpdeKNPLzLr5jtgW6GXuGhueD7RBlXPh7iENbR50s4MKXrWVJyGBnwWff1Chp0jeQD7PfhvsY2htl3ZQcpWEYnuhOoiNw8GwDnP9IhAA4ryHwU3_Sk_ExEaXcJ9DXQ7Kc__oDsGCmKugato&__tn__=K-R

BIC: https://www.facebook.com/fisherinohio/posts/314469469494441?__tn__=K-R
