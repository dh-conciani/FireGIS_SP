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
path_lafira <- ('./predicted_2_qa/')
lafira_list <- list.files (path_lafira, full.names=TRUE, pattern= ".tif$")

## Read ALOS bin mask product:
r_alos <- raster ('./masks/ALOS_SLOPE_30M/bin_mask/LAFirA_ALOS_SLOPE30M_30.tif')

## Run MapBiomas maskprocess: 
for (i in 1:length (lafira_list)){
    ## Read LAFirA raster
    r_lafira <- raster (lafira_list[i])
    print (names(r_lafira))
    ## Crop ALOS as LAFIrA extent:
    error_test <- try (identicalCRS (r_lafira, repro_alos), silent= TRUE)
    if (inherits (error_test, "try-error") == TRUE )
        {         
                  print ("first file, initialing process")
                  ext_pol <- as (extent (r_lafira), "SpatialPolygons")
                  proj4string (ext_pol) <- proj4string (r_lafira)
                  ext_pol <- spTransform (ext_pol, CRS(proj4string(r_alos)))
                  croped_alos <- crop (r_alos, ext_pol) 
                  ## Project ALOS to LAFirA projection:
                  print ("running ALOS reprojection")
                  repro_alos <- projectRaster (croped_alos, r_lafira, method= "ngb")
    } else {
                    if (identicalCRS (r_lafira, repro_alos) == FALSE)
                      { rm (repro_alos)
                        print ("different projections between LAFirA and ALOS :(")
                        ext_pol <- as (extent (r_lafira), "SpatialPolygons")
                        proj4string (ext_pol) <- proj4string (r_lafira)
                        ext_pol <- spTransform (ext_pol, CRS(proj4string(r_alos)))
                        croped_alos <- crop (r_alos, ext_pol)
                        ## Project ALOS to LAFirA projection:
                        print ("running reprojection")
                        repro_alos <- projectRaster (croped_alos, r_lafira, method= "ngb")
                  }  
        else { 
                  if (inherits (try (compareRaster (r_lafira, repro_alos), silent=TRUE), 
                                "try-error") == TRUE)
                      {
                         rm (repro_alos)
                         print ("same projection with different extents :(")
                         print ("cropping ALOS")
                         ext_pol <- as (extent (r_lafira), "SpatialPolygons")
                         proj4string (ext_pol) <- proj4string (r_lafira)
                         ext_pol <- spTransform (ext_pol, CRS(proj4string(r_alos)))
                         croped_alos <- crop (r_alos, ext_pol)
                         ## Project ALOS to LAFirA projection:
                         print ("running reprojection")
                         repro_alos <- projectRaster (croped_alos, r_lafira, method= "ngb") 
                          }
              else {
                    print ("projections match <3")
              }
        }
    }
    
    ## Mask LAFirA raster using ALOS slope:
    print ("masking LAFirA")
    v2 <- mask (r_lafira, repro_alos, maskvalue= 1, updatevalue= 11)

    ## Write filtered raster
    writeRaster(v2, paste0 ('./predicted_3_slope/', names(v2),
                            '_S30.tif'), overwrite=TRUE)
    ## Clean memory
    rm (repro_alos, error_test, croped_alos, ext_pol, r_lafira, v2)
    print (i/length(lafira_list)*100)
    print (" moving file to ~./root/done path~, please wait...")
    file.move(lafira_list[i], "./predicted_2_qa/done/")
    gc()
    print ("done, next!")
}

