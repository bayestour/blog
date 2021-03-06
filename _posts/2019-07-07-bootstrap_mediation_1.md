---
layout: post-sidenav
title: "부트스트랩 매개분석 (1): 수학 없이 시뮬레이션으로 추정하는 통계적 마법"
group: "Bayesian Statistics"
author: 박준석
---

지난 몇 차례의 글을 통해 소벨 테스트에 대해 다루었습니다. 다시 정리하자면, 소벨 테스트의 핵심은 경로계수의 곱 \\(ab\\)에 대한 추정치 \\(\hat{a}\hat{b}\\)의 정규성을 가정한 뒤, \\(a\\)와 \\(b\\) 각자의 점추정치와 그 분산을 이용하여 \\(\hat{a}\hat{b}\\)에 대한 표준오차를 계산하는 것이었습니다. 이렇게 계산된 점추정치와 표준오차는 95% 신뢰구간을 만드는 데 사용할 수 있으며, 그것이 0을 포함하는지 아닌지를 봄으로써 간접효과가 유의한지 통계적으로 검정한다고 말했습니다.

하지만 이런 근사는 아주 큰 표본에서나 어느 정도 유의하게 작동하고, 작은 표본에서는 크게 빗나갑니다. 사실 정규분포를 따르는 두 변수의 곱은 정규분포를 따르지 않습니다. 실제로 R이나 파이썬 등의 소프트웨어를 사용해서 시뮬레이션을 해 보면, 정규분포를 따르는 두 변수의 곱의 분포는 정규분포에 비해 상당히 뾰족해 보입니다. 설령 샘플 사이즈가 상당히 크더라도요. 그래서 소벨 테스트에서 표준오차를 구하기 위해 사용하는 근사는 사실 상당히 부정확합니다.

그러면 이런 상황에서 어떻게 해야 할까요? 요즘 가장 인기있는 대안은 <a href="https://projecteuclid.org/download/pdf_1/euclid.aos/1176344552">통계학 대가 Bradley Efron이 지난 1979년에 제안한 부트스트랩 bootstrap</a> 을 이용하는 것입니다. 부트스트랩은 신뢰구간에 대한 수학적 해법을 찾기 힘들 때 아주 광범위하게 사용되는 기법으로, 제안 당시 일대 혁명을 가져왔다고 합니다. 그 위력을 여러분도 곧 느끼실 수 있을겁니다.

부트스트랩의 아이디어는 사실 매우 간단합니다. 95% 신뢰구간이라는 것의 정의를 다시 한 번 상기해 봅시다. 우리가 모집단으로부터 랜덤 샘플링을 계속 반복해서 어떤 값 - 이를테면 표본평균 - 을 계산할 때, 어떤 방식으로 계산한 구간이 95%의 비율로 참값을 포함하게 만든 게 신뢰구간의 정의였죠? 그런데 우리가 실제로 가지고 있는 것은 모집단 전체가 아니라 어떤 특정한 자료입니다.

부트스트랩의 신박한 아이디어는 바로 지금부터입니다. 우리가 갖고 있는 데이터를 '작은 모집단'이라고 생각합시다. 그러면 신뢰구간은 어떻게 계산하면 될까요? 우리가 앞의 사고실험에서 했듯, 이 작은 '모집단'에서 표본을 계속 추출하여 우리가 관심있는 값을 계속 계산한 후, 그 상위/하위 2.5%에 해당되는 값을 추출하면 그것이 바로 95% 신뢰구간이 됩니다. 이것을 한 1,000번 또는 10,000번 반복하면 되겠죠. 이건 부트스트랩이 왜 쓸만한 결과를 가져다주는지에 대한 엄밀한 설명은 아닙니다만, 아무튼 기본 아이디어는 그렇습니다. 이미 눈치채셨겠지만, 부트스트랩은 특정 값에 대한 신뢰구간을 만들 때 수학적 유도를 전혀 요구하지 않습니다. (부트스트랩 절차 자체에 대한 정당화는 물론 수학적으로 이루어져야겠지만요) 그 대신 순전한 계산의 힘으로 밀어붙이는 방법이라, 아마 전산에 친숙하신 분들께 특히 매력적으로 보일 것입니다. 

