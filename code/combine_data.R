parser <- argparser::arg_parser("Combine unziped csvs into one file")
parser <- argparser::add_argument(parser, "--input", help="Input CSV files", nargs=Inf)
parser <- argparser::add_argument(parser, "--verbose", help="Print extra output", flag=TRUE)
args <- argparser::parse_args(parser)
if (args$verbose) dput(args)

# For debugging
# args <- list(FALSE, help = FALSE, opts = NA, verbose=TRUE, input = c(
#   "data/2013.csv", "data/2014.csv", "data/2015.csv",
#   "data/Q1_2016.csv", "data/Q2_2016.csv", "data/Q3_2016.csv", "data/Q4_2016.csv",
#   "data/Q1_2017.csv", "data/Q2_2017.csv", "data/Q3_2017.csv", "data/Q4_2017.csv",
#   "data/Q1_2018.csv", "data/Q2_2018.csv", "data/Q3_2018.csv", "data/Q4_2018.csv",
#   "data/Q1_2019.csv", "data/Q2_2019.csv", "data/Q3_2019.csv", "data/Q4_2019.csv",
#   "data/Q1_2020.csv", "data/Q2_2020.csv", "data/Q3_2020.csv", "data/Q4_2020.csv",
#   "data/Q1_2021.csv", "data/Q2_2021.csv", "data/Q3_2021.csv", "data/Q4_2021.csv",
#   "data/Q1_2022.csv", "data/Q2_2022.csv", "data/Q3_2022.csv", "data/Q4_2022.csv",
#   "data/Q1_2023.csv", "data/Q2_2023.csv", "data/Q3_2023.csv", "data/Q4_2023.csv",
#   "data/Q1_2024.csv", "data/Q2_2024.csv"
# ))

# Load the data
apply_fun = lapply
if (args$verbose) apply_fun = pbapply::pblapply
dt_list <- apply_fun(
  args$input,
  data.table::fread,
  integer64 = "numeric",  # Loose a little tiny precision off drive capacity
  encoding = "UTF-8",
  blank.lines.skip = TRUE,
  showProgress = args$verbose
)
dt <- data.table::rbindlist(dt_list, use.names=TRUE, fill=TRUE)
if (args$verbose) cat("...Processing", args$input, "successful.\n")

# Set keys
keys <- "serial_number"
data.table::setkeyv(dt, keys)

# Cleanup drive capacities
dt[, capacity_tb := round(as.numeric(capacity_bytes) / 1e+12 / 0.5) * 0.5]  # To the nearest 0.5 TB
dt[capacity_bytes <= "-1", capacity_tb := as.numeric(NA)]   # HDs can't have negative capacity.
dt[capacity_tb < 0L, capacity_tb := as.numeric(NA)]   # HDs can't have negative capacity.
dt[capacity_tb >= 1000L, capacity_tb := as.numeric(NA)]  # 1 PetaByte drives don't exist yet

# Check drive capacities
ambiguous_capacity_data <- dt[is.finite(capacity_tb), list(N=length(collapse::funique(capacity_tb))), by='serial_number'][N>1,]
data.table::setorder(ambiguous_capacity_data, -N)
if(nrow(ambiguous_capacity_data) > 0) {
  cat("...Drives with ambiguous capacity data:", ambiguous_capacity_data[["serial_number"]], "\n")
}
if(nrow(ambiguous_capacity_data) > 10L){
  warning("10+ drives with ambiguous capacity data. Check the data and scripts.")
}
if(nrow(ambiguous_capacity_data) > 100L){
  stop("100+ many drives with ambiguous capacity data. Check the data and scripts.")
}

# Clean drive models
clean_model_names <- compiler::cmpfun(function(x){

  # Only process unique strings
  x_unique <- sort(collapse::funique(x))
  x_map <- fastmatch::fmatch(x, x_unique)

  # Remove control characters (C), combiners (M), punctuation (P), math (S) and whitespace (Z)
  x_unique <- stringi::stri_replace_all_regex(x_unique, '[[\\p{C}]|[\\p{M}]|[\\p{S}]|[\\p{Z}]]+', ' ')
  x <- stringi::stri_replace_all_regex(x, ' +', ' ')
  x_unique <- stringi::stri_trim_both(x_unique)
  x_unique <- stringi::stri_trans_tolower(x_unique)

  # Remap and return
  return(x_unique[x_map])
})
dt[,model := clean_model_names(model)]

# Check model names
ambiguous_model_data <- dt[, list(N=length(collapse::funique(model))), by='serial_number'][N>1,]
data.table::setorder(ambiguous_model_data, -N)
if(nrow(ambiguous_model_data) > 0) {
  cat("...Drives with ambiguous model data:", ambiguous_model_data[["serial_number"]], "\n")
}
if(nrow(ambiguous_model_data) > 10L){
  warning("10+ drives with ambiguous capacity data. Check the data and scripts.")
}
if(nrow(ambiguous_model_data) > 100L){
  stop("100+ many drives with ambiguous capacity data. Check the data and scripts.")
}

# Aggregate
dt <- dt[, list(
  capacity_bytes = median(capacity_tb, na.rm=TRUE),  # For differing capacities, take the median excluding NAs
  model = model[which.max(max_date)],  # For differing models, take the latest
  min_date = min(min_date),
  max_date = max(max_date),
  first_fail = min(first_fail, na.rm=TRUE)
), by=keys]

fwrite(drive_dates, 'results/drive_dates.csv')



# Show drive serials with more than one unique model
duplicate_models <- dt[,list(N=length(unique(model))), by='serial_number'][N>1,]


# Data quality checks=: bad capacity
dt[,sort(kit::funique(capacity_bytes))]
dt[capacity_bytes == "-1", summary(date)]
dt[capacity_bytes == "-9116022715867848704", summary(date)]
gc(reset=T)

# Capacity map
capacity_map <- all_data[,list(model, capacity=capacity_bytes)]
capacity_map[,capacity := as.integer(round(as.numeric(capacity)/1e+12))]
setkeyv(capacity_map, c('capacity', 'model'))
capacity_map = unique(capacity_map)
gc(reset=T)
capacity_map <- capacity_map[capacity > 0L,]  # HDs can't have negative capacity.  Also drop all <500GB drives
capacity_map <- capacity_map[capacity < 1000L,]
setkeyv(capacity_map, 'model')
capacity_map <- unique(capacity_map)
gc(reset=T)
capacity_map <- capacity_map[,list(capacity=max(capacity)), by='model']
setorder(capacity_map, -capacity, model)
fwrite(capacity_map, 'results/capacity_map.csv')
gc(reset=T)
head(capacity_map, 25)

# Calculate dates by serial number
keys <- c('model', 'serial_number')
setkeyv(all_data, keys)

# drive_dates[serial_number=='9JG4657T',]

# Check that each unique serial has one unique model
# Some manufacturers do re-use serials, so there will be some dupes
# But it should be a very small number
duplicate_serials <- drive_dates[,list(N=length(funique(model))), by='serial_number'][N>1,]
stopifnot(nrow(duplicate_serials) < 10)
duplicate_serials
