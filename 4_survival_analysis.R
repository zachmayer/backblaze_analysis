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
library(prodlim)

days_to_year <- 365.2425
custom_palette <- c(
  "#1f78b4", "#ff7f00", "#6a3d9a", "#33a02c", "#e31a1c", "#b15928",
  "#a6cee3", "#fdbf6f", "#cab2d6", "#b2df8a", "#fb9a99", "black",
  "grey1", "grey10"
)

# Todo:
# From a practical perspective, put a death in at time 1, and multiply the resulting survival estimates and CIs by (N+1)/N.
# http://www.medicine.mcgill.ca/epidemiology/hanley/bios601/SurvivalAnalysis/MiettinenUpFromKaplanMeierGreenwood.pdf

# Load data
capacity_map <- fread('capacity_map.csv')
drive_dates <- fread('drive_dates.csv')

# Format HD sizes nicely
format_hd_size <- function(x, ...){
  utils:::format.object_size(x, ..., standard='SI', digits=0)
}
capacity_map[capacity_bytes <  1e+12, size := format_hd_size(capacity_bytes, 'GB')]
capacity_map[capacity_bytes >= 1e+12, size := format_hd_size(capacity_bytes, 'TB')]

capacity_order <- capacity_map[,list(capacity_bytes=max(capacity_bytes)), by='size']
capacity_order <- capacity_order[order(capacity_bytes),]
capacity_map[,size := factor(size, levels=capacity_order[,size], ordered=T)]

# Computer drive failure, and time to failure or time to censoring
drive_dates[,failed := as.integer(is.finite(first_fail))]
drive_dates[is.finite(first_fail), max_date := first_fail]
drive_dates[,days := as.integer(max_date - min_date)]
drive_dates[,model := factor(model)]

# Fit a cox model
ref_level <- drive_dates[,list(days=sum(days), .N), by='model'][which.max(days), as.character(model)]
drive_dates[,model := factor(model)]
drive_dates[,model := relevel(model, ref=ref_level)]
cox_model <- drive_dates[,coxph(Surv(time=days, failed) ~ 1 + model)]
cox_model_hazard <- basehaz(cox_model)

# Extract cox model coefficients
cf <- coef(summary(cox_model))
cf <- data.table(model=row.names(cf), cf)
cf[,upper_ci := coef + `se(coef)`]
cf[, model := gsub('model', '', model,fixed=T)]
cf <- cf[order(upper_ci),]
head(cf, 25)

# Fit a cox model
cf <- summary(cox_model)
cf <- data.table(model=row.names(cf$conf.int), cf$conf.int)
cf <- cf[order(`upper .95`),]
head(cf[is.finite(`upper .95`),], 50)

# Calculate survival days for the 99th percentile for each drive
surv_days_99 <- quantile(surv_model, .01)
surv_days_99 <- data.table(
  model = names(surv_days_99),
  rbindlist(lapply(surv_days_99, function(x) data.table(x)), use.names = T, fill=T)
)
setnames(
  surv_days_99, 
  c('quantile', 'lower', 'upper'),
  c('survial_days_99_percent', 'survial_days_99_percent_lower', 'survial_days_99_percent_upper')
  )

# Calculate survival rate at 5 years
surv_pct_at_years <- summary(
  surv_model, times=1 * days_to_year, conf.int=.9999, extend=TRUE, max.tables=999999,
  intervals=T
  )$table
surv_pct_at_years <- data.table(
  model = names(surv_pct_at_years),
  rbindlist(lapply(surv_pct_at_years, function(x) data.table(x)), use.names = T, fill=T)
)
surv_pct_at_years <- data.table(
  model = surv_pct_at_years$model,
  survival_pct_1_year = surv_pct_at_years$surv,
  survival_pct_1_year_lower = surv_pct_at_years$lower,
  survival_pct_1_year_upper = surv_pct_at_years$upper
)

# Combine survival statistics
dat <- merge(surv_days_99, surv_pct_at_years, by='model', all=T)
dat[,model := gsub('model=', '', model, fixed=T)]

# Calculate drive stats and combine with summary stats
drive_summary <- drive_dates[,list(
  n_unique=length(funique(serial_number)),
  drive_days = sum(days),
  naive_age_med = as.numeric(median(days)),
  naive_age_mean = as.numeric(mean(days)),
  failed = sum(failed)
), by='model']
drive_summary[model %in% model_list,]
dat <- merge(drive_summary, dat, by='model', all=T)

# Add drive TB
dat <- merge(dat, capacity_map, by='model', all=F)

# Show data
dat <- dat[, list(
  model, size, n_unique, drive_days, failed, survial_days_99_percent, 
  survival_pct_1_year_lower, pois_ci, naive_age_med, naive_age_mean)]

# Best by 1-year rate
dat[!is.na(survival_pct_1_year_lower),][order(-survival_pct_1_year_lower),]

# Best by percentile
dat[!is.na(survial_days_99_percent),][order(-survial_days_99_percent),]

# Best by pois
dat[!is.na(pois_ci),][order(-pois_ci),]



# Plot survival curves for the best drives by size
plot_dat <- drive_dates[model %in% model_list,]
plot_dat <- merge(plot_dat, capacity_map, by='model')
plot_dat[,table(factor(model), factor(size))]
out <- ggsurvplot(
  plot_dat[, survfit(Surv(time=days / 365.25, failed) ~ 1 + size)], 
  data=plot_dat, 
  palette = custom_palette, conf.int = T, ylim=c(.93, 1.0), xlab = "Time (years)", breaks = 1:5)
print(out)