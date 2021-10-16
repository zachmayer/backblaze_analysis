library(data.table)
options(timeout=600)  # These files take a while to download

# Single year data
for(year in 2013:2015){
  filename <- paste0('zip_data/data_', year, '.zip')
  if(!file.exists(filename)){
    url <- paste0(
      'https://f001.backblazeb2.com/file/Backblaze-Hard-Drive-Data/data_',
      year,
      '.zip'
    )
    print(paste('Downloading', filename))
    download.file(url, filename)
  }
}

# Quarterly data
THIS_YEAR <- year(Sys.Date())
for(year in 2016:THIS_YEAR){
  for(quarter in paste0('Q', 1:4)){
    quarter_year <- paste0(quarter, '_', year)
    filename <- paste0('zip_data/data_', quarter_year, '.zip')
    if(!file.exists(filename)){
      url <- paste0(
        'https://f001.backblazeb2.com/file/Backblaze-Hard-Drive-Data/data_',
        quarter_year,
        '.zip'
      )
      print(paste('Downloading', filename))
      download.file(url, filename)
    }
  }
}
