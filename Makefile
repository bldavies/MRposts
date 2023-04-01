all: data

data: sitemap posts metadata

sitemap:
	Rscript data-raw/sitemap.R

posts:
	Rscript data-raw/posts.R

metadata:
	Rscript data-raw/metadata.R

.PHONY: all data sitemap posts metadata
