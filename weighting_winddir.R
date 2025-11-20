# This script takes wind data and fetch lengths to create wind-weighted fetch. 

# Packages needed ----
library(sf)
library(terra)
library(tidyverse)
library(ggplot2)
library(purrr)

# Load MERA direction data ---- 
wind_dir <- rast('./galway_wind_dir_01082014_31082019.nc')

# Define 32 directional bins ----
bin_edges <- seq(0, 360, by = 11.25)
wind_props <- app(wind_dir, function(x) {
  if (all(is.na(x))) return(rep(NA, 32))
  dir_bin <- cut(x, breaks = bin_edges, include.lowest = TRUE, right = FALSE, labels = FALSE)
  tabulate(dir_bin, nbins = 32) / length(na.omit(x))
})
names(wind_props) <- paste0("dir_", 1:32)

## data check
app(wind_props, sum) ###confirm sum proportions equal 1


# resample ----
##50 m resolution (cublic spline to reduce artifacts)
target_rast <- rast(ext = ext(wind_dir), resolution = 50, crs = crs(wind_dir))

wind_props_smooth <- terra::resample(wind_props, target_rast, method = "cubicspline")

# normalise function fo IDs (this was only needed for original run)
normalize_ids <- function(x) {
  ### detect IDs with E prefix
  has_E <- grepl("^E", x)
  
  ### strip E, convert to numeric to unify formats
  nums <- as.numeric(gsub("^E", "", x))
  
  ### convert back to plain integer-style strings
  nums_chr <- format(nums, scientific = FALSE, trim = TRUE)
  
  ### reattach E where needed
  out <- ifelse(has_E, paste0("E", nums_chr), nums_chr)
  return(out)
}

# Define area IDs ----
#area_ids <- 1:11 ### when processing all 11 areas
area_ids<-5 ### just area 5 for testing

# Loop and combine ----
all_areas <- purrr::map_dfr(area_ids, function(area_num) {
  cat("Processing area:", area_num, "\n")
  
  ### Load fetch file
  fetch_file <- sprintf('./fetch_area_%s_processed_cleaned_v1.csv', area_num)
  
  fetch_df <- read.csv(fetch_file, header = T)

  ### Load points file
  points_file <- sprintf('./processed_cleaned_part_area_%s.csv', area_num)
  points <- read.csv(points_file)
  points_sf <- st_as_sf(points, coords = c("long", "lat"), crs = 4326)
  points_vect <- vect(st_transform(points_sf, crs = crs(wind_dir)))
  
  ### Extract wind
  wind_vals <- terra::extract(wind_props_smooth, points_vect)
  
  ### Combine with original sf object
  wind_vals$ID <- points_sf$ID
  
  ### Align by ID
  fetch_aligned <- fetch_df[order(fetch_df$ID), ]
  wind_aligned <- wind_vals[order(wind_vals$ID), ]
  
  
  fetch_aligned$ID <- normalize_ids(fetch_aligned$ID)
  wind_aligned$ID <- normalize_ids(wind_aligned$ID)
  
  wind_aligned <- wind_aligned[match(fetch_aligned$ID, wind_aligned$ID), ]
  stopifnot(all(fetch_aligned$ID == wind_aligned$ID))
  
  ### normalise
  fetch_aligned[1:32] <- fetch_aligned[1:32] / 200000
  
  ### Multiply and sum
  exposure_matrix <- fetch_aligned[, 1:32] * wind_aligned[, 2:33]
  total_exposure <- rowSums(exposure_matrix, na.rm = TRUE)
  
  ### Add exposure + ID + area info to points
  points_sf <- points_sf[order(points_sf$ID), ]
  points_sf$ID     <- normalize_ids(points_sf$ID)
  points_sf <- points_sf[match(fetch_aligned$ID, points_sf$ID), , drop = FALSE]
  
  points_sf$total_exposure <- total_exposure
  points_sf$area_id <- area_num
  points_sf$ID <- fetch_aligned$ID
  points_sf$mean_exposure<-rowMeans(exposure_matrix, na.rm = TRUE)
  return(points_sf)
})

# Convert to SpatVector ----
v <- vect(all_areas)

## Check  CRS
crs(v) 

## Reproject to EPSG:2157 - Irish Transverse Mercator
v_proj <- project(v, "EPSG:2157")  ### units now in meters

## Create raster template at 50m resolution
r_template <- rast(v_proj, resolution = 50)
crs(r_template) <- crs(v_proj)

## Rasterize 'total_exposure'
r_exposure <- rasterize(v_proj, r_template, field = "total_exposure", fun = "max")


# Plot it ----
plot(r_exposure)


# Any NA values that resulted from the point to raster conversion were filled with the surrounding mean values.
r_exposure_filled<-focal(r_exposure, w=3, fun=max, na.policy="only", na.rm=T)

plot(r_exposure_filled)

#writeRaster(r_exposure_filled, "weighted_log_sum_exposure_normalised_focal_10km_v3.tif", overwrite = TRUE)

# Save as GeoPackage
#st_write(all_areas, "all_weighted_fetch_normalised_10km_v3.shp")

