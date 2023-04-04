# METADATA.R
#
# This script creates a table of post metadata.
# It must be run after data-raw/posts.R.
#
# Ben Davies
# April 2023

# Load packages
library(dplyr)
library(lubridate)
library(purrr)
library(readr)
library(tidyr)
library(usethis)
library(vroom)

# Import globals
source('data-raw/globals.R')

# Import data collected manually
metadata_duplicated = read_csv('data-raw/manual/metadata_duplicated.csv')

# Define function for replacing non-ASCII characters with ASCII equivalents
replace_non_ascii = function(x) {
  subfun = function(x, pattern, y) gsub(pattern, y, x)
  x %>%
    subfun('á', 'a') %>%
    subfun('à', 'a') %>%
    subfun('ã', 'a') %>%
    subfun('ä', 'a') %>%
    subfun('ć', 'c') %>%
    subfun('ç', 'c') %>%
    subfun('ð', 'd') %>%
    subfun('c̶', 'c') %>%
    subfun('Ãª', 'e') %>%
    subfun('é', 'e') %>%
    subfun('é', 'e') %>%
    subfun('è', 'e') %>%
    subfun('ë', 'e') %>%
    subfun('İ', 'I') %>%
    subfun('í', 'i') %>%
    subfun('L̶', 'L') %>%
    subfun('ł', 'l') %>%
    subfun('ñ', 'n') %>%
    subfun('n̶', 'n') %>%
    subfun('Ö', 'O') %>%
    subfun('ó', 'o') %>%
    subfun('õ', 'o') %>%
    subfun('ö', 'o') %>%
    subfun('ô', 'o') %>%
    subfun('ş', 's') %>%
    subfun('Ü', 'U') %>%
    subfun('ú', 'u') %>%
    subfun('ü', 'u') %>%
    subfun('u̶', 'u') %>%
    subfun('Ž', 'Z') %>%
    subfun('ž', 'z') %>%
    subfun('ʼ', '\'') %>%
    subfun('‘', '\'') %>%
    subfun('’', '\'') %>%
    subfun('“', '"') %>%
    subfun('”', '"') %>%
    subfun('‐', '-') %>%
    subfun('–', '-') %>%
    subfun('—', '-') %>%
    subfun('…', '...') %>%
    subfun('¡', '') %>%
    subfun('×', 'x') %>%
    subfun('ﬁ', 'fi') %>%
    subfun('™', '')
}

# Initialize cache directory
cache_dir = 'data-raw/metadata'
if (!dir.exists(cache_dir)) dir.create(cache_dir)

# Iterate over years
year_dirs = list.dirs(POSTS_DIR, recursive = F)
for (year_dir in year_dirs) {
  
  # Iterate over months
  month_dirs = list.dirs(year_dir, recursive = F)
  for (month_dir in month_dirs) {
    
    # List post-specific files
    files = list.files(month_dir, 'metadata[.]csv', full.names = T, recursive = T)
  
    # Construct cache file path
    month_ext = sub(paste0(POSTS_DIR, '/'), '', month_dir)
    cache_file = sub('(.*)/(.*)', paste0(cache_dir, '/\\1-\\2.csv'), month_ext)
    
    # Create/update cache file
    if (!file.exists(cache_file) | max(file.mtime(files)) > file.mtime(cache_file)) {
      
      # Create table
      dat = tibble(file = files) %>%
        mutate(path = sub(paste0(POSTS_DIR, '/(.*)/metadata.csv'), '\\1', file),
               res = map(file, vroom, col_types = 'nTccn')) %>%
        select(-file) %>%
        unnest('res') %>%
        arrange(time)
      
      # Save table
      write_csv(dat, cache_file)
      
    }
  }
}

# Combine cached files into single table
cache_files = list.files(cache_dir, full.names = T)
metadata = cache_files %>%
  vroom(show_col_types = F) %>%
  bind_rows(metadata_duplicated) %>%
  filter(date(time) %in% DATE_RANGE) %>%
  arrange(time) %>%
  mutate(title = replace_non_ascii(title))

# Assert IDs are unique
if (max(count(metadata, id)$n) > 1) {
  stop('Post IDs are not unique')
}

# Save table
write_csv(metadata, 'data-raw/metadata.csv')
use_data(metadata, overwrite = T)

# Save session info
if ('bldr' %in% rownames(installed.packages())) {
  bldr::save_session_info('data-raw/metadata.log')
}
