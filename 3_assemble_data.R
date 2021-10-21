# Setup
stop()
rm(list = ls(all=T))
gc(reset = T)
library(pbapply)
library(data.table)
library(compiler)
library(fastmatch)
library(kit)

# Load the data
# NOTE: 54+ drives have more than one "failure" day
# I *think* this means that the drive failure was fixed, and the drive was re-deployed
# HOWEVER; I don't want to fix my own drives, so I am going to consider any "failure"
# to be game ove
data_dir <- 'data/'
all_files <- list.files(data_dir)
all_data <- pblapply(  # Takes ~18 minutes
  all_files,
  function(x){
    out <- fread(
      paste0(data_dir, x), 
      select=c('model', 'serial_number', 'failure', 'capacity_bytes'),
      colClasses=c(capacity_bytes='numeric') # We lose a tiny bit of precision, but who cares
    )
    out[,filename := x]
  }
)
all_data <- rbindlist(all_data, use.names=TRUE, fill=TRUE)
all_data[,capacity_bytes := as.integer(capacity_bytes)]

# Filename to date
file_to_date <- cmpfun(function(x){
  x_unique <- sort(funique(x))
  x_map <- fmatch(x, x_unique)
  x_date <- as.Date(gsub('.csv', '', x_unique, fixed=T))
  return(x_date[x_map])
})
all_data[,date := file_to_date(filename)]

# Data quality checks=: bad capacity
all_data[,sort(funique(capacity_bytes))]
all_data[capacity_bytes == "-1", summary(date)]
all_data[capacity_bytes == "-9116022715867848704", summary(date)]
gc(reset=T)

# Capacity map
capacity_map <- all_data[,list(model, capacity_bytes)]
capacity_map[,capacity_bytes := as.numeric(capacity_bytes)]
setkeyv(capacity_map, 'capacity_bytes')
gc(reset=T)
capacity_map <- capacity_map[which(capacity_bytes > 0),]  # HDs can't have negative capacity
capacity_map <- capacity_map[which(capacity_bytes < 1e+15),]  # 1 PetaByte drives don't exist yet
setkeyv(capacity_map, 'model')
capacity_map <- capacity_map[,list(capacity_bytes=max(capacity_bytes)), by='model']
fwrite(capacity_map, 'capacity_map.csv')
gc(reset=T)

# Calculate dates by serial number
setkeyv(all_data, c('model', 'serial_number'))
drive_dates <- all_data[, list(
  min_date = min(date),
  max_date = max(date),
  first_fail = min(date[failure==1])), by=c('model', 'serial_number')]
fwrite(drive_dates, 'drive_dates.csv')
