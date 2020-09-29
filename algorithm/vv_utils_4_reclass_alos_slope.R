## LAFirA v.1
## Landsat Antrhopic Fire Algorithm 
## Dhemerson Conciani (dhemerson.conciani@unesp.br)

## Reclassify ALOS product to mask LAFirA

## Binarize to 1:
## Slope less than 40&
## less than 30%
## less than 20%
## less than 10%

## Create reclassification permitting slope 10%
alos_10 = cbind(c(0,    10),
                c(10,  100),
                c(0,    1))

## Create reclassification permitting slope 20%
alos_20 = cbind(c(0,   20),
                c(20, 100),
                c(0,    1))

## Create reclassification permitting slope 30%
alos_30 = cbind(c(0,    30),
                c(30,  100),
                c(0,     1))

## Create reclassification permitting slope 30%
alos_40 = cbind(c(0,    40),
                c(40,  100),
                c(0,     1))

## Read libraries:
library (raster)
library (doParallel)

## Define dedicated threads:
## Core i7 5820K 3.3GHz // 64GB RAM // GTX 1060 6GB
cl <- makePSOCKcluster(11) 
registerDoParallel(cl)

## Set root
setwd('./')

## Define path and list LAFirA products:
path_alos <- ('./masks/ALOS_SLOPE_30M/')
alos_list <- list.files (path_alos, full.names=TRUE, pattern= ".tif$")

## Run reclass:
## Read ALOS raster
for (i in 1:length (alos_list))
        {
         ## Read ALOS raster
         r_alos <- raster (alos_list[i])

         ## Reclassify slope 10
         print ("slope 10% reclass")
         r_10 <- reclassify (r_alos, alos_10, right= NA, datatype= "INT2S")
         print ("slope 20% reclass")
         r_20 <- reclassify (r_alos, alos_20, right= NA, datatype= "INT2S")
         print ("slope 30% reclass")
         r_30 <- reclassify (r_alos, alos_30, right= NA, datatype= "INT2S")
         print ("slope 40% reclass")
         r_40 <- reclassify (r_alos, alos_40, right= NA, datatype= "INT2S")

         ## Export to ./bin_mask
         writeRaster(r_10, paste0 ('./masks/ALOS_SLOPE_30M/bin_mask/', names(r_10),
                                     '_10.tif'), overwrite=TRUE)
         writeRaster(r_20, paste0 ('./masks/ALOS_SLOPE_30M/bin_mask/', names(r_20),
                                     '_20.tif'), overwrite=TRUE)
         writeRaster(r_30, paste0 ('./masks/ALOS_SLOPE_30M/bin_mask/', names(r_30),
                                     '_30.tif'), overwrite=TRUE)
         writeRaster(r_40, paste0 ('./masks/ALOS_SLOPE_30M/bin_mask/', names(r_40),
                                     '_40.tif'), overwrite=TRUE)
}

