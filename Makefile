# Default target
.PHONY: help
help:
	@echo "Usage: make [target]"
	@echo
	@echo "Available targets:"
	@echo "  help             Display this help message."
	@echo "  all              Download all data and process it."
	@echo "  yearly_data      Download yearly data files (2013-2015)."
	@echo "  quarterly_data   Download quarterly data files (2016-2024)."
	@echo "  process_data     Process downloaded zip files into combined CSV files."
	@echo "  clean_data       Remove all processed CSV files."
	@echo "  print_files      Print the list of files for debugging."
	@echo
	@echo "Run make clean && make -j16 all to download/process the data in parallel."

# Configuration
BASE_URL := https://f001.backblazeb2.com/file/Backblaze-Hard-Drive-Data/
END_YEAR := 2024
END_QUARTER := Q2

# Directories
DOWNLOAD_DIR := zip_data
DATA_DIR := data
RESULTS_DIR := results

# Generate list of yearly data files (2013-2015)
YEARLY_FILES := $(addprefix $(DOWNLOAD_DIR)/data_,$(addsuffix .zip,$(shell seq 2013 2015)))

# Generate list of quarterly data files
define QUARTER_FILES
$(if $(filter $(1),$(END_YEAR)),\
    $(addprefix $(DOWNLOAD_DIR)/data_,$(addsuffix _$(1).zip,$(shell seq -f "Q%g" 1 $(subst Q,,$(END_QUARTER))))),\
    $(addprefix $(DOWNLOAD_DIR)/data_,$(addsuffix _$(1).zip,Q1 Q2 Q3 Q4)))
endef
QUARTERLY_FILES := $(foreach year,$(shell seq 2016 $(END_YEAR)),$(call QUARTER_FILES,$(year)))

# Static pattern rule for downloading files
ALL_FILES := $(YEARLY_FILES) $(QUARTERLY_FILES)
$(ALL_FILES): $(DOWNLOAD_DIR)/%.zip:
	@mkdir -p $(dir $@)
	curl -o $@ $(BASE_URL)$(@F)

# Pattern rule for processing zip files to CSV
# Only keeps the first 5 columns: date,serial_number,model,capacity_bytes,failure
# Note that for the smart stats stats, different files have different columns
# So if we want to process smart stats, we need much more complicated logic.
# For this script we just want to analyze failure rates, so we drop the smart stats
# Add trap 'rm -rf "$$TEMP_DIR"' EXIT; at the start to delete tempfiles
# Takes about 4 minutes with 8 cores
# ...Bad input files: data/Q1_2017/2017-01-30.csv — ???
# ...Bad input files: data/2014/2014-11-02.csv — DST ends lol
# ...Bad input files: data/2015/2015-11-01.csv — DST ends lol
CSV_FILES := $(patsubst $(DOWNLOAD_DIR)/data_%.zip,$(DATA_DIR)/%.csv,$(ALL_FILES))
$(DATA_DIR)/%.csv: $(DOWNLOAD_DIR)/data_%.zip code/process_csv_files.R | $(DATA_DIR)
	@echo "Processing $< ... $(shell date '+%Y-%m-%d %H:%M:%S')"
	@TEMP_DIR="$(DATA_DIR)/$*"; \
	mkdir -p "$$TEMP_DIR"; \
	unzip -n -qq -j $< -d "$$TEMP_DIR" -x "__MACOSX/*" "*.DS_Store" 2>/dev/null && \
	Rscript code/process_csv_files.R \
		--input "$$TEMP_DIR" \
		--output $@

# Clean processed data
.PHONY: clean
clean:
	find $(DATA_DIR) -mindepth 1 -delete
	find $(RESULTS_DIR) -mindepth 1 -delete

# Print the list of files (for debugging)
.PHONY: print_files
print_files:
	@echo "Yearly files:" $(YEARLY_FILES) "\n"
	@echo "Quarterly files:" $(QUARTERLY_FILES) "\n"
	@echo "CSV files:" $(CSV_FILES) "\n"

.PHONY: download_data
download_data: $(ALL_FILES)

.PHONY: unzip_data
unzip_data: $(CSV_FILES)

.PHONY: all
all: download_data unzip_data
