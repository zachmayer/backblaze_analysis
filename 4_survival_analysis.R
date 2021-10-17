# Setup
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
  drive_days = sum(N),
  failure=sum(failure),
  capacity_tb=round(max(capacity_bytes)/1e+12, 1)
), by=keys]

# Count number of drives that survived to one year by model
data_raw[,count_one_year := sum(drive_days>=days_to_year), by='model']

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