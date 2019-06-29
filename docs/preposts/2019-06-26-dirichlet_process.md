---
layout: post-sidenav
title: "Dirichlet Process(작성중)"
group: "Bayesian Statistics"
author: 임성빈
---

Nonparametric Bayesian 에서 군집화 문제를 풀 때 사용되는 [Dirichlet Process](https://en.wikipedia.org/wiki/Dirichlet_process) 를 소개합니다.

### 군집화 문제란?

군집화(clustering)란 말 그대로 **주어진 데이터를 몇 개의 부분집합으로 나누는 것** 입니다. 각 데이터 포인트 \\( x \\) 마다 쌍으로 정답 레이블(label) \\( y \\) 이 있는 분류(classification)문제와는 달리 군집화 문제는 레이블이 없습니다. 그래서 비지도학습(unsupervised learning)의 한 종류입니다. 아래 그림을 보시면 왼쪽이 주어진 데이터이고, 오른쪽이 군집화를 거친 결과입니다.

![figure1]({{ site.baseurl }}/images/posts/cluster-2019-06-26-figure1.png){:class="center-block" height="200px"}

대체로 머신러닝 수업에서 배우는 군집화 알고리즘은 다음과 같습니다

- K-means
- GMM (Gaussian Mixture Model)
- DBSCAN 

오늘 소개할 Dirichlet Process (DP)는 군집화 문제를 푸는 대표적인 nonparametric Bayesian 방법입니다. 사실 DP 는 활용하면 군집화 문제 뿐만 아니라 다른 곳에도 응용할 수 있습니다만, 이 포스트에서는 DP 를 활용하여 군집화 문제를 푸는 방법을 소개하겠습니다.

### 군집화 문제의 Mixture 모델 표현

우선 군집화 문제를 확률적으로 재해석 해보겠습니다. 데이터 \\( X \\) 를 관찰했다고 합시다. \\( L(X) \\) 이라는 함수는 이 데이터가 몇 번째 집합에서 뽑혔는지 확인해주는 함수라고 정의하겠습니다 (실제 상황에서는 이 함수를 알 수 없습니다). 다시 말해 \\( L(X)=k \\) 라는 건 **데이터 \\( X \\) 가 \\( k \\) 번째 집합에서 뽑혔다** 는 뜻입니다.

위와 같은 세팅에서 아래와 같은 확률분포를 우리는 정의할 수 있습니다. 즉, 데이터 \\( X \\) 가 집합 \\( k \\) 에서 뽑혔을 때, \\( X \\) 가 어떤 집합 \\( j \\) 에 속한다고 우리가 (또는 알고리즘이) 판단을 내릴 확률입니다.

$$
P_{k}(j) := \mathbb{P}(X \in j | L(X)=k)
$$

여기서 \\( P_{k}(j) \\) 는  **우도(likelihood)** 에 해당합니다. 올바른 모델링이라면 \\( j = k \\) 일 때 가장 값이 커야겠지요? \\( \pi_{k} := \mathbb{P}(L(X)=k) \\) 라고 표기하겠습니다. 이 확률을 모든 집합 \\( k \\) 에 더해 더하면 \\( \sum_{k}\pi_{k} = 1 \\) 이 성립합니다. 또한 조건부 확률의 정의에 의해 다음과 같은 관계식이 성립하게 됩니다.

$$
P(j) := \mathbb{P}(X\in j) = \sum_{k}\mathbb{P}(X \in j , L(X)=k) = \sum_{k}\pi_{k}P_{k}(j)\quad \cdots\quad (1)
$$

식 (1) 을 **mixture 모델** (또는 mixture 분포) 라 부릅니다.  여기서 \\( \pi_{k} \\) 는 데이터의 전체 분포에서 어떤 집합이 차지할 확률에 해당하는데요, 이를 mixture weight 라고 합니다. 군집화 문제에선 당연히 \\( P_{k}(j)\\) 을 정확하게 계산하는 것이 중요합니다. 궁극적으로 군집화 문제에서 \\( \pi_{k} \\) 가


### Dirichlet Process 에 대한 수학적 설명

지금까지는 직관적인 설명을 위해 다소 수학적인 부분을 배제하려고 했는데요, 이런 설명으로는 만족하지 않을 분이 계실까 염려(?)되어 수학적인 정의 및 성질에 대해서도 같이 설명하겠습니다. 단, 본 항목을 이해하려면 [측도론(measure theory)](https://en.wikipedia.org/wiki/Measure_(mathematics))의 기본적인 용어들을 알아야 합니다. 측도론을 모르시는 분들은 과감하게 skip 하셔도 좋습니다.

우선 Drichlet Process (DP) 를 수학적으로 정의하겠습니다.

---
#### Definition
\\( \alpha > 0 \\) 이고 \\( G \\) 가 \\( \Omega_{\phi} \\) 위에 정의된 확률측도일 때, 이산확률측도 \\( \Theta \\) 를 다음과 같이 정의하자:

$$
\Theta := \sum_{k} C_{k}\delta_{\Phi_{k}}
$$

이 때 이 \\( \Theta \\) 를 **Dirichlet Process (DP)** 라 부르고 \\( G \\) 를 **base measure**, \\( \alpha \\) 를 **concentration** 이라 한다. 여기서 \\( \delta \\) 는 Dirac 측도이고 \\(C_{k}\\), \\(\Phi_{k}\\) 는 다음과 같다:

$$
\begin{aligned}
V_{1}, V_{2},\ldots \underset{\text{i.i.d}}{\sim} \text{Beta}(1,\alpha),\quad C_{k}=V_{k}\prod_{j=1}^{k-1}(1-V_{k})
\end{aligned},\quad \Phi_{1},\Phi_{2},\ldots,\underset{\text{i.i.d}}{\sim}G
$$

주어진 \\( \alpha, G \\) 에 대해 \\( \Theta \\) 의 확률분포를 \\( \text{DP}(\alpha, G) \\) 로 표기한다.

---



### Clustering with DP

### Algorithm
