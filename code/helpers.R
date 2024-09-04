# Days in a year
days_to_year <- 365.2425

# Custom color custom_palette
custom_palette <- c(
  "#1f78b4", "#ff7f00", "#6a3d9a", "#33a02c", "#e31a1c", "#b15928",
  "#a6cee3", "#fdbf6f", "#cab2d6", "#b2df8a", "#fb9a99", "black",
  "grey1", "grey10"
)

# Clean up strings (specifically model names)
string_normalize <- compiler::cmpfun(function(x){

  # Only process unique strings
  x_unique <- sort(kit::funique(x))
  x_map <- fastmatch::fmatch(x, x_unique)

  # Remove control characters (C), combiners (M), punctuation (P), math (S) and whitespace (Z)
  x_unique <- stringi::stri_replace_all_regex(x_unique, '[[\\p{C}]|[\\p{M}]|[\\p{S}]|[\\p{Z}]]+', ' ')
  x <- stringi::stri_replace_all_regex(x, ' +', ' ')
  x_unique <- stringi::stri_trim_both(x_unique)
  x_unique <- stringi::stri_trans_tolower(x_unique)

  # Remap and return
  return(x_unique[x_map])
})
