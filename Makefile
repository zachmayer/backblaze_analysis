# Configuration
BASE_URL := https://f001.backblazeb2.com/file/Backblaze-Hard-Drive-Data/
END_YEAR := 2024
END_QUARTER := Q2

# Directory for downloaded files
DOWNLOAD_DIR := zip_data

# Directory for processed CSV files
DATA_DIR := data

# Generate list of yearly data files (2013-2015)
YEARLY_FILES := $(addprefix $(DOWNLOAD_DIR)/data_,$(addsuffix .zip,$(shell seq 2013 2015)))

# Generate list of quarterly data files
define QUARTER_FILES
$(if $(filter $(1),$(END_YEAR)),\
    $(addprefix $(DOWNLOAD_DIR)/data_,$(addsuffix _$(1).zip,$(shell seq -f "Q%g" 1 $(subst Q,,$(END_QUARTER))))),\
    $(addprefix $(DOWNLOAD_DIR)/data_,$(addsuffix _$(1).zip,Q1 Q2 Q3 Q4)))
endef

QUARTERLY_FILES := $(foreach year,$(shell seq 2016 $(END_YEAR)),$(call QUARTER_FILES,$(year)))

# All files to be downloaded
ALL_FILES := $(YEARLY_FILES) $(QUARTERLY_FILES)

# List of output CSV files
CSV_FILES := $(patsubst $(DOWNLOAD_DIR)/data_%.zip,$(DATA_DIR)/%.csv,$(ALL_FILES))

# Phony targets
.PHONY: all yearly_data quarterly_data process_data clean_data print_files

all: yearly_data quarterly_data process_data

yearly_data: $(YEARLY_FILES)

quarterly_data: $(QUARTERLY_FILES)

process_data: $(CSV_FILES)

# Static pattern rule for downloading files
$(ALL_FILES): $(DOWNLOAD_DIR)/%.zip:
	@mkdir -p $(dir $@)
	curl -o $@ $(BASE_URL)$(@F)

# Pattern rule for processing zip files to CSV
$(DATA_DIR)/%.csv: $(DOWNLOAD_DIR)/data_%.zip | $(DATA_DIR)
	@echo "Processing $< ... $(shell date '+%Y-%m-%d %H:%M:%S')"
	@trap 'rm -f $@.tmp' EXIT; \
	unzip -p $< | awk 'NR == 1 || FNR > 1' > $@.tmp && mv $@.tmp $@

# Ensure data directory exists
$(DATA_DIR):
	mkdir -p $@

# Clean processed data
clean_data:
	rm -rf $(DATA_DIR)

# Print the list of files (for debugging)
print_files:
	@echo "Yearly files:" $(YEARLY_FILES) "\n"
	@echo "Quarterly files:" $(QUARTERLY_FILES) "\n"
	@echo "CSV files:" $(CSV_FILES) "\n"
