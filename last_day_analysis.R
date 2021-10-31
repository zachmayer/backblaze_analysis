# Setup
stop()
rm(list = ls(all=T))
gc(reset = T)
library(pbapply)
library(data.table)
library(stringi)
library(ggplot2)
library(ggthemes)
library(datarobot)
source('helpers.r')

# TODO: organize files into folders:
# code in one folder
# data in another
# re-write code files to use the folders
# TODO: run string_normalize on model/serial in all raw data read

################################################################
# Load raw data
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
dat_list <- pblapply(all_files, function(x) {  # Takes ~60 minutes

  # print(x)

  # Bookkeeping
  gc(reset=T)

  # Load data
  dat <- fread(paste0(data_dir, x), showProgress=F)
  if(nrow(dat) < 1){  # TODO: find which file is blank!
    return(NULL)
  }

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

################################################################
# Make one big data table
################################################################

# Join data
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

# Order and drop vars
setkeyv(dat, c('model', 'serial_number'))
dat[,date := NULL]
dat[,serial_number := NULL]
setkeyv(dat, c('model', 'age_days', 'failure', 'smart_9_raw'))

# Save data
last_day_file <- 'last_day_data.csv'
fwrite(dat, last_day_file)

################################################################
# Run DR
################################################################

# Start project
projectObject = SetupProject(last_day_file)
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

# Function to run repo models
try_model <- function(pid, bp, scoringType='crossValidation', samplePct=NULL){
  tryCatch({
    suppressMessages({
      RequestNewModel(pid, list(
        projectId=pid$projectId,
        created=pid$created,
        projectName=pid$projectName,
        fileName=pid$fileName,
        blueprintId=bp
      ), scoringType=scoringType, samplePct=samplePct)
    })
  }, error=function(e) warning(e))
}

# Run repo models
models <- c(ListBlueprints(projectObject), ListModels(projectObject))
bps <- sort(unique(sapply(models, '[[', 'blueprintId')))
new <- pblapply(bps, function(bp){
  try_model(projectObject, bp, 'crossValidation')
  try_model(projectObject, bp, 'validation')
  Sys.sleep(0.1)
})

# Wait a few hours and run feature impact
Sys.sleep(3600*5)
best_model <- ListModels(project)[[1]]
featureImpactJobId <- RequestFeatureImpact(best_model)

# Wait a few minutes and run feature fit
# TODO
Sys.sleep(60*5)

# Lookit the project
ViewWebProject(projectObject$projectId)
