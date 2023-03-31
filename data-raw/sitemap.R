# SITEMAP.R
#
# This script scrapes the Marginal Revolution sitemap(s) for blog post paths and
# last modification dates.
#
# Ben Davies
# March 2023

# Load packages
library(dplyr)
library(lubridate)
library(readr)
library(xml2)

# Import globals
source('data-raw/globals.R')

# Read base sitemap
base_sitemap_url = 'https://marginalrevolution.com/sitemap_index.xml'
base_sitemap_xml = read_xml(base_sitemap_url)

# Extract post sitemap URLs
post_sitemap_urls = base_sitemap_xml %>%
  xml_find_all('//d1:loc') %>%
  xml_text() %>%
  {.[which(grepl('post-sitemap', .))]}

# Create table
sitemap = lapply(post_sitemap_urls, function(url) {
  
  # Wait
  Sys.sleep(1)
  
  # Read XML
  xml = read_xml(url)
  
  # Extract path and last modification date
  tibble(
    path = xml_text(xml_find_all(xml, './/d1:loc')),
    lastmod = xml_text(xml_find_all(xml, './/d1:lastmod'))
  )
  
}) %>%
  bind_rows() %>%
  slice(-1) %>%  # Remove index
  mutate(path = sub(paste0(BLOG_URL, '(.*)[.]html'), '\\1', path),
         lastmod = as_datetime(lastmod)) %>%
  arrange(lastmod)

# Save table
write_csv(sitemap, 'data-raw/sitemap.csv')

# Save session info
if ('bldr' %in% rownames(installed.packages())) {
  bldr::save_session_info('data-raw/sitemap.log')
}
