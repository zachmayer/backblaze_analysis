#!/usr/bin/env Rscript

args <- commandArgs(trailingOnly = TRUE)
input_file <- args[1]
output_file <- args[2]

# Read the temporary CSV file
dt <- data.table::fread(
  input_file, 
  select = c('date', 'model', 'serial_number', 'failure', 'capacity_bytes'),
  colClasses=c(capacity_bytes='numeric') # We lose a tiny bit of precision, but who cares
  )

# Set keys
data.table::setkey(dt, serial_number, model, capacity_bytes)

# Calculate summary statistics
summary_dt <- dt[, .(
  min_date = min(date),
  max_date = max(date),
  first_fail = min(date[failure == 1], na.rm = TRUE)
), by = .(serial_number, model, capacity_bytes)]

# Sort the final output
data.table::setorder(summary_dt, serial_number, model, capacity_bytes)

# Write the final output
data.table::fwrite(summary_dt, output_file)
