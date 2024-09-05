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

# Combine into one data.table
dt <- data.table::rbindlist(dt_list, use.names=TRUE, fill=TRUE)

# Set keys
keys <- "serial_number"
data.table::setkeyv(dt, keys)

# Cleanup drive capacities
# NOTE: drive capacity will go down as drives fail
dt[, capacity_tb := round(as.numeric(capacity_bytes) / 1e+12 / 0.1) * 0.1]  # To the nearest 0.5 TB
dt[capacity_bytes <= "-1", capacity_tb := 0L]   # HDs can't have negative capacity.
dt[capacity_tb < 0L, capacity_tb := 0L]   # HDs can't have negative capacity.
dt[capacity_tb >= 1000L, capacity_tb := 0L]  # 1 PetaByte drives don't exist yet

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
  capacity_tb = max(capacity_tb, na.rm=TRUE),  # For differing capacities, take the median excluding NAs
  model = model[which.max(max_date)],  # For differing models, take the latest
  min_date = min(min_date),
  max_date = max(max_date),
  first_fail = suppressWarnings(min(first_fail, na.rm=TRUE))
), by=keys]

# Recode failures
dt[,failed := as.integer(is.finite(first_fail))]
dt[is.finite(first_fail), max_date := first_fail]
dt[,first_fail := NULL]
stopifnot(dt[,all(max_date >= min_date)])

# Recode models
# hitachi bought hgst's disk business
# then wdc bought hitachi disk business
dt[,model := stringi::stri_replace_all_fixed(model, 'hgst ', 'wdc ')]
dt[,model := stringi::stri_replace_all_fixed(model, 'hitachi ', 'wdc ')]
dt[model == "wuh721816ale6l4", model := "wdc wuh721816ale6l4"]
dt[,sort(unique(model))]

# Save
data.table::fwrite(dt, 'results/drive_dates.csv')
