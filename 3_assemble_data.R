# Setup
library(pbapply)
library(data.table)

# Load the data
data_dir <- 'data/'
all_files <- list.files(data_dir)
all_data <- pblapply(
  all_files,
  function(x){
    out <- fread(
      paste0(data_dir, x), 
      select=c('model', 'serial_number', 'failure', 'capacity_bytes'),
      colClasses=c(capacity_bytes='character') # We lose a tiny bit of precision, but who cares
    )
    out[,filename := x]  # TODO: check which files have capacities < 0
  }
)
all_data <- rbindlist(all_data)

# Look at bad capacities
all_data[capacity_bytes == "-1", sort(unique(filename))]
all_data[capacity_bytes == "-9116022715867848704", sort(unique(filename))]

# Aggregate to counts by row (lots dupes so we can compress the data a lot here)
keys <- c('model', 'serial_number', 'failure', 'capacity_bytes')
setkeyv(all_data, keys)
all_data <- all_data[,list(.N), by=keys]

# Data quality checks
all_data[,sort(unique(capacity_bytes))]

summary(all_data[capacity_bytes == "-1",])
all_data[capacity_bytes == "-1",]
all_data[capacity_bytes == "-9116022715867848704",]

# Map models to capacity
all_data[,max_N := (N==max(N)), by='model']
capacity_map <- all_data[which(max_N),list(capacity_bytes=max(as.numeric(capacity_bytes))),by='model']
all_data[,max_N := NULL]
all_data[,capacity_bytes := NULL]

N <- nrow(all_data)
all_data <- merge(all_data, capacity_map, by='model', all.x=T, all.y=F)
stopifnot(nrow(all_data) == N)

# Save data
setkeyv(all_data, keys)
fwrite(all_data, 'all_data.csv')
# Now you can delete the "data" dir to save a bunch of GB of data