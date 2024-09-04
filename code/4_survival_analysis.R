library(ggthemes)
library(survminer)
source('code/helpers.r')

# Load data
drive_dates <- data.table::fread('results/drive_dates.csv')[capacity_tb >= 1,]  # Exclude small drives

# Calculate time to failure or time to censoring
drive_dates[,days := as.numeric(max_date - min_date)]

# Combine some low-data drives
drive_dates[,list(.N, days=sum(days), failed=sum(failed)) , by='model'][failed==0,]

# Choose the "reference" class based
ref_level <- 'hgst hms5c4040ble640'  # Reliable 4TB drive with lots of drives and drive days
drive_dates[,model := factor(model)]
drive_dates[,model := relevel(model, ref=ref_level)]

# Try glmnet
set.seed(42)
drive_dates[days == 0, days := 1/24.0]
x <- drive_dates[, Matrix::sparse.model.matrix(~ model)]
y <- drive_dates[, as.matrix(data.table::data.table(time=days, status=failed))]
t1 <- Sys.time()
fit <- glmnet::cv.glmnet(x, y, family = "cox", standardize=F, trace.it=1L, alpha=0.1, nlambda=25L, intercept=F, nfolds=5L, grouped=T)
t2 <- Sys.time()
print(t2 - t1)
plot(fit)
print(fit)  # 19.29
plot(survival::survfit(fit, s = 0.05, x = x, y = y))

# Fit the cox model
cox_model <- drive_dates[,survival::coxph(survival::Surv(time=days, failed) ~ 1 + model, x=T)]
summary(cox_model)
survival::cox.zph(cox_model)

# Fit exponential survival model
exp_model <- drive_dates[days>0, survival::survreg(survival::Surv(time=days, failed) ~ model, dist = "exponential")]


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
i <- 0
pb = txtProgressBar(min = 0, max = length(cf[['model']]), initial = 0, style=3)
for(m in cf[['model']]){
  cox_surv_curve <- survfit(cox_model, conf.int=CONF_LEVEL, newdata=data.table(model=m), conf.type="logit")
  quantile_surv <- quantile(cox_surv_curve, .03)
  surv_5_year <- summary(cox_surv_curve, conf.int=CONF_LEVEL, 1 * days_to_year)

  cf[model == m, years_97pct := quantile_surv[["lower"]] / 365.25]
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
  -years_97pct,
  -drive_days, -n_unique, failed, -size),]
dat <- dat[, list(
  model, size, n_unique,
  drive_days, failed, years_97pct,
  surv_5yr_lower, surv_5yr, surv_5yr_upper)]

# Save data for the write up
fwrite(dat, 'results/survival_results.csv')
saveRDS(cox_model, 'results/cox_model.rds')
