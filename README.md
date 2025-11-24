# Ireland_REI
Code used to create a relative exposure index for the coastline of Ireland. Workflow is limited to one section of coastline due to file size constraints. 

area_5 (inner Galway Bay) is the smallest area and is for testing code

'1-chunk_processing_fetch.R' is used to generate fetch lengths.

'2-weighting_windir.R' is used for weighting the fetch lenghts by wind direction.

'3-relative_exposure_index.R' creates the REI with wind-weighted fetch and mean wind speed.

'4-focal_smoothing.R' applies a guassian smoothing function to the REI, creating the final dataset.



