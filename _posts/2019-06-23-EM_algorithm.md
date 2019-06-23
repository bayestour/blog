---
layout: rmarkdown::github_document
title: "EM 알고리즘 이해 및 구현하기"
---

<p4><b> EM 알고리즘 이해 및 구현하기 </b></p4>
<br>
<br>
<p3><b> 박준석 </b></p3>
<br>
<p3><b> 2019년 6월 23일 </b></p3>
<br>

요즘들어 구현 시리즈를 많이 쓰는 것 같은데 나중에 한 번 따로 엮을까도 싶군요. 아무튼 오늘 소개할 내용은 EM 알고리즘입니다. EM 알고리즘…통계를 좀 깊게 들어간다 싶으면 반드시 등장하는 중요한 내용이지만 이해하기는 꽤 어렵습니다. 그래서 오늘은 이것을 설명하고 간단한 사례를 구현하는 것까지 한 번 해 보도록 하겠습니다.

우선 목적부터 설명하겠습니다. EM알고리즘은 기본적으로 부분적인 결측치가 있는 자료에서 최대가능도 (ML) 추정치를 구할 때 씁니다. [1] 원래는 결측치가 있으면 가능도를 계산할 수 없어서 ML을 적용할 수 없죠? 이럴 때 부분적 결측이 있는 케이스를 빼고 추정하면 간단하긴 한데, 그러면 남은 자료에서 얻을 수 있는 정보량만큼 버리는 꼴이라 비효율적입니다. 그래서 이것을 감안하여, 결측치가 있는 상황에서도 ML추정을 할 수 있게 만든 게 바로 EM 알고리즘입니다. 하지만 예제에서 다루듯 다른 다양한 문제에도 적용 가능하기 때문에, 널리 사용되고 있습니다.

여기서 설명할 사례는 참고문헌의 Do & Batzoglou (2008) 에서 가져왔습니다. 그런데 페이퍼가 굉장히 직관적이기는 하지만, 수학적 디테일을 많이 빼먹었기 때문에 저에게는 조금 불만족스러웠습니다. 일반적인 구현에 대한 아이디어도 없고요. 그래서 저는 같은 문제를 좀 더 비틀어서, 일반적인 케이스에 쓸 수 있는 형태로 설명하겠습니다.

이제 시행횟수(<img src="https://latex.codecogs.com/gif.latex?n" />)가 10인 이항분포에서 랜덤 샘플링을 할 건데, 공평한 동전을 던져 앞면이 나오면 성공 확률을 <img src="https://latex.codecogs.com/gif.latex?p_1" />  = 0.8로 설정하고 뒷면이 나오면 <img src="https://latex.codecogs.com/gif.latex?p_2" /> = 0.45로 설정한다고 칩시다. 그러면 두 분포는 각각 Binomial(10, 0.8)과 Binomial(10, 0.45)가 되고, 0.5의 확률로 각각의 분포에서 샘플링을 하게 됩니다. 이 짓을 다섯 번 반복합니다. 그래서 얻은 값이 5, 9, 8, 4, 7이었다고 칩시다.

이제 우리가 할 일은 <img src="https://latex.codecogs.com/gif.latex?p_1" /> 과 <img src="https://latex.codecogs.com/gif.latex?p_2" /> 를 추정하는 것입니다. 여기서 만약 우리가 동전이 무슨 면이 나왔는지 안다면 문제는 매우 간단합니다. 이를테면 (뒤, 앞, 앞, 뒤, 앞) 이 나왔다고 합시다. 그러면 <img src="https://latex.codecogs.com/gif.latex?p_1" />은 앞면이 나온 경우의 성공 횟수를 총 시행횟수로 나누고, <img src="https://latex.codecogs.com/gif.latex?p_2" />는 뒷면이 나온 경우의 성공 횟수를 총 시행횟수로 나누면 쉽게 구할 수 있습니다. 그러니까 <img src="https://latex.codecogs.com/gif.latex?p_1" />에 대한 (최대가능도) 추정치는 (9+8+7)/(10+10+10) = 0.8이고, <img src="https://latex.codecogs.com/gif.latex?p_2" />에 대한 추정치는 (5+4) / (10+10) = 0.45 입니다. 이런 경우를 “완전한 데이터” complete data 라 부릅니다. 즉 우리는 자료에 대한 모든 정보를 갖고 있고, 모든 모수치에 대해 완벽하게 추정할 수 있습니다. 이건 가장 happy한 케이스입니다.

