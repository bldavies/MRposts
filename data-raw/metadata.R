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

# Define function for replacing non-ASCII characters with ASCII equivalents
replace_non_ascii = function(x) {
  subfun = function(x, pattern, y) gsub(pattern, y, x)
  x %>%
    subfun('í', 'i') %>%
    subfun('õ', 'o') %>%
    subfun('ô', 'o') %>%
    subfun('ú', 'u') %>%
    subfun('‘', '\'') %>%
    subfun('’', '\'') %>%
    subfun('“', '"') %>%
    subfun('”', '"') %>%
    subfun('–', '-') %>%
    subfun('—', '-') %>%
    subfun('…', '...')
}

# Create table
metadata = tibble(file = list.files(POSTS_DIR, 'metadata[.]csv', full.names = T, recursive = T)) %>%
  mutate(path = sub(paste0(POSTS_DIR, '/(.*)/metadata.csv'), '\\1', file),
         month = as_date(paste0(substr(path, 1, 8), '01'))) %>%
  filter(month %in% unique(floor_date(DATE_RANGE, 'months'))) %>%
  mutate(res = map(file, vroom, show_col_types = F)) %>%
  select(-file, -month) %>%
  unnest('res') %>%
  arrange(time) %>%
  filter(as_date(time) %in% DATE_RANGE) %>%
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
