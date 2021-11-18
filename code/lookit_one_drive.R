# Setup
stop()
rm(list = ls(all=T))
gc(reset = T)
library(pbapply)
library(data.table)
library(stringi)
library(ggplot2)
library(ggthemes)
source('code/helpers.r')
set.seed(110001)

# 2 drives with high failure scores from the last_day_analysis
keep_drives <- rbindlist(
  list(
    data.table(model='hgst hms5c4040ble640', serial_number='pl2331lah4zldj'),  # didn't fail
    data.table(model='hgst hms5c4040ble640', serial_number='pl1331lahd3t1h')  # did fail
  )
)
keep_drives[,model := string_normalize(model)]
keep_drives[,serial_number := string_normalize(serial_number)]

################################################################
# Load raw data
################################################################
set.seed(110001)

# Choose files
data_dir <- 'data/'
all_files <- list.files(data_dir)

# Load the drive dates data
drive_dates <- fread('results/drive_dates.csv')
drive_dates[,model := string_normalize(model)]
drive_dates[,serial_number := string_normalize(serial_number)]
drive_dates <- merge(drive_dates, keep_drives, by=names(keep_drives))

# Only keep dates where a drive failed
only_these_drives <- drive_dates[,seq.Date(min(min_date), max(max_date), by='days')]
only_these_drives <- stri_paste(only_these_drives, '.csv')
all_files <- sort(intersect(all_files, only_these_drives))

# subset cols
keys <- c('model', 'serial_number')
drive_dates <- drive_dates[,keys,with=F]
setkeyv(drive_dates, keys)

# Select vars
keep <- c(
  'date',
  'serial_number',
  'model',
  'smart_241_raw',  # Total LBAs Written
  'smart_193_raw',  # Load Cycle Count
  'smart_197_raw',  # Current Pending Sector Count
  'smart_192_raw',  # Power-off Retract Count
  'smart_242_raw',  # Total LBAs Read
  'smart_9_raw',  # Power-On Hours
  'smart_1_normalized', # Read Error Rate
  'smart_5_raw'  # Reallocated Sectors Count
)

# Data processing function
load_last_day_only <- cmpfun(function(x){
  future({
    # Load data
    dat <- fread(paste0(data_dir, x), select=keep, showProgress=F)
    if(nrow(dat) < 1){  # TODO: find which file is blank!
      return(NULL)
    }

    # Normalize
    dat[,serial_number := string_normalize(serial_number)]
    dat[,model := string_normalize(model)]

    # Merges
    setkeyv(dat, keys)
    dat <- merge(drive_dates, dat, by=keys)

    #Return
    return(dat)
  })
})

# Load the data
set.seed(42)
all_files <- sample(all_files)
print(paste('~', round((0.004318525 * length(all_files))),  'minutes'))
plan(multisession, workers=24)
t1 <- Sys.time()
dat_list_futures <- pblapply(all_files, load_last_day_only)  # Start the jobs
dat_list <- pblapply(sample(dat_list_futures), value)  # Wait for them to finish
time_diff <- as.numeric(Sys.time() - t1)
print(time_diff)
print(time_diff / length(all_files))

################################################################
# Plot
################################################################

smart_stats <- names(dat)[grepl('smart_', names(dat), fixed=T)]
plot_dat <- melt.data.table(dat[,c('date', smart_stats), with=F], id.vars = c('date'))
plot_dat[,value := (value - min(value)) / diff(range(value)), by='variable']
ggplot(plot_dat, aes(x=date, y=value, color=variable)) +
  geom_point()+ theme(legend.position="top") + theme_tufte() +
  scale_color_manual(values=custom_palette)

for(var in sort(unique(plot_dat[['variable']]))){
  print({
    ggplot(plot_dat[variable == var,], aes(x=date, y=value, color=variable)) +
      geom_point()+ theme(legend.position="top") + theme_tufte() +
      scale_color_manual(values=custom_palette) + ggtitle(var)
  })
}

# fail cor
sort(abs(cor(dat[,smart_stats, with=F], dat[['failure']])[,1]))
