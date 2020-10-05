# Dhemerson Conciani (dh.conciani@gmail.com)
# Reproject list of rasters using reference

# Read packages
library (raster)
library (rgdal)
library (tools)
library (svMisc)

# Read archive with reference projection (In this example, a shapefile)
reference_to_crop <- shapefile ("H:/shps/limites/buffer_SEBS_22N.shp")
reference <- shapefile ('H:/shps/limites/buffer_SEBS.shp')

# Get reference projection
ref_proj <- crs(reference)

# Get the list of rasters
raster_list <- list.files(path = 'H:/machine_learning/sta_barbara/_training/imgs/', pattern = '.tif$', full.names = T)
list_count <- length(raster_list)

# Get only basenames
list_names <- file_path_sans_ext(basename(raster_list))

# Reproject using reference 
for (i in 1:list_count) {
  ##print progress
  print(i)
  progress(i)
  Sys.sleep(0.01)
  #read in raster
  r <- stack(raster_list[[i]])
  ##crop to minor without reproject
  r <- crop (r, reference_to_crop)
  #perform reprojection
  projected_raster <- projectRaster(r, crs = ref_proj)
  #crop to reference extent
  croped_raster <- crop (projected_raster, reference)
  #write each reprojected raster to a new file 
  writeRaster(croped_raster, paste0 ('H:/machine_learning/sta_barbara/_training/imgs/_reproj/',list_names[i],'.tif'), overwrite=TRUE)
}

