# Setup
# TODO: TRY A PROPORTIAL HAZARD MODEL — the 14 TB DRIVES LOOK GREAT BUT AREN'T YET 1 YEAR OLD
# TODO: Plot best drive by size
stop()
rm(list = ls(all=T))
gc(reset = T)
library(data.table)
library(kit)
library(survival)
library(ggthemes)
library(survminer)
source('code/helpers.r')

# Load data
capacity_map <- fread('results/capacity_map.csv')
drive_dates <- fread('results/drive_dates.csv')

# Format HD sizes nicely
format_hd_size <- function(x, ...){
  utils:::format.object_size(x, ..., standard='SI', digits=0)
}
capacity_map[capacity_bytes <  1e+12, size := format_hd_size(capacity_bytes, 'GB')]
capacity_map[capacity_bytes >= 1e+12, size := format_hd_size(capacity_bytes, 'TB')]

capacity_order <- capacity_map[,list(capacity_bytes=max(capacity_bytes)), by='size']
capacity_order <- capacity_order[order(capacity_bytes),]
capacity_map[,size := factor(size, levels=capacity_order[,size], ordered=T)]
fwrite(capacity_map, 'results/capacity_map_clean.csv')
fwrite(capacity_order, 'results/capacity_order.csv')

# Computer drive failure, and time to failure or time to censoring
drive_dates[,failed := as.integer(is.finite(first_fail))]
drive_dates[is.finite(first_fail), max_date := first_fail]
drive_dates[,days := as.integer(max_date - min_date)]
drive_dates[,model := factor(model)]

# Choose the "reference" class based
ref_level <- 'HGST HMS5C4040BLE640'  # Reliable 4TB drive with lots of drives and drive days
ref_level <- string_normalize(ref_level)
drive_dates[,model := factor(model)]
drive_dates[,model := relevel(model, ref=ref_level)]
fwrite(drive_dates, 'results/drive_dates_clean.csv')

# Fit the cox model
cox_model <- drive_dates[,coxph(Surv(time=days, failed) ~ 1 + model, x=T)]

# Extract cox model coefficients
# These coefficients are "hazard ratios".  Lower hazard is better
cf <- summary(cox_model)
cf <- data.table(
  model=row.names(coef(cf)),
  coef(cf),
  cf$conf.int[,c('lower .95', 'upper .95')]
  )
stopifnot(sum(duplicated(names(cf)))==0)
cf[,model := gsub('model', '', model, fixed=T)]
cf <- cf[order(`upper .95`, coef),]

# Calculate median survival and 5 year survival per model
CONF_LEVEL = .95
i <- 0
pb = txtProgressBar(min = 0, max = length(cf[['model']]), initial = 0, style=3)
for(m in cf[['model']]){
  cox_surv_curve <- survfit(cox_model, conf.int=CONF_LEVEL, newdata=data.table(model=m), conf.type="logit")
  quantile_surv <- quantile(cox_surv_curve, .01)
  surv_5_year <- summary(cox_surv_curve, conf.int=CONF_LEVEL, 1 * days_to_year)

  cf[model == m, surv_days_99pct := quantile_surv[["lower"]]]
  cf[model == m, surv_5yr_lower := surv_5_year$lower]
  cf[model == m, surv_5yr := surv_5_year$surv]
  cf[model == m, surv_5yr_upper := surv_5_year$upper]

  i <- i + 1
  setTxtProgressBar(pb,i)
}
close(pb)

# Calculate drive stats and combine with summary stats
dat <- drive_dates[,list(
  n_unique=length(funique(serial_number)),
  drive_days = sum(days),
  naive_age_med = as.numeric(median(days)),
  naive_age_mean = as.numeric(mean(days)),
  failed = sum(failed)
), by='model']
dat[,model := as.character(model)]
dat <- merge(dat, cf, by='model', all=F)
dat <- merge(dat, capacity_map, by='model', all=F)

# Order data and select columns
dat <- dat[order(
  -surv_5yr_lower, -surv_5yr, surv_5yr_upper,
  -surv_days_99pct,
  -drive_days, -n_unique, failed, -size),]
dat <- dat[, list(
  model, size, n_unique,
  drive_days, failed, surv_days_99pct,
  surv_5yr_lower, surv_5yr, surv_5yr_upper)]

# Save data for the write up
fwrite(dat, 'results/survival_results.csv')
saveRDS(cox_model, 'results/cox_model.rds')
