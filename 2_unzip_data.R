
########################################################
# Unzip
########################################################
library(pbapply)
zip_dir <- 'zip_data/'
all_files <- list.files(zip_dir)
all_files <- all_files[grepl('.zip', all_files)]
all_files <- paste0(zip_dir, all_files)
sink <- pblapply(all_files, function(filename){
  unzip(filename, exdir = 'data', overwrite=T, junkpaths=T)
})

########################################################
# Concat all files
########################################################
# https://unix.stackexchange.com/a/170692/203993

# Delete the combined file
output_name <- 'all_data.csv'
unlink(outname)

# Make a list of files
data_dir <- 'data/'
set.seed(110001)
all_files <- sample(list.files(data_dir))
gc(reset=T)

# Write the header for the last file we have (which will have the most columns)
t1 <- Sys.time()
dat_list <- pblapply(all_files, function(x){  # Takes ~30 minutes
  dat <- fread(paste0(data_dir, x), showProgress=F)
  dat[,capacity_bytes := NULL]
  ids <- c('date', 'serial_number', 'model', 'failure')
  dat <- melt.data.table(dat, id.vars = ids, na.rm = TRUE)
  dat <- dat[is.finite(value),]
  dat <- dat[value != 0,]
  dat <- dat[!grepl('_normalized', variable, fixed=T),]
  fwrite(dat, file=output_name, append = T)
}
)
time_diff <- as.numeric(Sys.time() - t1)
print(time_diff)
