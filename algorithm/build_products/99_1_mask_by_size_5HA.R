## LAFirA v.1
## Landsat Antrhopic Fire Algorithm 
## Dhemerson Conciani (dhemerson.conciani@unesp.br)

## Post-processing - Phase 1 
## Remove Random Comission using size filter

## Read libraries:
library (doParallel)
library (dplyr)
library (lubridate)
library (raster)
library (rgdal)
library (rgeos)
library (tools)
library (igraph)
library (filesstrings)


## Define dedicated threads:
## Core i7 5820K 3.3GHz // 64GB RAM // GTX 1060 6GB
#cl <- makePSOCKcluster(11) 
#registerDoParallel(cl)
#options (scipen = 999)

## Set root
setwd('./')
## Define path and list LAFirA products
path_lafira <- ('./qa_S30MB1HA_JDYRMIN')
lafira_list <- list.files (path_lafira, full.names=TRUE, pattern= ".tif$")
lafira_names <- file_path_sans_ext(list.files (path_lafira, full.names=FALSE, pattern= ".tif$"))

## Define reclassification function (binarize BA)
lafira_reclass = cbind(c(0,   1),
                       c(0,   366),
                       c(0,   1))

## Run size filter: 
for (i in 1:length (lafira_list)){
  ## Read LFirA Raster
  r_lafira <- raster (lafira_list[i])
  ## Binarize burned area
  print (names (r_lafira))
  print ("convert LAFirA to binary BA")
  bin_lafira <- reclassify (r_lafira, lafira_reclass, right=NA, datatype="INT2S")
  ## Clump using Rook's case method
  print ("clump BA events using rooks method")
  clumped_lafira <- clump (bin_lafira, directions= 4)
  
  ## Apply size filter
  ## Count clump sizes
  print ("computing BA sizes")
  clump9 = data.frame (freq (clumped_lafira)) 
  ## Define size criteria and map pixel position
  excludeID <- clump9$value[which(clump9$count <= 55)]
  ## Apply filter
  print ("mapping BAs less than 5 hectares")
  clumped_lafira [clumped_lafira %in% excludeID] <- NA
  clumped_lafira [clumped_lafira > 0] <- 1
  
  ## Mask into LAFirA 
  print ("masking small burns into LAFirA scene")
  #r_lafira [r_lafira ==1] <- NA ## Create label to masked areas
  v2 <- mask (r_lafira, clumped_lafira)

  ## Write filtered raster
  writeRaster(v2, paste0 ('./qa_S30MB1HA_JDYRMIN_5HA_APP/', lafira_names[i],
                          '_5HA.tif'), overwrite=TRUE)
  ## Clean memory
  print (names(v2))
  print (i/length(lafira_list)*100)
  rm (bin_lafira, clump9, clumped_lafira, r_lafira, v2, excludeID)
  #file.move(lafira_list[i], "F:/dhemerson/mapbiomas/")
  print ("done! next...")
  ## Remore temp files
  removeTmpFiles(h=0)
}
