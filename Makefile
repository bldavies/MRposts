all: data

data: sitemap posts metadata categories

sitemap:
	Rscript data-raw/sitemap.R

posts:
	Rscript data-raw/posts.R

metadata:
	Rscript data-raw/metadata.R

categories:
	Rscript data-raw/categories.R

.PHONY: all data sitemap posts metadata categories
