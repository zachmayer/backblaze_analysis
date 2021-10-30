# Setup
stop()
rm(list = ls(all=T))
gc(reset = T)
library(pbapply)
library(data.table)
library(stringi)
library(ggplot2)
library(ggthemes)
source('helpers.r')
set.seed(110001)

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
lookit_me <- drive_dates[!is.na(first_fail),][order(-days_to_fail),]
lookit_serial <- lookit_me[2, string_normalize(serial_number)]
lookit_model <- lookit_me[2, string_normalize(model)]

# Calculate "data gaps" by drive
t1 <- Sys.time()
set.seed(110001)
dat_list <- pblapply(  # Takes ~30 minutes
  sample(all_files),
  function(x){

    # Bookkeeping
    gc(reset=T)

    # Load data
    x <- paste0(data_dir, x)
    dat <- fread(x, showProgress=F, select=c('date', 'serial_number', 'model'))

    #Return
    dat
  }
)
time_diff <- as.numeric(Sys.time() - t1)
print(time_diff)

# Load the data
# https://www.backblaze.com/b2/hard-drive-test-data.html#overview-of-the-hard-drive-data
# https://en.wikipedia.org/wiki/S.M.A.R.T.
t1 <- Sys.time()
set.seed(110001)
dat_list <- pblapply(  # Takes ~30 minutes
  sample(all_files),
  function(x){

    # Bookkeeping
    gc(reset=T)

    # Load data
    dat <- fread(paste0(data_dir, x), showProgress=F)

    # Normalize
    dat[,serial_number := string_normalize(serial_number)]
    dat[,model := string_normalize(model)]

    # Subset
    dat <- dat[serial_number==lookit_serial & model==lookit_model,]

    #Return
    return(dat)
  }
)
warnings()  # 222 / 224 / 226 not found
time_diff <- as.numeric(Sys.time() - t1)
print(time_diff)

# Rbind
dat <- dat_list
dat <- lapply(dat, function(x){
  if(nrow(x)>0){
    return(x)
  }
})
dat <- rbindlist(dat, use.names=T, fill=T)

# Clean model name string
dat[,model := string_normalize(model)]
gc(reset=T)

# Replace NA with zero
smart_stats <- names(dat)[grepl('smart_', names(dat), fixed=T)]
for(var in smart_stats){
  set(dat, j=var, value = as.numeric(dat[[var]]))
  set(dat, i=which(is.na(dat[[var]])), j=var, value=0)
}
gc(reset=T)

# Drop constant numeric columns
nums <- sapply(dat, is.numeric)
singles <- sapply(dat, function(x) length(unique(x)) < 2)
num_singles <- nums & singles
remove_vars <- names(num_singles)[num_singles]
#print(remove_vars)
for(var in remove_vars){
  set(dat, j=var, value=NULL)
}

# Order
setkeyv(dat, c('model', 'serial_number', 'date'))

# Plots
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
