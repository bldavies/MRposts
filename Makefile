all: data sitemap

sitemap:
	Rscript data-raw/sitemap.R

.PHONY: all data sitemap
