## LAFirA v.1
## Landsat Antrhopic Fire Algorithm 
## Dhemerson Conciani (dhemerson.conciani@unesp.br)

## Post-processing
## Pixel Quality Assessment (pixel_qa)

## Read libraries:
library (doParallel)
library (dplyr)
library (lubridate)
library (raster)
library (rgdal)
library (tools)

## Define dedicated threads:
## Core i7 5820K 3.3GHz // 64GB RAM // GTX 1060 6GB
cl <- makePSOCKcluster(11) 
registerDoParallel(cl)

## Set root:
setwd('./')
## Define RAW LAFirA path:
path_lafira <- ('./predicted/222_76/')
## Define surface reflectance path 
path_sr <- ("F:/dhemerson/scenes/espa-dhemerson_conciani@yahoo.com.br-10282019-081354-021/done/")

## List files
lafira_list <- list.files (path_lafira, full.names=TRUE, pattern= ".tif$")
sr_list <- list.files (path_sr, full.names=TRUE, pattern= ".tar.gz$")

## Extract basenames
lafira_names <- file_path_sans_ext(basename(lafira_list))
sr_names <- file_path_sans_ext(basename(sr_list))

## Extract dates to match RAW LAFirA and pixel_qa
lafira_dates <- ymd( sapply (substr(lafira_names, start= 18, stop= 25), function(x) x))
sr_dates <- ymd (sapply (substr(sr_names, start= 11, stop= 18), function(x) x))

## Build location array by date
df_lafira <- data.frame (lafira_list, lafira_dates); colnames(df_lafira)[2] <- "date"
df_sr <- data.frame (sr_list, sr_dates); colnames(df_sr)[2] <- "date"

## match!!! <3 
matched <- left_join (df_lafira, df_sr, by = "date"); matched = na.omit (matched)

## Run 
for (i in 1:length (matched$sr_list)){
    ## Create ./temp dir to untar (tar.gz) files
    dir.create("./_tempPost")
    untar (tarfile= as.character(matched$sr_list[i]), exdir="./_tempPost/")
    ## Read RAW LAFirA
    r_lafira <- raster (as.character(matched$lafira_list[i]))
    ## Read pixel_qa
    r_qa <- raster(list.files ("./_tempPost/", pattern= "pixel_qa.tif", full.names=TRUE))
    ## Extract sensorname
    sensor <- sapply(substr(names(r_qa), start=1, stop=4), function(x) x)
    ## Read reclass matrix according sensor:
    ## Landsat 8 (OLI)
    if (sensor=="LC08") {
    # Clear bit values: 322, 386, 834, 898, fill=1
        l8_reclass   <- cbind(c(1,   2, 322, 323, 386, 387, 834, 835, 898,  899, 1346, 1347),
                             c(1, 321, 322, 385, 386, 833, 834, 897, 898, 1345, 1346, 2000),
                             c(0,   4,   0,   4,   0,   4,   0,   4,   0,    4,    0,    4))
                             mask <- reclassify (r_qa, l8_reclass, right=NA, datatype="INT2S")
                        } else {
                                ## Landsat 5 (TM) and 7 (ETM+)
                                # clear bit values: 66, 130, fill =1
                                l5_reclass <- cbind(c(1,   2,  66,  67, 130,  131),
                                                    c(1,  65,  66, 129, 130, 2000),
                                                    c(0,   4,   0,   4,   0,    4))
                                mask <- reclassify (r_qa, l5_reclass, right=NA, datatype="INT2S")
                        }
    ## Apply pixel_qa mask into RAW LAFirA product 
    lafira_qa <- mask (r_lafira, mask, maskvalue=4)
    print ("LAFirA BQA mask %:");print (i/length (matched$sr_list)*100)
    ## Write LAFirA pixel_qa masked
    writeRaster(lafira_qa, paste0 ('./predicted_qa/222_76/',
                                   names(r_lafira),
                                   '_qa.tif'), overwrite=TRUE, NAflag=255)
    ## Delete /temp* dir
    unlink ("./_tempPost", recursive= TRUE);gc() 
}
