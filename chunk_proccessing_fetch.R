# The purpose of this file is to calculate fetch for the coastline of Ireland in chunks, writing a csv file as it processes.

# Packages needed----
library(future)
library(furrr)
library(dplyr)
library(waver)
library(sf)
library(leaflet)
library(ggplot2)
library(progressr)

# Read the data----
fetch_area_5<-read.csv('area_5.csv')# smallest area for testing
fetch_coast <- st_read("IRE.shp")

# This is needed to combine all the landmasses. results will be inaccurate otherwise
fetch_coast <- st_union(fetch_coast)

# Points need to be sf object
points_sf<-st_as_sf(fetch_area_5,coords = c('long','lat'),crs=st_crs(fetch_coast))


# Visualise ----
## For test running and debugging
ggplot() +
  geom_sf(data = fetch_coast, fill = "lightblue", color = "darkblue", alpha = 0.5) +  
  geom_sf(data = points_sf, color = "red", size = 2) +  # Points
  theme_minimal()

# Fetch calculation inputs ----
num_intervals<-32
bearing_step<- 360/num_intervals
bear_seq<-seq(0,360-bearing_step,by=bearing_step)
print(bear_seq)
max_distance<-200000 ### In meters

# Parallel processing ----
## Set up for parallel processing (multisession compatible with Windows)
plan(multisession)  

## Define the chunk size (a chunk size of 80-120 seems to work well)
chunk_size <- ceiling(nrow(points_sf) / 15000)

## Split the points into chunks
chunks <- split(points_sf, ceiling(seq_along(1:nrow(points_sf)) / chunk_size))

## Change working directory to local/temp (onedrive causes problems when running for multiple days)
setwd("C:/Temp")

## Define the function to process each chunk and save directly to a csv
process_chunk <- function(chunk, bearings, fetch_coast, max_distance, append = TRUE) {
  chunk_results <- lapply(1:nrow(chunk), function(i) {
    ### Extract latitude and longitude
    coords <- st_coordinates(chunk[i, ])
    
    ### Process the chunk
    x <- fetch_len_multi(
      chunk[i, ], 
      bearings = bearings, 
      fetch_coast, 
      dmax = max_distance,
      method = 'clip') %>%
      as.data.frame() %>%
      mutate(
        total = rowSums(.), 
        ID = chunk$ID[i],
        lat = coords[1, "Y"], 
        long = coords[1, "X"]  
      )
    return(x)
  })
  
  ### Combine all results for the current chunk
  combined_chunk <- do.call(rbind, chunk_results)
  
  ### Write combined chunk to CSV
  write.table(
    combined_chunk, 
    file = 'fetch_area_4_processed_v1.csv', 
    append = append, 
    quote = FALSE, 
    col.names = !append,
    sep = ',', 
    row.names = FALSE
  )
}

# Process ----
handlers(global = TRUE)
plan(multisession,workers=10) 

with_progress({
  p <- progressor(along = chunks)
  future_map(
    chunks,
    function(chunk) {
      p() 
      process_chunk(chunk, bearings = bear_seq, fetch_coast, max_distance, append = TRUE)
    }
  )
})


