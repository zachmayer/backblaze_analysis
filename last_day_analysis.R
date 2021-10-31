# Setup
stop()
rm(list = ls(all=T))
gc(reset = T)
library(pbapply)
library(data.table)
library(stringi)
library(ggplot2)
library(ggthemes)
source('helpers.r')

################################################################
# Setup data
################################################################
set.seed(110001)

# Choose files
data_dir <- 'data/'
all_files <- list.files(data_dir)
all_files <- sample(all_files)
x <- all_files[1]

# Load the drive dates data
keys <- c('model', 'serial_number', 'date')
drive_dates <- fread('drive_dates.csv')
drive_dates[,date := max_date]
drive_dates[is.finite(first_fail), date := first_fail]
drive_dates[,age_days := as.integer(date - min_date)]
drive_dates_subset <- drive_dates[,list(model, serial_number, date, age_days)]
drive_dates_subset[, model := string_normalize(model)]
drive_dates_subset[, serial_number := string_normalize(serial_number)]
setkeyv(drive_dates_subset, keys)

# TODO: add gaps
# TODO: drop drives with large gaps?

# Load the data
t1 <- Sys.time()
dat_list <- pblapply(all_files, function(x) {  # Takes ~30 minutes

  # Bookkeeping
  gc(reset=T)

  # Load data
  dat <- fread(paste0(data_dir, x), showProgress=F)

  # Normalize
  dat[,serial_number := string_normalize(serial_number)]
  dat[,model := string_normalize(model)]

  # Merges
  setkeyv(dat, keys)
  dat <- merge(drive_dates_subset, dat, sby=keys)

  # Drops
  dat[,capacity_bytes := NULL]

  #Return
  if(nrow(dat) > 0){
    return(dat)
  }
})
time_diff <- as.numeric(Sys.time() - t1)
print(time_diff)

# Join data
# TODO: CACHE THIS FILE
dat <- rbindlist(dat_list, fill=T, use.names=T)

# Replace NA with zero
smart_stats <- names(dat)[grepl('smart_', names(dat), fixed=T)]
for(var in smart_stats){
  set(dat, j=var, value = as.numeric(dat[[var]]))
  set(dat, i=which(is.na(dat[[var]])), j=var, value=0)
}
gc(reset=T)

# Drop constant numeric columns
nums <- sapply(dat, is.numeric)
singles <- sapply(dat, function(x) length(unique(x)) < 2)
num_singles <- nums & singles
remove_vars <- names(num_singles)[num_singles]
#print(remove_vars)
for(var in remove_vars){
  set(dat, j=var, value=NULL)
}

# Order
dat[,date := NULL]
setkeyv(dat, c('model', 'serial_number'))

################################################################
# Run DR
################################################################

# Start project
library(datarobot)
projectObject = SetupProject(dat)
readr::write_lines(projectObject$projectId, 'pid.txt')
sink <- UpdateProject(projectObject, workerCount=25, holdoutUnlocked=TRUE)
st <- SetTarget(
  project=projectObject,
  target="failure",
  targetType='Binary',
  metric='FVE Binomial',
  partition=CreateStratifiedPartition(validationType='CV', holdoutPct=0, reps=10),
  smartDownsampled=FALSE,
  mode='comprehensive',
  seed=35569,
  maxWait=600)

# Run repo models
bps <- ListBlueprints(projectObject)
new <- pblapply(bps, function(bp){
  tryCatch({
    out <- RequestNewModel(projectObject$projectId, bp, scoringType='crossValidation')
  }, error=function(e) warning(e))
})

# Lookit
ViewWebProject(projectObject$projectId)
