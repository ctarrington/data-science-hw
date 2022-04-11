data = read.table("http://www.stat.ufl.edu/~winner/data/pgalpga2008.dat",header=FALSE)
attach(data)
names(data)
data$V3=data$V3-1
summary(data)

data.lm=lm(V2~V1+V3)
print(data.lm)
predict(data.lm, data.frame(V1=260, V3=1), interval = "predict")

plot(fitted(data.lm), residuals(data.lm))
