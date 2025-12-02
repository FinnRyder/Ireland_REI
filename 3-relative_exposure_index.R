# The purpose of this file is to create a relative exposure index using wind weighted fetch and wind speed. 

# Packages needed ----
library(terra)
library(tidyverse)
library(sf)
library(archive)

# Load data ----
wind_speed <- rast('./mean_wind_01082014_31082019.nc')
zip_file<-"all_galway_bay_nomalised_fetch_dist.zipx"
archive_extract(zip_file)
area_five<-st_read("./all_galway_bay_nomalised_fetch_dist.shp")

### ttl_xps = total exposure (summed weighted fetch)
### mn_xpsr = mean exposure (mean weighted fetch)...not used 

# Process ----
## Create a target raster with same extent and CRS, but 50m resolution
target_rast<- rast(ext = ext(wind_speed), resolution = 50, crs = crs(wind_speed))

## Resample the wind data at 50m
wind_smooth<- resample(wind_speed, target_rast, method = "cubicspline")

head(wind_smooth)
plot(wind_smooth)

## same projection
area_five_proj<- st_transform(area_five, crs(wind_smooth))

## Extract
area5_wind_speed<- terra::extract(wind_smooth,area_five_proj)

## Join data
area_five_proj$ID<- as.numeric(area_five_proj$ID)
area5_combined<- area_five_proj %>%
  left_join(area5_wind_speed, by = "ID")

## Create exposure value
area5_combined$windspeed_weighted_fetch<- (area5_combined$ttl_xps*area5_combined$mean_wind)

# Convert to SpatVector ----
v2<- vect(area5_combined)

## Check CRS
crs(v2)

## Reproject to Irish Grid (EPSG:2157)
v_proj2<- project(v2, "EPSG:2157")

## Create raster template at 50m resolution
r_template2<- rast(v_proj2, resolution = 50)
crs(r_template2)<- crs(v_proj2)

## Rasterize using 'windspeed_weighted_fetch'
r_exposure2<- rasterize(v_proj2, r_template2, field = "windspeed_weighted_fetch", fun = "max",touches=TRUE)

## Plot
plot(r_exposure2)

## Any NA values that resulted from the point to raster conversion were filled with the surrounding mean values.
fetch_smooth<- terra::focal(r_exposure2, w = 3, fun = mean, na.policy="only", na.rm=T)
plot(fetch_smooth)

# Save data ----
writeRaster(fetch_smooth, "REI.tif", overwrite = F)

