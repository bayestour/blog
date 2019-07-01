
library(ggplot2)

n_data = 10000

xdata1 = rnorm(n=(n_data/2), mean=10, sd=3)
xdata2 = rnorm(n=(n_data/2), mean=20, sd=3)
xdata = c(xdata1, xdata2)

ydata1 = xdata1 * 1 + rnorm(n=(n_data/2), mean=0, sd=3)
ydata2 = xdata2 * (-0.5) + rnorm(n=(n_data/2), mean=0, sd=2)
ydata = c(ydata1, ydata2)

data = data.frame(x=xdata, y=ydata)
ggplot(data=data, aes(x,y)) + geom_point(colour='blue', size=0.5)

model = glm(data$y ~ data$x)
