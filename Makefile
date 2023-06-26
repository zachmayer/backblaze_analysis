.PHONY: all download_data unzip_data assemble_data survival_analysis

all: download_data unzip_data assemble_data survival_analysis readme

download_data:
	Rscript code/1_download_data.R

unzip_data:
	Rscript code/2_unzip_data.R

assemble_data:
	Rscript code/3_assemble_data.R

survival_analysis:
	Rscript code/4_survival_analysis.R

readme:
	Rscript -e "rmarkdown::render('README.Rmd', 'github_document', clean=TRUE)"
