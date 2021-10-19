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
library(muhaz)
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

# Choose the "reference" class based on the drive with the most days
ref_level <- drive_dates[,list(days=max(days), .N), by='model'][which.max(days), as.character(model)]
drive_dates[,model := factor(model)]
drive_dates[,model := relevel(model, ref=ref_level)]
cox_model <- drive_dates[,coxph(Surv(time=days, failed) ~ 1 + model, x=T)]

# Extract baseline hazard
models <- drive_dates[,list(days=10 * days_to_year, failed=0), by='model']
surv_10_year_log <- predict(cox_model, newdata=models, type='expected', se.fit=T)
surv_10_year <- exp(-(surv_10_year_log$fit + surv_10_year_log$se.fit))
models[,surv_10_year := surv_10_year]

# Extract cox model coefficients
cf <- summary(cox_model)
cf <- data.table(model=row.names(cf$conf.int), cf$conf.int)
cf[,model := gsub('model', '', model, fixed=T)]

# Calculate survival rate at 10 years
surv_pct_at_years <- summary(cox_model_curve, times=10 * days_to_year, extend=TRUE)

# Add 99% / 5 years to table
cf[,surv_10_years_lower := (1 - `upper .95`) * surv_pct_at_years$surv]
cf[,surv_10_years := (1 - `exp(coef)`) * surv_pct_at_years$surv]
cf[,surv_10_years_upper := (1 - `lower .95`) * surv_pct_at_years$surv]

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

# Show data
dat <- dat[order(-surv_10_years_lower), list(
  model, size, n_unique, drive_days, failed, 
  surv_10_years_lower, surv_10_years, surv_10_years_upper, naive_age_med)]
dat[!is.na(surv_10_years_lower),]

# Plot survival curves for the best drives by size
plot_dat <- drive_dates[model %in% model_list,]
plot_dat <- merge(plot_dat, capacity_map, by='model')
plot_dat[,table(factor(model), factor(size))]
out <- ggsurvplot(
  plot_dat[, survfit(Surv(time=days / 365.25, failed) ~ 1 + size)], 
  data=plot_dat, 
  palette = custom_palette, conf.int = T, ylim=c(.93, 1.0), xlab = "Time (years)", breaks = 1:5)
print(out)