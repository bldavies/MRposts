all: data package

data: sitemap posts metadata categories

sitemap:
	Rscript data-raw/sitemap.R

posts:
	Rscript data-raw/posts.R

metadata:
	Rscript data-raw/metadata.R

categories:
	Rscript data-raw/categories.R

package:
	Rscript -e "devtools::install()"

.PHONY: all data sitemap posts metadata categories package
