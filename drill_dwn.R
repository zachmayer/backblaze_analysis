rm(list=ls(all=T))
gc(reset=T)
library(data.table)
library(survival)
library(BayesSurvival)
library(rstanarm)
library(quantreg)
library(prodlim)
custom_palette <- c(
  "#1f78b4", "#ff7f00", "#6a3d9a", "#33a02c", "#e31a1c", "#b15928",
  "#a6cee3", "#fdbf6f", "#cab2d6", "#b2df8a", "#fb9a99", "black",
  "grey1", "grey10"
)

library(prodlim)
dat <- drive_dates[model %in% c('WDC  WUH721414ALE6L4', 'HGST HUH721212ALN604'),]
model <- dat[,prodlim(Surv(days, failed) ~ model)]
summary(model, times=180)
summary(model, times=181)
summary(model, times=1084, newdata=data.frame(model='WDC  WUH721414ALE6L4'))
quantile(model, c(0.0005, .99))

y <- dat[days>0, as.matrix(data.table(time=days, status=failed))]
x <- dat[days>0, model.matrix(~ factor(model))]
fit <- cv.glmnet(x, y, family = "cox")
plot(fit)
predict(fit, x)


dat <- data.table(
  days = c(762, 766),
  failed = c(1, 0)
)
model <- dat[,prodlim(Surv(days, failed) ~ 1)]
summary(model, times=761)
summary(model, times=762)
quantile(model, c(0.01, .99))

model <- dat[,survfit(Surv(days, failed) ~ 1, robust=T, type = "fleming-harrington", conf.type = "log-log")]
summary(model, times=761)
summary(model, times=762)
quantile(model, c(0.01, .99))


quantile(model, .01)$lower
model_bayes <- BayesSurv(
  df = data.frame(dat), #our data frame
  time = "days", #name of column with survival/censoring times
  event = "failed", #name of column with status indicator
  prior = "Dependent", #use dependent Gamma prior
  
)

PlotBayesSurv(bayes.surv.object = model_bayes,
              object = "survival")

mod1 <- stan_surv(formula = Surv(days, failed) ~ 1, data=data.frame(dat), algorithm = 'fullrank')


dat <- data.frame(
  days = c(
    1483L, 2693L, 1145L, 1477L, 1481L, 1428L, 1768L, 2693L, 1476L, 2693L, 2693L, 
    2051L, 1180L, 1645L, 2693L, 1313L, 2693L, 2693L, 1399L, 1455L, 2693L, 1476L, 
    2693L, 1476L), 
  failed = c(
    0L, 0L, 1L, 0L, 0L, 0L, 1L, 0L, 0L, 0L, 0L, 0L, 0L, 0L, 0L, 0L, 0L, 0L, 0L, 
    0L, 0L, 0L, 0L, 0L)
)
res <- BayesSurv(
  df = data.frame(dat), #our data frame
  time = "days", #name of column with survival/censoring times
  event = "failed", #name of column with status indicator
  prior = "Dependent", #use dependent Gamma prior
)

PlotBayesSurv(bayes.surv.object = res,
              object = "survival")
