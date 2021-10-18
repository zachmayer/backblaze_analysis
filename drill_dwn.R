library(data.table)
library(survival)
library(BayesSurvival)
library(rstanarm)

dat <- data.table(
  days = rep(c(762, 766), 100),
  failed = rep(c(1, 0), 100)
)

model <- dat[,survfit(Surv(days, failed) ~ 1)]
summary(model, times=2 * 365.25)
summary(model, times=761)
summary(model, times=3 * 365.25, extend=T)

quantile(model, .01)$lower
model_bayes <- BayesSurv(
  df = data.frame(dat), #our data frame
  time = "days", #name of column with survival/censoring times
  event = "failed", #name of column with status indicator
  prior = "Dependent", #use dependent Gamma prior
  
)

PlotBayesSurv(bayes.surv.object = res,
              object = "survival")



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
