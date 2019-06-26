---
layout: post-sidenav
title: "Dirichlet Process"
group: "Bayesian Statistics"
author: 임성빈
---

Nonparametric Bayesian 에서 군집화 문제를 풀 때 사용되는 [Dirichlet Process](https://en.wikipedia.org/wiki/Dirichlet_process) 를 소개합니다.

### 군집화 문제란?

군집화(clustering)란 말 그대로 **주어진 데이터를 몇 개의 부분집합으로 나누는 것** 입니다. 각 데이터 포인트 \\( x \\) 마다 쌍으로 정답 레이블(label) \\( y \\) 이 있는 분류(classification)문제와는 달리 군집화 문제는 레이블이 없습니다. 그래서 비지도학습(unsupervised learning)의 한 종류입니다. 아래 그림을 보시면 왼쪽이 주어진 데이터이고, 오른쪽이 군집화를 거친 결과입니다.

![figure1]({{ site.baseurl }}/images/posts/cluster-2019-06-26-figure1.png){:class="center-block" height="200px"}

대체로 머신러닝 수업에서 배우는 군집화 알고리즘은 다음과 같습니다

- K-means
- GMM(Gaussian Mixture Model)
- DBSCAN 

오늘 소개할 Dirichlet Process (DP) 는 군집화 문제를 푸는 대표적인 nonparametric Bayesian 방법입니다. 오늘은 DP 를 활용

### 군집화 문제의 Mixture 모델 표현

우선 군집화 문제를 확률적으로 재해석 해보겠습니다. 데이터에서 \\( X \\) 를 관찰한다고 합시다. \\( L(X) \\) 이라는 함수는 이 데이터가 어떤 군집(cluster)에서 뽑혔는지 말해주는 확률변수라고 정의하겠습니다. 다시 말해 \\( L(X)=k \\) 라는 건 **데이터 \\( X \\) 가 집합 \\( k \\) 에서 뽑혔다** 는 뜻입니다. 실제 문제에서는 \\( L(X) \\) 의 값은 미지수이겠지요?

위와 같은 세팅에서 아래와 같은 확률분포를 우리는 정의할 수 있습니다. 즉, 데이터 \\( X \\) 가 \\( k \\) 에서 뽑혔을 때, \\( X \\) 가 어떤 집합 \\( j \\) 에 속한다고 판단을 내릴 확률입니다.

$$
P_{k}(j) := \mathbb{P}(X \in j | L(X)=k)
$$

\\( \pi_{k} := \mathbb{P}(L(X)=k) \\) 라고 정의하겠습니다 (당연히 \\( \sum_{j}\pi_{j} = 1 \\) 이겠죠?).

$$
P(j) = \sum_{k}\pi_{k}P_{k}(j)
$$

### Dirichlet Process

이제 DP 를 저

**[Definition]** \\( \alpha > 0 \\) 이고 \\( G \\) 가 \\( \Omega_{\phi} \\) 위에 정의된 확률측도일 때, 이산확률측도 \\( \Theta \\) 를 다음과 같이 정의하자:
$$
\Theta := \sum_{k} C_{k}\delta_{\Phi_{k}}
$$
이 때 이 \\( \Theta \\) 를 **Dirichlet Process (DP)** 라 부르고 \\( G \\) 를 **base measure**, \\( \alpha \\) 를 **concentration** 이라 한다. 여기서 \\( \delta \\) 는 Dirac 측도이고 \\(C_{k}\\), \\(\Phi_{k}\\) 는 다음과 같다:
$$
\begin{aligned}
V_{1}, V_{2},\ldots \underset{\text{i.i.d}}{\sim} \text{Beta}(1,\alpha),\quad C_{k}=V_{k}\prod_{j=1}^{k-1}(1-V_{k})
\end{aligned},\quad \Phi_{1},\Phi_{2},\ldots,\underset{\text{i.i.d}}{\sim}G
$$
주어진 \\( \alpha, G \\) 에 대해 \\( \Theta \\) 의 확률분포를 \\( DP(\alpha, G) \\) 로 표기한다.


### Clustering with DP

### Algorithm
