# Ireland_REI
Code used to create a relative exposure index for the coastline of Ireland. Workflow is limited to one section of coastline due to file size constraints. 
area_5 (inner Galway Bay) is the smallest area and is for testing code.

Code
---------

**1-chunk_processing_fetch.R** is used to generate fetch lengths.

**2-weighting_windir.R** is used for weighting the fetch lenghts by wind direction.

**3-relative_exposure_index.R** creates the REI with wind-weighted fetch and mean wind speed.

**4-focal_smoothing.R** applies a guassian smoothing function to the REI, creating the final dataset.


Files
---------

**IRE.zip** - Coastline data for Ireland only.

**area_5.csv** - Inner Galway Bay is the smallest area and is for testing code.

**fetch_area_5_proccessed_cleaned_v1.csv** - Fetch lengths for points in inner Galway Bay. Created in '1-chunk_processing_fetch.R'.

**galway_wind_dir01082014_31082019.zipx** - Mera wind direction data for inner Galway Bay.

**mean_wind_01082014_31082019.zipx** -  - Mera mean wind speed data.

**distance_to_land_crop.tif** - Distance to land raster for inner Galway Bay. Used for focal smoothing.
