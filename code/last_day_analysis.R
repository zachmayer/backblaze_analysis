# Setup
stop()
rm(list = ls(all=T))
gc(reset = T)
library(pbapply)
library(data.table)
library(bit64)
library(stringi)
library(ggplot2)
library(ggthemes)
library(future)
library(compiler)
library(xgboost)
library(datarobot)
source('code/helpers.r')

# TODO: rowwise count of zeros
# TODO: rowwise count of NAs (after dropping constant columns)
# TODO: try a survival xgboost, crib tuning from best DR model (which looks like XGB)
# TODO: use 30 days prior to censoring as target for 0
# TODO: Predict in sample, and look at prediciton over time for failed drives: does it start to go up as we get to the failure date?  Plot this for all failed drives to see how far out we may be able to predict failures

################################################################
# Load raw data
################################################################
set.seed(110001)

# Choose files
data_dir <- 'data/'
all_files <- list.files(data_dir)
x <- all_files[1]

# Load the drive dates data
keys <- c('model', 'serial_number', 'date')
drive_dates <- fread('results/drive_dates.csv')
drive_dates[,date := max_date]
drive_dates[is.finite(first_fail), date := first_fail]
drive_dates[,age_days := as.integer(date - min_date)]
drive_dates_subset <- drive_dates[,list(model, serial_number, date, age_days)]
drive_dates_subset[, model := string_normalize(model)]
drive_dates_subset[, serial_number := string_normalize(serial_number)]
setkeyv(drive_dates_subset, keys)

# Only keep dates where a drive failed
last_days_only <- drive_dates_subset[,stri_paste(sort(funique(date)), '.csv')]
all_files <- sort(intersect(all_files, last_days_only))

# TODO: add gaps
# TODO: drop drives with large gaps?

# Data processing function
load_last_day_only <- cmpfun(function(x){
  future({
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
    return(dat)
  })
})

# Load the data
set.seed(42)
all_files <- sample(all_files)
print(paste('~', round((0.006656703 * length(all_files))),  'minutes'))
plan(multisession, workers=24)
t1 <- Sys.time()
# availableCores()
dat_list_futures <- pblapply(all_files, load_last_day_only)  # Start the jobs
dat_list <- pblapply(sample(dat_list_futures), value)  # Wait for them to finish
time_diff <- as.numeric(Sys.time() - t1)
print(time_diff)
print(time_diff / length(all_files))

################################################################
# Make one big data table
################################################################

# Join data
dat <- rbindlist(dat_list, fill=T, use.names=T)

# Convert to numeric and optionally replace NA with 0
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
setkeyv(dat, c('model', 'age_days', 'failure', 'smart_9_raw'))

# Save data
# dat[,serial_number := NULL]
last_day_file <- 'results/last_day_data.csv'
fwrite(dat, last_day_file)

dat[,summary(as.integer64(smart_241_raw))]

################################################################
# Survival XGboost
################################################################

# dat <- fread(last_day_file, colClasses=c(smart_241_raw='int64'))

# Set factor order
#dat[,list(.N), by='model'][order(N, model), model]

dat[,smart_9_raw_per_day := smart_9_raw / age_days]
dat[!is.finite(smart_9_raw_per_day), smart_9_raw_per_day := 0]

dat[,gb_write_per_day := ((smart_241_raw * 512) / 8e+9) / age_days]  # this is a guess
dat[!is.finite(gb_write_per_day), gb_write_per_day := 0]
dat[,summary(gb_write_per_day)]

dat[,gb_read_per_day := ((smart_242_raw * 512) / 8e+9) / age_days]  # this is a guess
dat[!is.finite(gb_read_per_day), gb_read_per_day := 0]
dat[,summary(gb_read_per_day)]

dat[,start_stop_per_day := smart_4_raw / age_days]
dat[!is.finite(start_stop_per_day), start_stop_per_day := 0]
dat[,summary(start_stop_per_day)]

subset_smart <- c(
  'gb_write_per_day',
  'gb_read_per_day',
  # 'smart_241_raw',  # Total LBAs Written
  # 'smart_242_raw',  # Total LBAs Read
  'smart_193_raw',  # Load Cycle Count
  'smart_197_raw',  # Current Pending Sector Count
  'smart_192_raw',  # Power-off Retract Count
  'smart_9_raw_per_day',
  # 'smart_9_raw',  # Power-On Hours
  'smart_1_normalized', # Read Error Rate
  'smart_5_raw',  # Reallocated Sectors Count
  'smart_195_normalized',  # Hardware ECC Recovered
  'smart_189_raw',  # High Fly Writes
  'smart_187_normalized',  # Reported Uncorrectable Errors
  'smart_7_normalized', # Seek Error Rate
  'start_stop_per_day',
  # 'smart_4_raw', # 	Start/Stop Count
  'smart_190_normalized', # Temperature Difference or Airflow Temperature
  'smart_2_normalized', # Throughput Performance
  'smart_194_raw', # Temperature or Temperature Celsius
  'smart_8_raw' # Seek Time Performance
  )