그런데 이제 상황을 좀 바꾸어서, 각각의 경우 동전이 무슨 면이 나왔는지는 모르고 성공 횟수만 안다고 가정해 봅시다. 이 때는 자료를 앞면이 나온 경우와 뒷면이 나온 경우로 나누어서 <img src="https://latex.codecogs.com/gif.latex?p_1" /> 과 <img src="https://latex.codecogs.com/gif.latex?p_2" /> 를 추정할 수 없습니다. 즉 이제 동전이 무슨 면이 나왔는지는 일종의 “결측치” 입니다. 이런 경우를 “불완전 자료” incomplete data 라 부릅니다. 당연히 이 때 일반적인 최대가능도 추정법을 사용하는 것은 불가능합니다. 그럼 어떻게 해야 할까요?

각각의 경우 우리는 동전이 어느 면이 나왔는지는 모르지만, 10번 중 몇 번 성공했는지는 알고 있습니다. 이 정보를 유용하게 사용할 수 있지 않을까요? 다시 말해 5, 9, 8, 4, 7 이라는 숫자를 보면 “딱 봐도” 9,8,7과 5,4는 왠지 두 그룹으로 묶을 수 있을 것 같습니다. 다시 말해 우리는 이 숫자들이 <img src="https://latex.codecogs.com/gif.latex?p_1" />과 <img src="https://latex.codecogs.com/gif.latex?p_2" /> 중 어느 쪽에서 생성되었을지 “감을 잡을 수” 있다는 말입니다. 그런데 이 “감”은 부정확하므로, 대신 각각의 숫자가 어떤 <img src="https://latex.codecogs.com/gif.latex?p_1" />과 <img src="https://latex.codecogs.com/gif.latex?p_2" />에서 생성되었는지 상대적인 확률을 구해 봅시다. 예를 들어 <img src="https://latex.codecogs.com/gif.latex?p_1" />=0.6, <img src="https://latex.codecogs.com/gif.latex?p_2" />=0.5라고 해 봅시다. 그러면 dbinom(X, 10, 0.6)과 dbinom(X, 10, 0.5)의 비율을 각각의 숫자에 대해 구할 수 있습니다. 그러면 결과는 다음과 같습니다:

```{r}

n <- 10
y <- c(5, 9, 8, 4, 7)
p <- c(0.6, 0.5)
weights <- dbinom(y, n, p[1]) / (dbinom(y, n, p[1]) + dbinom(y, n, p[2]))
weights

```

여기서 weights는 <img src="https://latex.codecogs.com/gif.latex?p_1" /> 과 <img src="https://latex.codecogs.com/gif.latex?p_2" />  하에서 자료가 생성되었을 확률의 상대적 비율을 나타냅니다. 이제 이것을 이용해서 각 자료의 확률을 <img src="https://latex.codecogs.com/gif.latex?p_1" />과 <img src="https://latex.codecogs.com/gif.latex?p_2" /> 하에서의 확률 값의 가중평균으로 구할 수 있습니다. 이 확률들을 다 곱하면 가능도가 되겠죠? 그런데 여기서는 그냥 가능도 대신 로그-가능도를 씁니다. 다음 함수는 이런 방식으로 계산된 로그-가능도를 계산해주는 함수입니다.

```{r}
E <- function(p, weights) -sum(weights*dbinom(y, n, p[1], log=T) +
  (1-weights)*dbinom(y, n, p[2], log=T))
```

마이너스를 붙인 이유는 이제 이 함수를 최적화할 거라서입니다. (원래 최대가능도법의 목적은 가능도함수를 최대화하는 것임을 상기합시다.) 이제 이 E라는 함수를 최적화하는 함수를 하나 따로 짭니다:

```{r}
M <- function(p, weights) optim(p, E, weights=weights, lower=c(1e-10, 1e-10),
  upper=c(1-(1e-10), 1-(1e-10)), method='L-BFGS-B')$par
```

기술적 디테일이 좀 있지만 무시하고, <img src="https://latex.codecogs.com/gif.latex?p" />는 최적화를 위한 일종의 시작 값이며, 이 함수는 주어진 가중치를 사용하여 만들어진 새로운 가능도함수를 최대화한다는 것만 기억합시다. 시작 값으로 <img src="https://latex.codecogs.com/gif.latex?p_1=0.6" />,  <img src="https://latex.codecogs.com/gif.latex?p_2=0.5" />를 준 후 최적화하면 다음과 같은 결과를 얻습니다 (참고문헌과 같은 결과):

```{r}
M(c(0.6, 0.5), weights)
```

