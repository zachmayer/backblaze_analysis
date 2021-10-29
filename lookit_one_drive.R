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
drive_dates[,days_to_fail := as.integer(first_fail - min_date)]
lookit_me <- drive_dates[!is.na(first_fail),][order(-days_to_fail),][1, serial_number]

# Load the data
# https://www.backblaze.com/b2/hard-drive-test-data.html#overview-of-the-hard-drive-data
# https://en.wikipedia.org/wiki/S.M.A.R.T.
t1 <- Sys.time()
set.seed(110001)
dat_list <- pblapply(  # Takes ~30 minutes
  sample(all_files, SAMPLE_SIZE),
  function(x){
    
    # Bookkeeping
    gc(reset=T)
    
    # Load data
    dat <- fread(
      paste0(data_dir, x), 
      select=c('model', 'serial_number', 'date', 'failure', smart_stats),
      colClasses=smart_classes,
      showProgress=F
    )
    
    # Subset
    dat <- dat[serial_number==lookit_me,]
    
    #Return
    return(dat)
  }
)
warnings()  # 222 / 224 / 226 not found
time_diff <- as.numeric(Sys.time() - t1)

# Rbind
dat <- rbindlist(dat_list, use.names=T, fill=T)
summary(dat)
