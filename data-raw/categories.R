# CATEGORIES.R
#
# This script creates a table of post ID-category pairs.
# It must be run after data-raw/metadata.R.
#
# Ben Davies
# April 2023

# Load packages
library(dplyr)
library(readr)
library(usethis)
library(vroom)

# Import globals
source('data-raw/globals.R')

# Import metadata
metadata = read_csv('data-raw/metadata.csv')

# Create table
categories = list.files(POSTS_DIR, 'categories[.]csv', full.names = T, recursive = T) %>%
  vroom(show_col_types = F) %>%
  arrange(id, category) %>%
  semi_join(metadata, by = 'id')

# Save table
write_csv(categories, 'data-raw/categories.csv')
use_data(categories, overwrite = T)

# Save session info
if ('bldr' %in% rownames(installed.packages())) {
  bldr::save_session_info('data-raw/categories.log')
}
