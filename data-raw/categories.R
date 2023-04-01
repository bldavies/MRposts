# CATEGORIES.R
#
# This script creates a table of post ID-category pairs.
# It must be run after data-raw/posts.R.
#
# Ben Davies
# March 2023

# Load packages
library(dplyr)
library(readr)
library(vroom)

# Import globals
source('data-raw/globals.R')

# Create table
categories = list.files(POSTS_DIR, 'categories[.]csv', full.names = T, recursive = T) %>%
  vroom(show_col_types = F) %>%
  arrange(id, category)

# Save table
write_csv(categories, 'data-raw/categories.csv')

# Save session info
if ('bldr' %in% rownames(installed.packages())) {
  bldr::save_session_info('data-raw/categories.log')
}
