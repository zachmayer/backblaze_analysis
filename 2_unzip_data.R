
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
last_file <- tail(sort(all_files), 1)
system(paste('head -1', paste0(data_dir, last_file), '>', output_name))
system(paste('cat', output_name))

# Now write the contents of the file
system(paste0('tail -n +2 -q ', data_dir, '*.csv >> ', output_name))


t1 <- Sys.time()
dat_list <- pblapply(all_files, function(x){ # Takes ~30 minutes
    x <- paste0(data_dir, x)

  }
)
time_diff <- as.numeric(Sys.time() - t1)
print(time_diff)
gc(reset=T)