여기서 한 가지 중요한 디테일이 등장하는데, 바로 표본을 추출할 때 '비복원추출' sampling without replacement 이 아니라 '복원추출' sampling with replacement 을 해야 한다는 것입니다. 전자는 한 번 뽑힌 값은 그 다음부터는 뽑지 않는 것이고, 후자는 뽑을 수 있게 하는 것입니다. 예를 들어 우리가 1,2,3 이라는 세 숫자로 이루어진 데이터를 갖고 있다고 합시다. 그러면 비복원추출로 \\(n=2\\)인 샘플을 뽑는다면, 첫 번째 추출에서 1이 나오면 그 다음에는 1을 뽑을 수 없지만, 복원추출인 경우에는 (1,1)을 뽑는 것이 가능합니다. 부트스트랩은 복원추출을 통해 원 데이터셋과 동일한 크기의 새로운 데이터셋을 반복해서 만든 뒤, 우리가 관심있어하는 값을 계산하는 것을 반복합니다.

이제 예시를 하나 보겠습니다. 우리가 1부터 10까지 열 개의 숫자로 이루어진 자료를 갖고 있을 때, (정규성을 가정하고) 이 자료의 모평균에 대한 95% 신뢰구간을 얻고 싶다고 가정해 봅시다. 일단 이론적 결과부터 보면 다음과 같습니다.

```r
# R

data <- 1:10
mean(data)

[1] 5.5

c(mean(data)-1.96*sd(data)/sqrt(10), mean(data)+1.96*sd(data)/sqrt(10))
```
```r
[1] 3.623443 7.376557
```

이제 부트스트랩 방식을 사용해 보겠습니다. 원 데이터와 같은 \\(n=10\\)인 크기의 샘플을 원 데이터로부터 추출하는 과정을 10,000회 반복한 뒤, 그로부터 얻어진 10,000개의 표본평균들의 경험적 분포에서 상위/하위 2.5% 에 해당하는 값들을 끊어서 신뢰구간을 만들어 보겠습니다. 결과는 다음과 같습니다.

```r
# R
n_boot <- 10000
sample_means <- vector(length=n_boot)

for(i in 1:n_boot){
  sample_means[i] <- mean(sample(data, length(data), replace=T))
}

as.vector(quantile(sample_means, c(.025, .975)))
```
```r
[1] 3.8 7.3
```

```python
# Python
import numpy as np
import math

data = np.array(range(1, 11, 1))
n_boot = 10000
means = np.zeros(n_boot)

for i in range(n_boot):
    means[i] = np.mean(np.random.choice(data, size=data.size, replace=True))

np.quantile(means, [.025, .975])
```
```python
array([3.8, 7.3])
```

우리가 앞에서 얻었던 값인 3.62, 7.37과 약간의 차이는 있지만 상당히 근접한 값을 얻었습니다. 시행 횟수를 늘리면 차이가 조금 줄기는 합니다. 하지만 시뮬레이션 방식이기 때문에 완전히 사라지지는 않습니다.

내친김에 모표준편차에 대한 95% 부트스트랩 신뢰구간도 만들어 볼까요? 매우 쉽습니다:

```r
# R
data <- 1:10
n_boot <- 10000
sample_sds <- vector(length=n_boot)

for(i in 1:n_boot){
  sample_sds[i] <- sd(sample(data, length(data), replace=T))
}

as.vector(quantile(sample_sds, c(.025, .975)))
```
```r
[1] 1.885323 3.675746
```

```python
# Python
import numpy as np
import math

data = np.array(range(1, 11, 1)).astype(float)
n_boot = 10000
sds = np.zeros(n_boot)

for i in range(n_boot):
    sds[i] = np.std(np.random.choice(data, size=data.size, replace=True), ddof=1)

np.quantile(sds, [.025, .975])
```
```python
array([1.87379591, 3.68329563])
```

여기까지가 끝입니다. 간단하죠? 지금까지 모평균과 모표준편차에 대한 신뢰구간을 경험적 분포로부터 획득하는 데 그 어떤 수식도 사용하지 않았습니다. 오직 재표집 resampling, 우리가 관심있어하는 값의 계산, 두 가지만 사용했습니다. 똑같은 요령으로 중앙값, quantile 등 어떤 것이라도 점/구간추정이 됩니다. 이렇게 간단하게 통계적 추론을 할 수 있다는 게 마법처럼 느껴지지 않으신가요? 저는 부트스트랩을 처음 접할 때 그런 느낌이 들었습니다.

지금까지 부트스트랩의 기본적 아이디어에 대해 설명했습니다. 다음 글에서는 이를 \\(ab\\)의 95% 신뢰구간을 얻는 데 어떻게 사용할지에 대해 이야기하도록 하겠습니다.

더 읽을거리들

<a href="http://www2.stat.duke.edu/~banks/111-lectures.dir/lect13.pdf">읽을거리 1</a>

<a href="https://ocw.mit.edu/courses/mathematics/18-05-introduction-to-probability-and-statistics-spring-2014/readings/MIT18_05S14_Reading24.pdf">읽을거리 2</a>
