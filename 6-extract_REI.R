# The purpose of this file is to extract data from the relative exposure index from a csv of GPS points.Example points are from a field campaign in County Donegal for the SeaForest project.

# Packages needed----
library(terra)
library(tidyverse)
library(sf)
library(leaflet)

# Load data----
REI <- rast("Ireland_REI.tif")
waypoints<-read.csv("waypoints.csv")

# Check data ----
## View the relative exposure data
plot(REI)

## View the points to confirm location before extracting
leaflet(data = waypoints) %>% 
  addTiles() %>%
  addMarkers(~lon, ~lat)

# Process ----
## Convert to a sf object
waypoints_sf <- st_as_sf(x = waypoints,coords = c("lon", "lat"))

rp = project(REI,"epsg:4326") ### make sure the crs is the same
projcrs<-crs(rp)  ### set crs for rest of code

## Extract
donegal_exposure<-terra::extract(rp,waypoints_sf)
donegal_exposure$geometry<-waypoints_sf$geometry

## Create sf object
donegal_exposure_sf<- st_as_sf(donegal_exposure,crs=projcrs)
plot(donegal_exposure_sf)
names(donegal_exposure_sf)[2]<-'Exposure'

# Create a plot ----
fetch_coast<-st_read("IRL.shp")

ggplot()+
  geom_sf(data=donegal_exposure_sf,aes(colour=Exposure))+
  geom_sf(data=fetch_coast)+
  coord_sf(xlim=c(-8.25,-8.6),
           ylim=c(54.89,55.13))+
  scale_color_continuous(type = "viridis")

# Prep for saving ----
## Extract lat and lon for to save as a csv
exposure_lat_long <- donegal_exposure_sf %>%
  dplyr::mutate(
    lon = st_coordinates(.)[,1],
    lat = st_coordinates(.)[,2]
  )

## Remove geometry 
exposure_lat_long$geometry<-NULL

# Save ----
write.csv(exposure_lat_long, "donegal_exposure.csv",row.names = F)
