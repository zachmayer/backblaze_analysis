# Setup
stop()
rm(list = ls(all=T))
gc(reset = T)
library(data.table)
library(survival)
library(ggthemes)
days_to_year <- 365.2425

# Load raw data
data_raw <- fread('all_data.csv')
keys <- c('model', 'serial_number')
setkeyv(data_raw, keys)

# Sum drive days by model and failure state
data_raw <- data_raw[,list(
  drive_days = as.integer(sum(N)),
  failure = as.integer(sum(failure)),
  tb = as.numeric(round(max(capacity_bytes)/1e+12, 1))
), by=keys]

# Calculate 99% confidence interval of 99% survival
survival_quantile <- function(time, failure, quantiles){
  out <- survfit(Surv(time, failure)~1)
  out <- quantile(out, quantiles/100)
  out <- list(
    percentile = quantiles,
    lower = as.numeric(out$lower),
    days =  as.numeric(out$quantile),
    upper =  as.numeric(out$upper)
  )
  return(out)
}

data_quant <- data_raw[, c(
  list(tb=max(tb)),
  survival_quantile(drive_days, failure,  quantiles=seq(0, 1, length=11)[-1])
), by='model']

data_quant

# Do a non-parametric survival curve for every drive model
survival_curve_at_t <- function(time, failure, at=days_to_year){
  out <- survfit(Surv(time, failure)~1)
  out <- summary(out, times=at, conf.int=.95)
  out <- list(
    surv = out$surv,
    lower =  out$lower
  )
  return(out)
}

data_surv <- data_raw[, c(list(
  capacity_tb=max(capacity_tb), 
  drive_days=sum(drive_days),
  failures=sum(failure),
  N_drives=.N
), survival_curve_at_t(drive_days, failure)), by='model']
data_surv <- data_surv[order(-lower),]

# Choose best drive
best_drive <- data_surv[1, model]