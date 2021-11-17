# Setup
stop()
rm(list = ls(all=T))
gc(reset = T)
library(pbapply)
library(data.table)
source('helpers.r')
set.seed(110001)
SAMPLE_SIZE <- 2008

# TODO:
# Consider stratified sampling: once we've ID'd important smart stats, sample where those >0

# SMART stats I want to keep
count_stats <- c(2, 3, 4, 5, 9, 10, 12, 187, 188, 189, 196, 197, 198, 201, 222, 223, 224, 226)
smart_stats <- paste('smart', count_stats, 'raw', sep='_')
smart_classes <- rep('integer', length(smart_stats))
names(smart_classes) <- smart_stats
smart_classes['smart_188_raw'] <- 'integer64'
smart_classes['smart_201_raw'] <- 'integer64'

# Choose files
# Smart stats 222/224/226 start in 2015
data_dir <- 'data/'
all_files <- list.files(data_dir)
all_dates <- as.Date(gsub('.csv', '', all_files, fixed=T))
all_files <- all_files[year(all_dates) >= 2015]
print(length(all_files) / length(list.files(data_dir)))

# Load the drive dates data
drive_dates <- fread('drive_dates.csv')

# Load the data
# https://www.backblaze.com/b2/hard-drive-test-data.html#overview-of-the-hard-drive-data
# https://en.wikipedia.org/wiki/S.M.A.R.T.
t1 <- Sys.time()
set.seed(110001)
all_data <- pblapply(  # Takes ~30 minutes
  sample(all_files, SAMPLE_SIZE),
  function(x){

    # Bookkeeping
    gc(reset=T)

    # Load data
    out <- fread(
      paste0(data_dir, x), 
      select=c('model', 'serial_number', 'date', 'failure', smart_stats),
      colClasses=smart_classes,
      showProgress=F
    )

    # If the drive failed today, we don't need to predict tomorrow
    out <- out[failure == 0,]
    out <- merge(out, drive_dates, all.x=T, by=c('model', 'serial_number'))

    # Calculate time to failure or time to censoring
    out[,days_to_failure := as.integer(first_fail - date)]
    out[,days_to_end := as.integer(max_date - date)]

    # Remove drives after the first failure
    # It seems that backblaze fixes some failures and redeploys the drives
    # I don't want to deal with repairing and redeploying drives
    # So I will consider the first failure as the end of the data
    out <- out[is.na(days_to_failure) | (days_to_failure > 0),]

    # Remove drives that end "today" for non-failure reasons
    out <- out[days_to_end > 0,]

    # Calculate a binary target variable
    out[,failed_tomorrow := as.integer(days_to_failure == 1)]
    out[is.na(days_to_failure), failed_tomorrow := 0]

    # Sample 1% of non-failed (and keep all failed)
    out[,rand := runif(.N)]
    number_old <- out[failed_tomorrow==0, .N]
    out <- out[failed_tomorrow==1 | rand < .01,]
    number_new <- out[failed_tomorrow==0, .N]
    out[failed_tomorrow==0, weight := number_old / number_new]
    out[failed_tomorrow==1, weight := 1]

    # Remove some cols and return
    # Keep min_date
    out[,c('max_date', 'first_fail') := NULL]
    out[,c('days_to_failure', 'days_to_end', 'rand', 'failure') := NULL]
    if(nrow(out) > 0){
      return(out)
    }
    return(NULL)
  }
)
warnings()  # 222 / 224 / 226 not found
time_diff <- as.numeric(Sys.time() - t1)

# Union the daily data into one big data table
gc(reset=T)
all_data <- rbindlist(all_data, fill=T, use.names = T)
gc(reset=T)
all_data[,table(failed_tomorrow) / .N] * 100

# Clean model name string
all_data[,model := string_normalize(model)]
gc(reset=T)

# Replace NA with zero
for(var in smart_stats){
 set(all_data, i=which(is.na(all_data[[var]])), j=var, value=0)
}
gc(reset=T)

# Add drive age
all_data[,drive_age_years := as.integer(date - min_date) / 365.24, by='serial_number']
gc(reset=T)

# Reindex serial
all_data[,serial_number := paste0('s', as.integer(factor(serial_number)))]
gc(reset=T)

# Order columns
first_cols <- c('serial_number', 'model', 'date', 'weight', 'drive_age_years', 'failed_tomorrow')
all_cols <- c(first_cols, setdiff(names(all_data), first_cols))
setcolorder(all_data, all_cols)
setkeyv(all_data, first_cols)

# Drop columns
all_data[,serial_number := NULL]
all_data[,min_date := NULL]
len_unique <- sapply(all_data, function(x) length(funique(x)))
for(col in names(len_unique[len_unique==1])){
  set(all_data, j=col, value=NULL)
}

# Save
summary(all_data)
fwrite(all_data, '~/Downloads/drive_failure_discrete_time_smart_model.csv')

# Stats
(time_diff / SAMPLE_SIZE) * length(all_files) # Minutes to read
((nrow(all_data) / SAMPLE_SIZE) * length(all_files)) / 1e6 # Millions of rows
as.numeric((object.size(all_data) / SAMPLE_SIZE) * length(all_files) / 1e+9)  # GB
