
library(ggplot2)

n_data = 10000

# xdata1 = rnorm(n=(n_data/2), mean=10, sd=3)
# xdata2 = rnorm(n=(n_data/2), mean=20, sd=3)
# xdata = c(xdata1, xdata2)
# 
# ydata1 = xdata1 * 1 + rnorm(n=(n_data/2), mean=0, sd=3)
# ydata2 = xdata2 * (-0.5) + rnorm(n=(n_data/2), mean=0, sd=2)
# ydata = c(ydata1, ydata2)
# 
# data = data.frame(x=xdata, y=ydata)
# ggplot(data=data, aes(x,y)) + geom_point(colour='blue', size=0.5)
# 
# model = glm(data$y ~ data$x)

sd_jitter = 0.3

cutter = function(x) {
  x <- x + rnorm(1, 0, sd_jitter)
  x <- min(max(x ,0), 10)
  return(x)
}

customer = function(t) {
  if (t==1) {
    return(cutter(rbinom(1, 10, 0.1)))
  }
  if (t==2) {
    return(cutter(rbinom(1, 10, 0.5)))
  }
  if (t==3) {
    if (runif(1,0,1) > 0.5) {
      return(cutter(rbinom(1, 10, 0.99)))  
    }
    else {
      return(cutter(rbinom(1, 10, 0.7)))
    }
  }
  if (t==4) {
    return(cutter(rbinom(1, 10, 0.7)))
  }
  if (t==5) {
    return(cutter(rbinom(1, 10, 0.3)))
  }
}
  
time = round(runif(n=n_data, min=1, max=5))
vistor = sapply(time, customer)
fisher_ = data.frame(customers=vistor, time=time)

ggplot(data=fisher_,
       aes(x=time, y=customers)) + 
  geom_boxplot(
    data=fisher_,
    aes(x=time, y=customers, group=time, fill=customers)
  )

