# Ireland_REI

[![DOI](https://zenodo.org/badge/1085096005.svg)](https://doi.org/10.5281/zenodo.17817079)

Code used to create a relative exposure index for the coastline of Ireland. The main workflow (scripts 1 - 4) is limited to one section of coastline due to file size constraints. 
area_5 (inner Galway Bay) is the smallest area and therefore the area for testing code.  

📄 Code
---------

**1-chunk_processing_fetch.R** - Generates basic fetch distances in 32 directions.

**2-weighting_windir.R** - Weights the fetch distances by wind direction.

**3-relative_exposure_index.R** - Creates the REI with wind-weighted fetch and mean wind speed.

**4-focal_smoothing.R** - Applies a guassian smoothing function to the REI, creating the final dataset.

**5-validation.R** - Correlation analysis of the REI and SWAN model.

**6-extract_REI.R** - Extracts REI values from a *csv file containing GPS coordinates.


📁 Files
---------

**IRE.zip** - Coastline data for Ireland only. Used in ```1-chunk_processing_fetch.R```.

**area_5.csv** - Inner Galway Bay is the smallest area and is for testing code. Used in ```1-chunk_processing_fetch.R```.

**fetch_area_5_proccessed_cleaned_v1.csv** - Fetch distances for points in inner Galway Bay. Created in ```1-chunk_processing_fetch.R```. Used in ```2-weighting_windir.R```.

**galway_wind_dir01082014_31082019.zipx** - MÉRA wind direction data for inner Galway Bay. Used in ```2-weighting_windir.R```.

**mean_wind_01082014_31082019.zipx** - MÉRA mean wind speed data. Used in ```3-relative_exposure_index.R```.

**distance_to_land_crop.tif** - Distance to land raster for inner Galway Bay. Used for focal smoothing. Used in ```4-focal_smoothing.R```.

**irish_shelf_overall_max_hs.tif** - SWAN model outputs for validation. Used in ```5-validation.R```.

**irish_shelf_overall_mean_hs.tif** - SWAN model outputs for validation. Used in ```5-validation.R```.

**waypoints.csv** - GPS points for example of extracting REI values. Used in ```6-extract_REI.R```.

**Ireland_REI** - The relative exposure index. Created in ```4-focal_smoothing.R```. Used in ```5-validation.R``` and ```6-extract_REI.R```.


🤝 Acknowledgments
---------
Thank you to Met Éireann, Ireland’s National Meteorological Service for providing the wind data (```mean_wind_01082014_31082019.zipx``` and ```galway_wind_dir01082014_31082019.zipx```) used to create the relative exposure index. Thanks also to the Irish Marine Institute for providing the SWAN model data (```irish_shelf_overall_mean_hs.tif``` and ```irish_shelf_overall_max_hs.tif```) used to validate the REI. This work was funded by the Department of Housing, Local Government and Heritage, Republic of Ireland.
