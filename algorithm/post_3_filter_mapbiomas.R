## LAFirA v.1
## Landsat Antrhopic Fire Algorithm 
## Dhemerson Conciani (dhemerson.conciani@unesp.br)

## Post-processing - Phase 1 
## Mask areas using binary masks from mapbiomas (v 4.1)
## @see vv_utils_1_reclass_mapbiomas.R

## Read libraries:
library (doParallel)
library (dplyr)
library (filesstrings)
library (lubridate)
library (raster)
library (rsacc)
library (rgdal)
library (rgeos)
library (tools)
library (igraph)

## Define dedicated threads:
## Core i7 5820K 3.3GHz // 64GB RAM // GTX 1060 6GB
cl <- makePSOCKcluster(11) 
registerDoParallel(cl)
options (scipen = 999)

## Set root
setwd('./')

## Define path and list LAFirA products:
path_lafira <- ('./predicted_3_slope/lote1/')
lafira_list <- list.files (path_lafira, full.names=TRUE, pattern= ".tif$")

## Define path and list MapBiomas v4.1 product:
path_mapbiomas <- ('./masks/MAPBIOMAS-EXPORT/bin_mask/')
mapbiomas_list <- list.files (path_mapbiomas, full.names=TRUE, pattern= ".tif$")

## Extract basenames to pair by dates:
## from LAFirA:
lafira_YYYY = sapply ( substr (file_path_sans_ext(
                       basename(lafira_list)), 
                       start= 18, stop=21), function (x) x)

## from MapBiomas:
mapbiomas_YYYY = sapply ( substr (file_path_sans_ext(
                          basename(mapbiomas_list)), 
                          start= 11, stop=14), function (x) x)

## Build position data.frames with YYYY info and match:
df_lafira    <- data.frame (lafira_list, lafira_YYYY); colnames(df_lafira)[2] <- "YYYY"
df_mapbiomas <- data.frame (mapbiomas_list, mapbiomas_YYYY); colnames(df_mapbiomas)[2] <- "YYYY"
matched <- left_join (df_lafira, df_mapbiomas, by = "YYYY"); matched = na.omit (matched)

## Run MapBiomas maskprocess: 
for (i in 1:nrow (matched)){
    ## Read LAFirA raster
    r_lafira <- raster (as.character(matched$lafira_list[i]))
    print (names(r_lafira))
    ## Read MapBiomas raster
    r_mapbiomas <- raster (as.character(matched$mapbiomas_list[i]))
    ## Crop MapBiomas as LAFIrA extent:
    ext_pol <- as (extent (r_lafira), "SpatialPolygons")
    proj4string (ext_pol) <- proj4string (r_lafira)
    ext_pol <- spTransform (ext_pol, CRS(proj4string(r_mapbiomas)))
    print ("Cropping mapbiomas")
    croped_mapbiomas <- crop (r_mapbiomas, ext_pol) 
    ## Project MapBiomas to LAFirA projection:
    print ("Rsampling and reprojecting mapbiomas from:")
    print (crs(croped_mapbiomas))
    print ("To:")
    print (crs(r_lafira))
    repro_mapbiomas <- projectRaster (croped_mapbiomas, r_lafira, method= "ngb")
    ## Mask LAFirA raster using MapBiomas:
    print ("Masking LAFirA with MapBiomas")
    v2 <- mask (r_lafira, repro_mapbiomas, maskvalue= 1, updatevalue= 12)

    ## Write filtered raster
    writeRaster(v2, paste0 ('./predicted_4_mapbiomas/', names(v2),
                            'MB.tif'), overwrite=TRUE)
    ## Clean memory
    rm (croped_mapbiomas, ext_pol, r_lafira, r_mapbiomas, repro_lafira,
    repro_mapbiomas, v2)
    gc()
    print (i/nrow(matched)*100)
    print (" moving file to ~./root/done path~, please wait...")
    file.move(as.character(matched$lafira_list[i]), "F:/dhemerson/slope/")
    print ("done! next...")
    ## Remore temp files
    removeTmpFiles(h=0)
    }

