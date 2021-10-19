rm(list=ls(all=T))
gc(reset=T)
library(data.table)
library(survival)
library(BayesSurvival)
library(rstanarm)
library(quantreg)
library(ctqr)

dat <- data.table(
  days = c(762, 766),
  failed = c(1, 0)
)

model <- dat[,survfit(Surv(days, failed) ~ 1, robust=T, type = "fleming-harrington", conf.type = "log-log")]
summary(model, times=761)
summary(model, times=762)
quantile(model, 0.01)

dat[,ctqr(Surv(days, failed) ~ 1, p=seq(0.01, .99, length=100))]

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
