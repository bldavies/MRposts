# POSTS.R
#
# This script scrapes post metadata, categories, and content.
# It must be run after data-raw/sitemap.R.
#
# Ben Davies
# April 2023

# Load packages
library(dplyr)
library(lubridate)
library(readr)
library(rvest)

# Import globals
source('data-raw/globals.R')

# Import sitemap
sitemap = read_csv('data-raw/sitemap.csv')

# Import metadata on posts with duplicated paths
metadata_duplicated = read_csv('data-raw/manual/metadata_duplicated.csv')

# Import list of errant paths
errant_paths = read_csv('data-raw/errant-paths.csv')

# Restrict to posts in date range with unique non-errant paths
posts = sitemap %>%
  mutate(month = as_date(paste0(substr(path, 1, 8), '01'))) %>%
  filter(month %in% unique(floor_date(DATE_RANGE, 'months'))) %>%
  anti_join(metadata_duplicated, by = 'path') %>%
  anti_join(errant_paths, by = 'path')

# Iterate over posts in date range
for (i in 1:nrow(posts)) {
  
  # Extract post path
  post_path = posts$path[i]
  
  # Initialize output directory
  post_dir = paste0(POSTS_DIR, post_path)
  if (!dir.exists(post_dir)) dir.create(post_dir, recursive = T)
  
  # Check post metadata modification time
  post_metadata_mtime = file.mtime(paste0(post_dir, '/metadata.csv'))
  attr(post_metadata_mtime, 'tzone') = 'UTC'
  
  # Download/update post metadata, categories, and content
  if (is.na(post_metadata_mtime) | posts$lastmod[i] > post_metadata_mtime) {
    
    # Wait
    Sys.sleep(3)
    
    # Read post HTML
    post_url = paste0(BLOG_URL, post_path, '.html')
    post_html = tryCatch(read_html(post_url), error = function(e) NULL)
    
    # Process post HTML
    if (!is.null(post_html)) {
      
      # Extract post ID
      post_id = post_html %>%
        html_elements('article.post') %>%
        html_attr('id') %>%
        {as.integer(sub('post-', '', .))}
      
      # Parse post header
      post_header = post_html %>%
        html_elements('article.post header')
      
      # Extract post publication time
      post_time = post_header %>%
        html_element('.byline time') %>%
        html_attr('datetime') %>%
        as_datetime()
      
      # Extract post title
      post_title = post_header %>%
        html_element('.entry-title') %>%
        html_text()
      
      # Extract post author
      post_author = post_header %>%
        html_element('.author') %>%
        html_text()
      
      # Extract post comment count
      post_comments = post_html %>%
        html_element('article.post footer section.post-actions li.meta-item .meta-text') %>%
        html_text() %>%
        {sub(' Comments', '', .)} %>%
        as.numeric()
      
      # Manually fix parsing failures
      if (post_id == 9061) {
        post_title = 'Confusions about the multiplier < 1 (me defending fiscal policy, sort of)'
      }
      if (post_id == 77456) {
        post_title = 'Big Data+Small Bias << Small Data+Zero Bias'
      }
      
      # Save table of post metadata
      tibble(
        id = post_id,
        time = post_time,
        title = post_title,
        author = post_author,
        comments = post_comments
      ) %>%
        write_csv(paste0(post_dir, '/metadata.csv'))
      
      # Extract post categories
      post_categories = post_header %>%
        html_elements('.entry-tags li') %>%
        html_text()
      
      # Save table of post ID-category pairs
      if (length(post_categories) > 0) {
        tibble(
          id = post_id,
          category = post_categories
        ) %>%
          write_csv(paste0(post_dir, '/categories.csv'))
      }
      
      # Save post content
      post_html %>%
        html_elements('article.post .entry-content') %>%
        html_children() %>%
        as.character() %>%
        {unlist(strsplit(., '\n'))} %>%
        trimws() %>%
        write_lines(paste0(post_dir, '/content.html'))
    }
  }
}

# Save session info
if ('bldr' %in% rownames(installed.packages())) {
  bldr::save_session_info('data-raw/posts.log')
}
