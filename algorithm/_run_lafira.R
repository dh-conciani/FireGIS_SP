## LAFirA v.1
## Landsat Antrhopic Fire Algorithm 
## Dhemerson Conciani (dhemerson.conciani@unesp.br)

## Classify Landsat scenes into:
# 1. Burned Area
# 2. Bare soil
# 3. Green Cover
# 4. Settlements
# 5. Harvest
# 6. Road
# 7. Shadow
# 8. Water

## Read libraries:
library (doParallel)
library (filesstrings)
library (randomForest)
library (raster)
library (RStoolbox)
library (tools)

## Define dedicated threads:
## Core i7 5820K 3.3GHz // 64GB RAM // GTX 1060 6GB
cl <- makePSOCKcluster(11) 
registerDoParallel(cl)

## Set work directories and load LAFirA:
setwd('./')
path_scenes <- ("F:/dhemerson/scenes/espa-dhemerson_conciani@yahoo.com.br-10282019-081354-021")
load("./classifier/LAFirA_classifier.RData") 

## List landsat .tar.gz compressed files:
scene_list <- list.files (path_scenes, full.names=TRUE, pattern= "tar.gz$")

## Run LAFirA v1.0
for (i in 1:length (scene_list)){
    ## Create ./temp dir to untar (tar.gz) files
    dir.create("./_temp")
    untar (tarfile= scene_list[i], exdir="./_temp/")
    ## Extract sensorname
    sensor <- sapply(substr(file_path_sans_ext(
        basename(scene_list[i])), start=1, stop=4), function(x) x)
    ## Read Surface Reflectance (level-2) according sensor:
    if (sensor=="LC08") {
        ## Inputs for Landsat 8 (OLI):
        r_blue  <- raster (list.files ('./_temp/', full.names= T, pattern='sr_band2.tif$'))
        r_green <- raster (list.files ('./_temp/', full.names= T, pattern='sr_band3.tif$'))
        r_red   <- raster (list.files ('./_temp/', full.names= T, pattern='sr_band4.tif$'))
        r_nir   <- raster (list.files ('./_temp/', full.names= T, pattern='sr_band5.tif$'))
        r_swir1 <- raster (list.files ('./_temp/', full.names= T, pattern='sr_band6.tif$'))
        r_swir2 <- raster (list.files ('./_temp/', full.names= T, pattern='sr_band7.tif$'))
    } else {
        ## Inputs for Landsat 5 (TM) and 7 (ETM+):
        r_blue  <- raster (list.files ('./_temp/', full.names= T, pattern='sr_band1.tif$'))
        r_green <- raster (list.files ('./_temp/', full.names= T, pattern='sr_band2.tif$'))
        r_red   <- raster (list.files ('./_temp/', full.names= T, pattern='sr_band3.tif$'))
        r_nir   <- raster (list.files ('./_temp/', full.names= T, pattern='sr_band4.tif$'))
        r_swir1 <- raster (list.files ('./_temp/', full.names= T, pattern='sr_band5.tif$'))
        r_swir2 <- raster (list.files ('./_temp/', full.names= T, pattern='sr_band7.tif$'))
    }
    ## Compute spectral index:
    r_ndvi  <- (r_nir - r_red)/(r_nir + r_red)
    r_gndvi <- (r_nir - r_green)/(r_nir + r_green)
    r_msavi <- r_nir + 0.5 - (0.5 * sqrt(2 * r_nir + 1)^2 - 8 * (r_nir - (2 * r_red)))
    r_ndwi  <- (r_green - r_nir)/(r_green + r_nir)
    r_slavi <- r_nir/(r_red + r_swir2)
    r_nbr   <- ((r_nir - r_swir1) / (r_nir + r_swir1))
    r_baim  <- 1 / ((0.05 - r_nir)^2 + (0.2 - r_swir1)^2)
    r_csi   <- r_nir / r_swir1
    r_mirbi <- 10 * r_swir1 - 9.8 * r_nir + 2
    r_s2    <- (r_blue - r_red) / (r_blue + r_red)
    r_iri   <- sqrt ((r_nir^2 + r_swir2^2) / r_swir1)
    ## Stack Surface Reflectance and Spectral Index
    r_stack <- stack (r_blue, r_green, r_red, r_nir, r_swir1, r_swir2, r_ndvi, r_gndvi, r_msavi, r_ndwi, r_slavi, r_nbr, r_baim, r_csi, r_mirbi, r_s2, r_iri); names(r_stack) <- c ("Blue", "Green", "Red", "NIR", "SWIR1", "SWIR2", "NDVI", "GNDVI", "MSAVI", "NDWI", "SLAVI", "NBR", "BAIM", "CSI", "MIRBI", "S2", "IRI")
    ## Clear Memory and dele ./temp dir 
    rm (r_blue, r_green, r_red, r_nir, r_swir1, r_swir2, r_ndvi, r_gndvi, r_msavi, r_ndwi, r_slavi,         r_nbr, r_baim, r_csi, r_mirbi, r_s2, r_iri); gc()
    ## Apply LAFirA:
    print ("LAFirA Progress:");print (i/length (scene_list)*100)
    print ("Current Scene Progress:"); print (scene_list[i])
    Pred <- predict (r_stack, rfModel, 
                     progress = 'text', 
                     type='response', 
                     na.rm= TRUE, 
                     inf.rm= TRUE)
    ## Write LAFirA classification
    writeRaster(Pred, paste0 ('./predicted/222_76/', 
                              substr(list.files("./_temp/")[2], start=1, stop=41),
                              'LAFirAv1.tif'), overwrite=TRUE)
    ## Move tar.gz processed to the /done path
    file.move(scene_list[i], paste0(path_scenes,"/done/"))
    ## Delete ./temp dir
    unlink ("./_temp", recursive= TRUE)
    print("Done! next...")
}
