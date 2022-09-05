# Setup
rm(list = ls(all=T))
gc(reset = T)
library(pbapply)
library(data.table)
source('code/helpers.r')

# Load the data
# NOTE: 54+ drives have more than one "failure" day
# I *think* this means that the drive failure was fixed, and the drive was re-deployed
# HOWEVER; I don't want to fix my own drives, so I am going to consider any "failure"
# to be game over
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
# all_data[serial_number=='9JG4657T',]

# Cleanup model names
all_data[,model := string_normalize(model)]

# Filename to date
all_data[,date := file_to_date(filename)]
# all_data[serial_number=='9JG4657T',]

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
fwrite(capacity_map, 'results/capacity_map.csv')
gc(reset=T)

# Calculate dates by serial number
keys <- c('model', 'serial_number')
setkeyv(all_data, keys)
drive_dates <- all_data[, list(
  min_date = min(date),
  max_date = max(date),
  first_fail = min(date[failure==1])), by=keys]
fwrite(drive_dates, 'results/drive_dates.csv')
# drive_dates[serial_number=='9JG4657T',]

# Check that each unique serial has one unique model
# Some manufacturers do re-use serials, so there will be some dupes
# But it should be a very small number
duplicate_serials <- drive_dates[,list(N=length(funique(model))), by='serial_number'][N>1,]
stopifnot(nrow(duplicate_serials) < 10)
duplicate_serials
