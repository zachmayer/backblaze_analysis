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
parser <- argparser::add_argument(parser, "--verbose",
                                  help="Print extra output",
                                  flag=TRUE)

args <- argparser::parse_args(parser)
if (args$verbose) print(dput(args))

# Validate required arguments
if (is.na(args$input) || is.na(args$output)) {
  stop("Both input directory and output file must be specified.", call.=FALSE)
}

# Process CSV files
keys <- c("serial_number", "model", "capacity_bytes")
apply_fun = lapply
if (args$verbose) apply_fun = pbapply::pblapply
dt <- data.table::rbindlist(
  apply_fun(
    list.files(path = args$input, pattern = "*.csv", full.names = TRUE),
    data.table::fread,
    select = c("date", keys, "failure"),
    integer64 = "numeric",  # Loose a little tiny precision off drive capacity
    encoding = "UTF-8",
    blank.lines.skip = TRUE,
    showProgress = args$verbose
  )
)
data.table::setkeyv(dt, keys)
if (args$verbose) cat("Processing", args$input, "successful.\n")

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
if (args$verbose) cat("Processing", args$output, "successful.\n")
