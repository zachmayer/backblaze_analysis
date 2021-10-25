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
# 1. Compute lags / diffs
# 2. Think about including 2015 (pre 2015 we're missing some smart stats I want)
# 3. Consider "smart sampling" to keep all failures but drop some non-failed rows

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
all_files <- all_files[year(all_dates) > 2015]
print(length(all_files) / length(list.files(data_dir)))

# Load the data
# https://www.backblaze.com/b2/hard-drive-test-data.html#overview-of-the-hard-drive-data
# https://en.wikipedia.org/wiki/S.M.A.R.T.
t1 <- Sys.time()
all_data <- pblapply(  # Takes ~15 minutes
  sample(all_files, SAMPLE_SIZE),
  function(x){
    out <- fread(
      paste0(data_dir, x), 
      select=c('model', 'serial_number', 'date', 'failure', smart_stats),
      colClasses=smart_classes,
      showProgress=F
    )
    out[,filename := x]
    out
  }
)
warnings()  # 222 / 224 / 226 not found
time_diff <- as.numeric(Sys.time() - t1)
all_data <- rbindlist(all_data, use.names=TRUE, fill=TRUE)

# Clean model
all_data[,model := string_normalize(model)]

# Add year/quarter
all_data[,year := year(date)]
all_data[,quarter := quarter(date)]
setkeyv(all_data, 'quarter')

# Determine last day of each quarter
keys <- c('serial_number', 'year', 'quarter')
all_data[,last_day := NULL]
N <- nrow(all_data)
all_data[,last_day := (1:.N) == which.max(date), by=keys]
print(nrow(all_data) / N)
rm(keys)

# Only keep the last day of the quarter
data_keep <- all_data[which(last_day),]
data_keep[,last_day := NULL]

# Replace NA with zero
for(var in smart_stats){
 set(data_keep, i=which(is.na(data_keep[[var]])), j=var, value=0)
}

# Drop data after the first failure
# Note that we need to key by model AND serial as there are some dupes
keys <- c('model', 'serial_number')
drive_dates <- fread('drive_dates.csv')[,list(model, serial_number, min_date, first_fail)]
setkeyv(data_keep, keys)
setkeyv(drive_dates, keys)
data_keep <- merge(data_keep, drive_dates, all.x=T, by=keys)
data_keep <- data_keep[is.na(first_fail) | date <= first_fail,]
rm(keys)

# Add drive age
data_keep[,drive_age_years := as.integer(date - min_date) / 365.24, by='serial_number']

# Reindex date as the start of the quarter
data_keep[, month := (quarter-1)*3 + 1]
data_keep[,table(quarter, month)]
data_keep[,date := as.Date(ISOdate(year, month, 1))]
data_keep[,c('year', 'month', 'first_fail') := NULL]

# Reindex serial
data_keep[,serial_number := paste0('s', as.integer(factor(serial_number)))]

# Lag stats by 1 month - TODO!
# TODO: use SAFER?
keys <- c('serial_number', 'model', 'date')
setkeyv(data_keep, keys)

# Drop some columns
data_keep[,min_date := NULL]
data_keep[,quarter := NULL]
data_keep[,filename := NULL]

# Order columns
first_cols <- c('serial_number', 'model', 'date', 'drive_age_years', 'failure')
all_cols <- c(first_cols, setdiff(names(data_keep), first_cols))
setcolorder(data_keep, all_cols)
setkeyv(data_keep, first_cols)

# Save
fwrite(data_keep, '~/Downloads/drive_failure_discrete_time_smart_model.csv')

# Stats
(time_diff / SAMPLE_SIZE) * length(all_files) # Minutes to read
((nrow(data_keep) / SAMPLE_SIZE) * length(all_files)) / 1e6 # Millions of rows
as.numeric((object.size(data_keep) / SAMPLE_SIZE) * length(all_files) / 1e+9)  # GB
