# Libraries for helpers
library(compiler)  # cmpfun
library(kit)  # funique
library(fastmatch)  # fmatch
library(stringi)  # stri_replace_all_regex / stri_trim_both

# Days in a year
days_to_year <- 365.2425

# Custom color custom_palette
custom_palette <- c(
  "#1f78b4", "#ff7f00", "#6a3d9a", "#33a02c", "#e31a1c", "#b15928",
  "#a6cee3", "#fdbf6f", "#cab2d6", "#b2df8a", "#fb9a99", "black",
  "grey1", "grey10"
)

# Clean up strings (specifically model names)
string_normalize <- cmpfun(function(x){
  
  # Only process unique strings
  x_unique <- sort(funique(x))
  x_map <- fmatch(x, x_unique)
  
  # Remove control characters (C), combiners (M), punctuation (P), math (S) and whitespace (Z) 
  x_unique <- stri_replace_all_regex(x_unique, '[[\\p{C}]|[\\p{M}]|[\\p{S}]|[\\p{Z}]]+', ' ')
  x <- stri_replace_all_regex(x, ' +', ' ')
  x_unique <- stri_trim_both(x_unique)
  
  # Remap and return
  return(x_unique[x_map])
})

# Convert a file name to a date
file_to_date <- cmpfun(function(x){
  x_unique <- sort(funique(x))
  x_map <- fmatch(x, x_unique)
  x_date <- as.Date(gsub('.csv', '', x_unique, fixed=T))
  return(x_date[x_map])
})