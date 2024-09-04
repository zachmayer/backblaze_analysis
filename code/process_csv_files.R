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
parser <- argparser::add_argument(parser, "--select",
                                  help="Comma-separated list of columns to select",
                                  default="")
parser <- argparser::add_argument(parser, "--verbose",
                                  help="Print extra output",
                                  flag=TRUE)

args <- argparser::parse_args(parser)

# Validate required arguments
if (is.na(args$input) || is.na(args$output)) {
  stop("Both input directory and output file must be specified.", call.=FALSE)
}

# Convert select string to vector
KEYS <- c("serial_number", "model", "capacity_bytes")
select_cols <- unlist(strsplit(args$select, ","))
select_cols <- c("date", KEYS, select_cols)
select_cols <- unique(select_cols)

# Process CSV files
apply_fun = lapply
if (verbose) apply_fun = pbapply::pblapply
dt <- data.table::rbindlist(
  apply_fun(
    list.files(path = args$input, pattern = "*.csv", full.names = TRUE),
    data.table::fread,
    select = select_cols,
    integer64 = "numeric",  # Loose a little tiny precision off drive capacity
    encoding = "UTF-8",
    blank.lines.skip = TRUE,
    showProgress = verbose
  )
)
setkeyv(df, KEYS)
if (verbose) cat("Processing", args$input, "successful.\n")

# Calculate summary statistics
summary_dt <- dt[, .(
  min_date = min(date),
  max_date = max(date),
  first_fail = suppressWarnings(min(date[failure == 1L], na.rm = TRUE))
), by = KEYS]

# Sort the final output
data.table::setorderv(summary_dt, KEYS)

# Write the final output
data.table::fwrite(summary_dt, args$output, sep = ",", quote = TRUE, encoding = "UTF-8")
