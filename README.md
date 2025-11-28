# Ireland_REI
Code used to create a relative exposure index for the coastline of Ireland. Workflow is limited to one section of coastline due to file size constraints. 
area_5 (inner Galway Bay) is the smallest area and therefore the area for testing code.

📄 Code
---------

**1-chunk_processing_fetch.R** - Generates basic fetch distances in 32 directions.

**2-weighting_windir.R** - Weights the fetch distances by wind direction.

**3-relative_exposure_index.R** - Creates the REI with wind-weighted fetch and mean wind speed.

**4-focal_smoothing.R** - Applies a guassian smoothing function to the REI, creating the final dataset.

**5-validation.R** - Correlation analysis of the REI and SWAN model.

**6-extract_REI.R** - Extracts REI values from a csv file containing GPS coordinates.


📁 Files
---------

**IRE.zip** - Coastline data for Ireland only. Used in ```1-chunk_processing_fetch.R```.

**area_5.csv** - Inner Galway Bay is the smallest area and is for testing code. Used in ```1-chunk_processing_fetch.R```.

**fetch_area_5_proccessed_cleaned_v1.csv** - Fetch distances for points in inner Galway Bay. Created in ```1-chunk_processing_fetch.R```. Used in ```2-weighting_windir.R```.

**galway_wind_dir01082014_31082019.zipx** - MÉRA wind direction data for inner Galway Bay. Used in ```2-weighting_windir.R```.

**mean_wind_01082014_31082019.zipx** - MÉRA mean wind speed data. Used in ```3-relative_exposure_index.R```.

**distance_to_land_crop.tif** - Distance to land raster for inner Galway Bay. Used for focal smoothing. Used in ```4-focal_smoothing.R```.

**waypoints.csv** - GPS points for example of extracting REI values. Used in ```6-extract_REI.R```.

**processed_cleaned_part_area_5.csv** 



🔗 Links
---------



🤝 Acknowledgments
---------
Thank you to Met Éireann and the Marine Institute for providing the data to create and validate the relative exposure index. This work was funded by the Department of Housing, Local Government and Heritage, Republic of Ireland.
