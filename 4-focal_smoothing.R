# The purpose of this file is apply focal smoothing to the relative exposure index.

# Packages needed ----
library(terra)

# Load data ----
area_five <- rast("area_five_REI_normalised_10km.tif")
dist <- rast("distance_to_land_crop.tif")  ### in km

# Define a radius by distance function (in meters) ----
smooth_radius_fun <- function(d) {
  a <- 50      ### minimum radius nearshore
  b <- 500     ### scaling factor
  p <- 1.5     ### curvature exponent
  radius_m <- a + b * (d ^ p)
  pmin(radius_m, 2500)  ### cap at 2.5 km radius
}

## Compute per-pixel radius
radius_raster <- app(dist, smooth_radius_fun)

## Plot
plot(radius_raster)

## Gaussian smoothing function ----
gaussian_kernel <- function(radius_m, cellsize) {
  window_size <- round((radius_m * 2) / cellsize) + 1
  if (window_size %% 2 == 0) window_size <- window_size + 1
  sigma <- window_size / 6
  coords <- seq(-(window_size - 1) / 2, (window_size - 1) / 2)
  m <- outer(coords, coords, function(x, y) exp(-(x^2 + y^2) / (2 * sigma^2)))
  m / sum(m)
}

## Define cell size
cellsize <- res(area_five)[1]

# Define distance bands ----
distance_breaks <- seq(0, 10, by=0.1)  ### 0 to 10 km in 0.1 km steps
radius_values <- smooth_radius_fun(distance_breaks)  ### radius (m) for each band
test <- smooth_radius_fun(distance_breaks)
plot(distance_breaks, test,
     xlab = "Distance from shore (km)",
     ylab = "Smoothing radius (m)")

# Initialize output raster ----
r_smooth_adaptive <- area_five

# Loop through fine bands ----
for (i in seq_along(radius_values)) {
  radius_m <- radius_values[i]
  
  if (radius_m <= cellsize) next  ### skip trivial radius
  
  mask_band <- classify(dist, 
                        matrix(c(-Inf, distance_breaks[i], NA,
                                 distance_breaks[i], distance_breaks[i + 1], 1,
                                 distance_breaks[i + 1], Inf, NA),
                               ncol = 3, byrow = TRUE))
  
  mask_sum <- as.numeric(global(mask_band, "sum", na.rm = TRUE))
  
  if (!is.na(mask_sum) && mask_sum > 0) {
    w <- gaussian_kernel(radius_m, cellsize)
    smoothed_band <- focal(area_five, w = w, fun = mean, na.rm = TRUE, na.policy = "omit")
    smoothed_band <- mask(smoothed_band, mask_band)
    r_smooth_adaptive <- cover(smoothed_band, r_smooth_adaptive)
  }
}

## Plot 
plot(r_smooth_adaptive)

# Save ----
writeRaster(r_smooth_adaptive, "REI_focal_by_dist_v1.tif", overwrite = F)


