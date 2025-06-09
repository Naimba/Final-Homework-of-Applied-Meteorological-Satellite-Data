# -*- coding: utf-8 -*-
"""
Created on Mon Jun  9 10:13:23 2025

@author: Alphann
"""

import earthaccess
#import xarray as xr

# This will work if Earthdata prerequisite files have already been generated
auth = earthaccess.login()

# To download multiple files, change the second temporal parameter
results = earthaccess.search_data(
    short_name="GPM_3IMERGHH",
    version='07',
    temporal=('2024-06-10', '2024-06-10'), # This will stream one granule, but can be edited for a longer temporal extent
    bounding_box=(-180, -90, 180, 90)
)

# Download granules to local path
downloaded_files = earthaccess.download(
    results,
    local_path='E:/downloadtest', # Change this string to download to a different path
)

# OPTIONAL: Open granules using Xarray
#ds = xr.open_mfdataset(downloaded_files)
#print(ds)