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

# Initialize cache directory
cache_dir = 'data-raw/categories'
if (!dir.exists(cache_dir)) dir.create(cache_dir)

# Iterate over years
year_dirs = list.dirs(POSTS_DIR, recursive = F)
for (year_dir in year_dirs) {
  
  # Iterate over months
  month_dirs = list.dirs(year_dir, recursive = F)
  for (month_dir in month_dirs) {
    
    # List post-specific files
    files = list.files(month_dir, 'categories[.]csv', full.names = T, recursive = T)
    
    # Construct cache file path
    month_ext = sub(paste0(POSTS_DIR, '/'), '', month_dir)
    cache_file = sub('(.*)/(.*)', paste0(cache_dir, '/\\1-\\2.csv'), month_ext)
    
    # Create/update cache file
    if (!file.exists(cache_file) | max(file.mtime(files)) > file.mtime(cache_file)) {
      
      # Create table
      dat = files %>%
        vroom(show_col_types = F) %>%
        arrange(id, category)
      
      # Save table
      write_csv(dat, cache_file)
      
    }
  }
}

# Combine cached files into single table
cache_files = list.files(cache_dir, full.names = T)
categories = cache_files %>%
  vroom(show_col_types = F) %>%
  arrange(id) %>%
  semi_join(metadata, by = 'id')

# Save table
write_csv(categories, 'data-raw/categories.csv')
use_data(categories, overwrite = T)

# Save session info
if ('bldr' %in% rownames(installed.packages())) {
  bldr::save_session_info('data-raw/categories.log')
}
