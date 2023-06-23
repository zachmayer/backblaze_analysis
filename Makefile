.PHONY: all download_data unzip_data assemble_data survival_analysis

all: download_data unzip_data assemble_data survival_analysis

download_data:
	Rscript code/1_download_data.R

unzip_data:
	Rscript code/2_unzip_data.R

assemble_data:
	Rscript code/3_assemble_data.R

survival_analysis:
	Rscript code/4_survival_analysis.R
