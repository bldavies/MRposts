# METADATA.R
#
# This script creates a table of post metadata.
# It must be run after data-raw/posts.R.
#
# Ben Davies
# March 2023

# Load packages
library(dplyr)
library(purrr)
library(readr)
library(tidyr)
library(vroom)

# Import globals
source('data-raw/globals.R')

# Define function for replacing non-ASCII characters with ASCII equivalents
replace_non_ascii = function(x) {
  subfun = function(x, pattern, y) gsub(pattern, y, x)
  x %>%
    subfun('‘', '\'') %>%
    subfun('’', '\'') %>%
    subfun('“', '"') %>%
    subfun('”', '"')
}

# Create table
metadata = tibble(file = list.files(POSTS_DIR, 'metadata[.]csv', full.names = T, recursive = T)) %>%
  mutate(path = sub(paste0(POSTS_DIR, '/(.*)/metadata.csv'), '\\1', file),
         res = map(file, vroom, show_col_types = F)) %>%
  select(-file) %>%
  unnest('res') %>%
  arrange(time) %>%
  mutate(title = replace_non_ascii(title))

# Assert IDs are unique
if (max(count(metadata, id)$n) > 1) {
  stop('Post IDs are not unique')
}

# Save table
write_csv(metadata, 'data-raw/metadata.csv')

# Save session info
if ('bldr' %in% rownames(installed.packages())) {
  bldr::save_session_info('data-raw/metadata.log')
}