여기까지가 한 바퀴입니다. EM 알고리즘은 이렇게 로그-가능도함수를 결측치에 대한 가중평균으로 구하는 “기댓값” 스텝 (E-step), 그리고 그렇게 가중평균이 된 로그-가능도함수를 최대화하는 모수치의 값을 찾는 “최대화” 스텝 (M-step) 으로 이루어져 있습니다. 이 둘을 더 이상 로그가능도함수의 값이 유의미하게 변화하지 않을 때까지 반복하면 됩니다. [2]

이것을 실제로 구현하면 다음과 같습니다:

```{r}

iter <- 0
dif <- 1000
eps <- 1e-10

while(dif > eps){
  
  weights <- dbinom(y, n, p[1]) / (dbinom(y, n, p[1]) + dbinom(y, n, p[2]))
  temp <- M(p, weights)
  weights_temp <- dbinom(y, n, temp[1]) / (dbinom(y, n, p[1]) + dbinom(y, n, temp[2]))
  dif <- abs(E(p, weights)-E(temp, weights_temp))
  p <- temp
  iter <- iter + 1
}

p

iter
```

알고리즘은 20회 만에 수렴했고, E-M 알고리즘에 의해 구해진 최대가능도 추정치는 <img src="https://latex.codecogs.com/gif.latex?p_1" /> =0.797, <img src="https://latex.codecogs.com/gif.latex?p_2" /> =0.520 입니다. 물론 이 값은 실제 값과 좀 다른데, 동전의 면을 알고 추정한 경우 정확히 모수치와 일치한 것에 비하면 좀 실망스러운 값입니다. 하지만 정보가 부족했기 때문에, 이 편차는 어쩔 수 없습니다.

그러면 데이터의 양을 좀 늘리면 괜찮아질까요? 자료를 좀 더 많이 샘플링하면 추정치가 좀 더 향상되는 걸 알 수 있습니다. 코드는 아래 깃헙 주소에서 받으실 수 있습니다. 실행해 보면 <img src="https://latex.codecogs.com/gif.latex?p_1" />과 <img src="https://latex.codecogs.com/gif.latex?p_2" />의 참값에 꽤 가까운 값이 나올겁니다. (운이 아주 나쁘지 않으면요.)

여기까지 E-M 알고리즘의 스텝을 정리하면 다음과 같습니다:

1. 모수치의 값을 적당히 초기화한다.
2. 가중치를 각 케이스별로 계산하는데, 이것은 개별 모수치 하에서 확률질량(밀도) 값의 비율로 정의된다. [3]
3. 가중치를 이용한 로그-가능도함수를 정의하고, 이를 최대화하는 모수치의 값을 찾는다.
4. 3. 에서 얻어진 모수치의 값이 이전 모수치의 값에서 거의 변하지 않을 때까지 1-3을 반복한다.

이것이 E-M 알고리즘의 개요입니다. 하지만 다른 수치적 해법들과 마찬가지로 E-M 알고리즘은 가능도함수가 최대화되는 지점을 반드시 찾아준다는 보장은 없습니다. 이를 local maxima의 문제라 하는데, 이에 대한 설명은 생략하겠습니다.

참고문헌은 최대화 과정을 생략하고 표본평균으을 구하는 것으로 바꾸었는데, 사실 이항분포의 경우 표본평균은 곧 최대가능도 추정치기 때문에 상관이 없습니다. 하지만 이 예제에서는 구체적으로 로그-가능도 함수를 최대화하는 것을 보여줌으로써 보다 일반적인 경우에 대해 다루려 했습니다. E-M 알고리즘의 이해에 도움이 되셨기를 바랍니다. 참고로 E-M 알고리즘은 mixture distribution의 추정, 결측치 대체 등 다양한 문제에서 유용하게 사용되고 있습니다.

전체 R 코드: https://github.com/JoonsukPark/examples/blob/master/EM_binomial.R

참고문헌

Do, C. B., & Batzoglou, S. (2008). What is the expectation maximization algorithm?. Nature biotechnology, 26(8), 897.

https://www.nature.com/articles/nbt1406

[1] 모수치의 추정 문제에도 적용할 수 있는데, 이것은 모수치를 결측치로 간주하는 트릭을 쓸 수 있기 때문입니다. 

[2] 참고로 매 “바퀴”마다 로그가능도함수의 값은 증가함이 알려져 있습니다.

[3] 이 사례에서는 생략됐지만, 사실 prior 의 값도 고려되어야 하긴 합니다. 다시 말해 우리는 ‘동전’이 공평하다는 것을 알기 때문에 가중치를 따로 고려하지 않았지만, 만약 그 ‘동전’의 앞면이 나올 확률이 0.6이거나 했다면 이를 따로 곱해주어야 한다는 말입니다.
