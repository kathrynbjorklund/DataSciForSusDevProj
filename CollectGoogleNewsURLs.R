# Collect Google News URLs

# Packages
library(tidyRSS)
library(lubridate)

# Base URL and search term for the RSS feed
keyword_base <- "https://news.google.com/rss/search?q=ebola+after:"

# Search date ranges
start_dates <- seq(ymd("2022-08-01"), ymd("2022-10-30"), by = "days") # seq() generates sequences of numbers
end_dates <- seq(ymd("2022-08-02"), ymd("2022-10-31"), by = "days")

# Empty list for storing data frames
results_list <- list()

# Loop through the date ranges and fetch the RSS feeds
for (i in seq_along(start_dates)) { # Starting a loop that goes through each date in start_dates, seq_along() generates the amount of dates there are, variable i used to keep track of which date currently on 
start_date <- start_dates[i] # Get the (i)th start date and assign it to the variable start_date
end_date <- end_dates[i] # Get the corresponding end date
keyword <- paste0(keyword_base, start_date, "+before:", end_date, "&ceid=US:eb&hl=en&gl=US") # Building custom Google News RSS URL 
# paste0() links the input values into a string
# (ceid=US:en - Country edition = United States, language = English; hl=en - Headline language = English; gl=US - Geolocation = United States)
  
# Fetch the RSS feed and handle errors
google_news <- try(tidyfeed(keyword, clean_tags = TRUE, parse_dates = TRUE), silent = TRUE)
# tidyfeed() downloads and reads news feed from URL stored in keyword
# clean_tags cleans up html tags in the news text 
# parse_dates turns date fields in feed into R date-time objects
# try() silent = TRUE put in so if URL fails, the error is stored inside google_news variable 
  
# Short delay
Sys.sleep(1) # Pauses the script for 1 second, to avoid overloading servers/hitting rate limits

# Check if the feed was fetched successfully
  if (inherits(google_news, "try-error")) {
    message(paste("Failed to fetch feed for date range:", start_date, "to", end_date))
    next
  }
# Checks if try() resulted in an error and prints a message if it did
# Uses next to skip to the next iteration of the loop

  # Convert the feed to a data frame and check for validity
  if (nrow(google_news) > 0) {
    df <- apply(google_news, 2, as.character)
    results_list[[i]] <- df
  } else {
    message(paste("No results for date range:", start_date, "to", end_date))
  }
}
# If the feed was fetched and has rows apply() converts each column to character
# If the feed is empty, message is printed instead

# Combine all data frames into one, if there are any results
if (length(results_list) > 0) {
  combined_df <- do.call(rbind, results_list)
# If at least one feed result was stored do.call(rbind, ) combines all data frames in results_list into one larger df stacking them row-wise
  
# Write the combined data frame to a CSV file
  write.csv(combined_df, "~/Desktop/ebola_news.csv", row.names = FALSE)
} else {
  message("No data collected.")
}
# Saves combined df to a .csv file 
# row.names = FALSE prevents R from adding row numbers as an extra column in csv file

# References
#"Scraping Google News with rvest for Keywords." Stack Overflow, 7 Jan. 2021, stackoverflow.com/questions/65520315/scraping-google-news-with-rvest-for-keywords.
