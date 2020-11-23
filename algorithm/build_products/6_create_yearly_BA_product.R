## read libraries
library (raster)
library (rgeos)
library (rgdal)

## read db
db <- read.table ("./product_db/filtered_db_julian.txt")

## subset a tile row
tile <- subset (db, path_row == levels(as.factor(db$path_row))[9])
print (paste0("tile = ", levels(as.factor(tile$path_row))))

## extract temporal parameters
#seq_yr <- unique(tile$year)
seq_yr <- seq(1985, 2011)

## loop for
for (i in 1:length(seq_yr)) {
  print (paste0("processing ", seq_yr[i], " year"))
  print (paste0(i, " of ", length (seq_yr)))
  yr_list <- tile[grep(seq_yr[i], tile$year),]         ## subset n year
  #yr_list <- yr_list[5:16,]
  r_list <- lapply (yr_list$dest, raster)              ## read as raster
  
  ## compute extents and standardize all raster extents
  print ("extracting raster extents")
  r_extent <- lapply (r_list, extent)
  pol_extent <- lapply (r_extent, function (x) as(x, 'SpatialPolygons')) 
  ## create unique IDs Slot per scene
  for (j in 1:length(pol_extent)) {
    pol_extent[[j]]@polygons[[1]]@ID <- paste0("'",j,"'")
  }
  ## merge extents
  joined_polygons <- SpatialPolygons(lapply(pol_extent, function(x){x@polygons[[1]]}))
  joined_polygons <- as(joined_polygons,'SpatialPolygonsDataFrame')
  ## dissolve extents. raster cells outside extent are filled with NA 
  print ("filling raster outbounds with NA")
  r_resample <- lapply (r_list, function(x) extend (x, extent (gUnaryUnion(joined_polygons)), value = NA))
  gc()
  ###### ONLY FOR MINIMUM ######
  ## convert all 0 to NA
  r_resample <- lapply(r_resample, function(x) raster::clamp (x, lower=1, useValues=F))
  gc()
  ##############################
  
  ## stack raster
  r_stack <- stack (r_resample)
  gc()

  ## calc max julian day per pixel
  print ("building minimum/maximum julian day raster from stack")
  max_jd <- calc(r_stack, fun = min, na.rm=TRUE) 
  gc()
  
  ## export yearly product
  print ("exporting raster file")
  writeRaster(max_jd, paste0 ('./qa_S30MB1HA_JDYRMIN/',unique(tile$path_row),'_',seq_yr[i],'_','JDBAMIN.tif'), overwrite=TRUE, NAflag=-9999)
  print ("-----> done")
  rm (r_resample, r_stack)
  removeTmpFiles(h=0)
  gc()
}



