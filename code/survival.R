# Load data
drive_dates <- data.table::fread('results/drive_dates.csv')[capacity_tb >= 1,]  # Exclude small drives

# Calculate time to failure or time to censoring
drive_dates[,days := as.numeric(max_date - min_date)]

# Choose the "reference" class based
ref_level <- 'hgst hms5c4040ble640'  # Reliable 4TB drive with lots of drives and drive days
drive_dates[,model := factor(model)]
drive_dates[,model := relevel(model, ref=ref_level)]

# Fit the cox model.  Takes about 2 mins
cox_model <- drive_dates[,survival::coxph(survival::Surv(time=days, failed) ~ 1 + model, x=T)]

# Extract cox model coefficients
# These coefficients are "hazard ratios".  Lower hazard is better
cf <- summary(cox_model)
cf <- data.table::data.table(
  model=row.names(coef(cf)),
  coef(cf),
  cf$conf.int[,c('lower .95', 'upper .95')]
)
stopifnot(sum(duplicated(names(cf)))==0)
cf[,model := gsub('model', '', model, fixed=T)]
cf <- cf[order(`upper .95`, coef),]

# Calculate median survival and 5 year survival per model
CONF_LEVEL = .95
newdata_all_models <- data.table::data.table(model = setdiff(cf[['model']], '(Intercept)'))
cox_surv_curves <- survival::survfit(cox_model, conf.int = CONF_LEVEL, newdata = newdata_all_models, conf.type = "logit")
quantiles_surv <- quantile(cox_surv_curves, .03)  # 3% survival quantile
surv_5_year <- summary(cox_surv_curves, conf.int = CONF_LEVEL, times = 365.25 * 5)  # 5-year survival
cf[, years_97pct := quantiles_surv$lower / 365.25]
cf[, surv_5yr_lower := surv_5_year$lower[1,]]
cf[, surv_5yr := surv_5_year$surv[1,]]
cf[, surv_5yr_upper := surv_5_year$upper[1,]]

# Calculate drive stats and combine with summary stats
dat <- drive_dates[,list(
  n_unique=length(collapse::funique(serial_number)),
  drive_days = sum(days),
  capacity_tb = max(capacity_tb),
  naive_age_med = as.numeric(median(days)),
  naive_age_mean = as.numeric(mean(days)),
  failed = sum(failed)
), by='model']
dat[,model := as.character(model)]
dat <- merge(dat, cf, by='model', all=F)

# Order data and select columns
dat <- dat[order(
  -surv_5yr_lower, -surv_5yr, surv_5yr_upper,
  -years_97pct,
  -drive_days, -n_unique, failed, -capacity_tb),]
dat <- dat[, list(
  model, capacity_tb, n_unique,
  drive_days, failed, years_97pct,
  surv_5yr_lower, surv_5yr, surv_5yr_upper)]

# Save data for the write up
data.table::fwrite(dat, 'results/survival.csv')
saveRDS(cox_model, 'results/cox_model.rds')
