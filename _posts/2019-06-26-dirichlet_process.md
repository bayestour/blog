---
layout: post-sidenav
title: "Dirichlet Process"
group: "Nonparametric Bayesian"
author: 임성빈
---

Nonparametric Bayesian 에서 군집화 문제를 풀 때 사용되는 [Dirichlet Process](https://en.wikipedia.org/wiki/Dirichlet_process) 를 소개합니다.

### 군집화(clustering)란?

군집화란 말 그대로 **주어진 데이터를 몇 개의 부분집합으로 나누는 것** 입니다.

![figure1]({{ site.baseurl }}/images/posts/cluster-2019-06-26-figure1.png){:class="center-block" height="200px"}

대체로 머신러닝 수업에서 배우는 군집화 알고리즘은 다음과 같습니다

- K-means
- GMM
- DBSCAN 

오늘 소개할 Dirichlet process는 군집화 문제를 푸는 대표적인 nonparametric Bayesian 방법입니다.

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