crs <- cor(dat[,age_days], dat[,subset_smart,with=F], use = "pairwise.complete.obs")
sort(abs(crs[1,]), decreasing = T)

# Setup XGboost data
# https://xgboost.readthedocs.io/en/latest/tutorials/aft_survival_analysis.html
all_smart <- names(dat)[grepl('smart', names(dat))]
X <- data.matrix(dat[,c('model', subset_smart), with=F])
y_upper <- dat[,age_days]
y_upper <- dat[,ifelse(failure==1, age_days, Inf)]
y <- dat[,ifelse(failure==1, age_days, -age_days)]

# dtrain = xgb.DMatrix(X, label=y, label_lower_bound=y_upper, label_upper_bound=y_upper)  # AFT
dtrain = xgb.DMatrix(X, label=y)  # COX

# CV XGboost model
params <- list(
  objective='survival:cox',
  #aft_loss_distribution='extreme',
  #eval_metric='rmse',
  tree_method='hist',
  learning_rate=0.1,
  max_depth=4,
  base_score=1
)
xgb_model_cv <- xgb.cv(params, dtrain, nrounds=500, nfold=10)

# Plot model training
plot_data <- data.table(xgb_model_cv$evaluation_log)
best_iter <- plot_data[which.min(test_cox_nloglik_mean), iter]
print(plot_data[best_iter,])

ggplot(plot_data, aes(x=iter)) +
  geom_line(aes(y=train_cox_nloglik_mean, col='train')) +
  geom_line(aes(y=test_cox_nloglik_mean, col='valid')) +
  ylab('cox_nloglik') +
  scale_color_manual(values=custom_palette) +
  theme_tufte()

# Fit final model
xgb_model <- xgb.train(params, dtrain, nrounds=best_iter)
dat[,pred := predict(xgb_model, dtrain)]

# Lookit results - bad drives
ref_level <- string_normalize('HGST HMS5C4040BLE640')
lookit_vars <- c('pred', 'model', 'serial_number', 'age_days', subset_smart)
dat[failure==0 & model == ref_level & age_days > 365,][which.max(pred),][,lookit_vars,with=F]
dat[failure==1 & model == ref_level & age_days > 365,][which.max(pred),][,lookit_vars,with=F]

dat[failure==0 & age_days > 365][which.max(pred),][,lookit_vars,with=F]
dat[failure==1 & age_days > 365,][which.max(pred),][,lookit_vars,with=F]

# Lookit results - good drives
dat[failure==0 & age_days > 365][which.min(pred),][,lookit_vars,with=F]
dat[failure==1 & age_days > 365,][which.min(pred),][,lookit_vars,with=F]

# Find interactions
# https://cran.r-project.org/web/packages/EIX/vignettes/EIX.html
library(EIX)
pairs <- interactions(xgb_model, X, option = "interactions")
pairs <- data.table(pairs)[order(-sumGain),]
head(pairs, 10)

# Looking worst drive
row <- dat[,which.max(pred)]
#dat[row,]
wf <- waterfall(xgb_model, X[row,], X[row,], type='regression', option='interactions', baseline=0)
wf
plot(wf)

################################################################
# Run DR
################################################################

# Load the cached data and project object
# Note that projectObject will be overwitten by a NEW project below when you run SetupProject
# You can manually skip the `start project` block if you wish to just load an old project
# dat <- fread('last_day_data.csv')
# projectObject <- GetProject(readr::read_lines('results/pid.txt'))

# Start project
projectObject = SetupProject(dat[,c('model', 'failure', 'age_days', subset_smart), with=F])
readr::write_lines(projectObject$projectId, 'pid.txt')
sink <- UpdateProject(projectObject, workerCount=25, holdoutUnlocked=TRUE)
st <- SetTarget(
  project=projectObject,
  target="failure",
  targetType='Binary',
  metric='FVE Binomial',
  partition=CreateStratifiedPartition(validationType='CV', holdoutPct=0, reps=5),
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
Sys.sleep(3600*5)
models <- c(ListBlueprints(projectObject), ListModels(projectObject))
bps <- sort(unique(sapply(models, '[[', 'blueprintId')))
new <- pblapply(bps, function(bp){
  try_model(projectObject, bp, 'crossValidation')
  try_model(projectObject, bp, 'validation')
  Sys.sleep(0.1)
})

# Run feature impact
Sys.sleep(3600*5)
best_model <- ListModels(projectObject)[[1]]
featureImpactJobId <- RequestFeatureImpact(best_model)

# Wait a few minutes and run feature fit
# TODO
Sys.sleep(60*5)

# Lookit the project
ViewWebProject(projectObject)
