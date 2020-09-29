## LAFirA v.1
## Landsat Antrhopic Fire Algorithm 
## Dhemerson Conciani (dhemerson.conciani@unesp.br)

## Reclassify MapBiomas product to mask LAFirA

## Binarize to 1:
# 23 - Beach/ Dunes
# 24 - Urban
# 25 - Other Impermeable
# 29 - Rocky outcrop
# 30 - Mining 
## Other to 0

## Create reclassification matrix according lines 8:14
mapbiomas_reclass = cbind(c(1,   23,  24,  25,  26,  29,  30,  31,  33,  34),
                          c(22,  23,  24,  25,  28,  29,  30,  32,  33,  99),
                          c(0,    1,   1,   1,   0,   1,   1,   0,   1,   0))


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
path_mapbiomas <- ('./masks/MAPBIOMAS-EXPORT/')
mapbiomas_list <- list.files (path_mapbiomas, full.names=TRUE, pattern= ".tif$")

## Run reclass:
## Read MapBiomas raster
for (i in 1:length (mapbiomas_list))
        {
         ## Read MapBiomas raster
         r_mapbiomas <- raster (mapbiomas_list[i])

         ## Reclassify to ./bin_mask
         r_mask <- reclassify (r_mapbiomas, mapbiomas_reclass, right= NA, datatype= "INT2S")

         ## Export to ./bin_mask
         writeRaster(r_mask, paste0 ('./masks/MAPBIOMAS-EXPORT/bin_mask/', names(r_mask),
                                     '_bin_mask.tif'), overwrite=TRUE)
         ## Print and next
         print (names(r_mask)); print ("done, next...")
}

