#!/usr/bin/env Rscript
# fread all csv files from a directory
# select given columns from them
# concatenate them together
# then aggregate by date

#!/usr/bin/env Rscript

# Parse command line arguments
parser <- argparser::arg_parser("Process CSV files and combine them")
parser <- argparser::add_argument(parser, "--input", help="Input directory containing CSV files", type="character")
parser <- argparser::add_argument(parser, "--output", help="Output CSV file", type="character")
parser <- argparser::add_argument(parser, "--verbose", help="Print extra output", flag=TRUE)

args <- argparser::parse_args(parser)
if (args$verbose) dput(args)

# Manually load args for testing
# args <- list(
#   input = "data/Q1_2018",
#   output = "data/test.csv",
#   verbose = TRUE
# )

# Validate required arguments
if (is.na(args$input) || is.na(args$output)) {
  stop("Both input directory and output file must be specified.", call.=FALSE)
}

# Read the input files
csv_files <- list.files(path = args$input, pattern = "*.csv", full.names = TRUE)
if (args$verbose) cat("...Found", length(csv_files), "csv files.\n")

# Read CSV files to list
apply_fun = lapply
if (args$verbose) apply_fun = pbapply::pblapply
keys <- c("serial_number", "model", "capacity_bytes")
dt_list <- apply_fun(
  csv_files,
  data.table::fread,
  select = c(keys, "failure"),
  integer64 = "numeric",  # Loose a little tiny precision off drive capacity
  encoding = "UTF-8",
  blank.lines.skip = TRUE,
  showProgress = args$verbose
)

# Some files have bad date formats (such as 2018-02-25 in Q1 2018)
# So we use the filename to set the date.
# Note that we need to change the type of the column to IDate
file_dates <- data.table::as.IDate(gsub('.csv', '', basename(csv_files), fixed=TRUE))
stopifnot(length(file_dates) == length(dt_list))
for (i in seq_along(dt_list)) {
  data.table::set(dt_list[[i]], j = "date", value = file_dates[i])
}

# Drop bad files
dt_list <- lapply(dt_list, function(x){
  out <- if(nrow(x) == 0) NULL else x
})
bad_files <- csv_files[sapply(dt_list, is.null)]
if(length(bad_files) > 0) cat("...Bad input files:", bad_files, "\n")

# Combine csv files
dt <- data.table::rbindlist(dt_list, use.names=TRUE, fill=TRUE)

# Set keys
data.table::setkeyv(dt, keys)
if (args$verbose) cat("...Processing", args$input, "successful.\n")

# Calculate summary statistics
summary_dt <- dt[, list(
  min_date = min(date),
  max_date = max(date),
  first_fail = suppressWarnings(min(date[failure == 1L], na.rm = TRUE))
), by = keys]

# Sort the final output
data.table::setorderv(summary_dt, keys)

# Write the final output
data.table::fwrite(summary_dt, args$output, sep = ",", quote = TRUE, encoding = "UTF-8")
if (args$verbose) cat("...", args$output, "successful.\n")
