#!/usr/bin/env Rscript

# Load required library
library(data.table)

# Read input arguments
args <- commandArgs(trailingOnly = TRUE)
input_file <- args[1]

# Read the temporary CSV file
data <- data.table::fread(input_file, select = c("date", "serial_number", "model", "capacity_bytes", "failure"))

# Set keys
data.table::setkeyv(data, c("serial_number", "model", "capacity_bytes"))

# Perform aggregation
result <- data[, .(
  min_date = min(date),
  max_date = max(date),
  first_fail = min(date[failure == 1], na.rm = TRUE)
), by = .(serial_number, model, capacity_bytes)]

# Sort the result
data.table::setorder(result, serial_number, model, capacity_bytes)

# Overwrite the temporary file with the processed data
data.table::fwrite(result, input_file)

# Inform the user
cat("Processed data written to:", input_file, "\n")
