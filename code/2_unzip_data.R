
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
