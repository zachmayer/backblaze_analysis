  # Setup
  stop()
  rm(list = ls(all=T))
  gc(reset = T)
  library(data.table)
  library(kit)
  library(survival)
  library(ggthemes)
  days_to_year <- 365.2425
  
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
  
  # Join data
  # dat <- merge(drive_dates, capacity_map, by='model', all=F)
  # dat <- dat[,list(model, size, serial_number, days, failed)]
  # dat[,sort(table(size))]
  
  # Fit a survival model
  surv_model <- drive_dates[,survfit(Surv(time=days, failed) ~ 0 + model)]
  
  # Calculate survival days for the 99th percentile for each drive
  surv_days_99 <- quantile(surv_model, 0.01)
  surv_days_99 <- data.table(
    model = row.names(surv_days_99$quantile),
    survial_days_99_percent = surv_days_99$quantile[,1],
    survial_days_99_percent_lower = surv_days_99$lower[,1],
    survial_days_99_percent_upper = surv_days_99$upper[,1]
  )
  
  # Calculate survival rate at 2 years
  surv_pct_at_years <- summary(
    surv_model, times=10 * days_to_year, conf.int=.95, extend=TRUE
    )
  surv_pct_at_years <- data.table(
    model = surv_pct_at_years$strata,
    survival_pct_10_year = surv_pct_at_years$surv,
    survival_pct_10_year_lower = surv_pct_at_years$lower,
    survival_pct_10_year_upper = surv_pct_at_years$upper
  )
  
  # Combine survival statistics
  dat <- merge(surv_days_99, surv_pct_at_years, by='model', all=T)
  dat[,model := gsub('model=', '', model, fixed=T)]
  
  # Calculate drive stats and combine with summary stats
  drive_summary <- drive_dates[,list(
    n_unique=length(funique(serial_number)),
    drive_days = sum(days),
    failed = sum(failed)
  ), by='model']
  dat <- merge(drive_summary, dat, by='model', all=T)
  
  # Add drive TB
  dat <- merge(dat, capacity_map, by='model', all=F)
  dat <- dat[order(-survival_pct_10_year_lower), list(model, size, n_unique, drive_days, failed, survial_days_99_percent_lower, survival_pct_10_year_lower)]
  dat[!is.na(survival_pct_10_year_lower) & !is.na(survial_days_99_percent_lower),]
