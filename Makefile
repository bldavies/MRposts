all: data

data: sitemap posts

sitemap:
	Rscript data-raw/sitemap.R

posts:
	Rscript data-raw/posts.R

.PHONY: all data sitemap posts
