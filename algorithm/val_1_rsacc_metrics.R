## LAFirA v.1
## Landsat Antrhopic Fire Algorithm 
## Dhemerson Conciani (dhemerson.conciani@unesp.br)

## Compute validation statistics using rsaac

## Read libraries:
library (doParallel)
library (dplyr)
library (lubridate)
library (raster)
library (rsacc)
library (rgdal)
library (rgeos)
library (tools)

## Define dedicated threads:
## Core i7 5820K 3.3GHz // 64GB RAM // GTX 1060 6GB
cl <- makePSOCKcluster(11) 
registerDoParallel(cl)
options (scipen = 999)

## Define reclassification function
lafira_reclass = cbind(c(1,   2, 255),
                       c(1, 244, 255),
                       c(1,   0, 255))

## Set root
setwd('./')
## Define LAFirA product path
path_lafira <- ('./validation/val_scenes/_slope30_size16/')
## Define validation burned area path
path_val <- ("./validation/BA/219_76/")
## Define scene frame
scene_frame <- shapefile ("./validation/pol_scenes/219_76.shp"); scene_frame$ID = 0
## Create Recipe
data_219_76 <- as.data.frame (NULL)

## List files
lafira_list <- list.files (path_lafira, full.names=TRUE, pattern= ".tif$")
val_list <- list.files (path_val, full.names=TRUE, pattern= ".shp$")

## Extract basenames
lafira_names <- file_path_sans_ext(basename(lafira_list))
val_names <- file_path_sans_ext(basename(val_list))

## Extract dates to match LAFirA product and validation burned area
lafira_dates <- ymd( sapply (substr(lafira_names, start= 18, stop= 25), function(x) x))
val_dates <- ymd (val_names)

## Build location array by date
df_lafira <- data.frame (lafira_list, lafira_dates); colnames(df_lafira)[2] <- "date"
df_val <- data.frame (val_list, val_dates); colnames(df_val)[2] <- "date"

## match!!! <3 
matched <- left_join (df_lafira, df_val, by = "date"); matched = na.omit (matched)

## Function to val time serie
for (i in 1:nrow(matched))
    {
    # Read vector of burned areas
    shp_ba <- shapefile (as.character(matched$val_list[i])); shp_ba$ID = 1

    ## Drill frame with BA 
    drilled_frame <- erase (scene_frame, shp_ba)

    ## Merge Unburned (drilled frame) and burned (shp_ba)
    val_shp <- bind (drilled_frame, shp_ba)

    ## Read LAFirA equivalent product 
    r_lafira   <- raster (as.character(matched$lafira_list[i]))
    ## Reclassify LAFirA land-use into binary 
    bin_lafira <- reclassify (r_lafira, lafira_reclass, right=NA, datatype="INT2S")
    bin_lafira <- crop (bin_lafira, val_shp) # Crop LAFirA to val extent
    crs (val_shp) = crs (bin_lafira)

    ## compute confusion matrix
    cmat <- conf_mat (bin_lafira, val_shp, val_field= "ID")

    ## compute accuracy
    accuracy <- try (kia(cmat), silent=TRUE)
    if (inherits(accuracy, "try-error") == FALSE) 
        {
        ## create temporary file with accuracy metrics 
        LSID          = as.character(sapply (substr(path_val, start= 17, stop= 22), 
                                             function(x) x))
        Date          = matched$date[i]
        Overall_Acc   = accuracy$`Overall Accuracy`[1,]
        Overall_Error = accuracy$`Overall Accuracy`[2,]
        Kappa         = accuracy$`Overall Accuracy`[3,]
        Omi_Comi      = accuracy$`Class Accuracy`[2,]
        temp <- data.frame (LSID, Date, Overall_Acc, Overall_Error, Kappa, Omi_Comi)
        ## Build DF
        data_219_76 <- rbind (data_219_76, temp) } else 
            {
            ## create temporary file with accuracy metrics 
            LSID                = as.character(sapply (substr(path_val, start= 17, stop= 22), 
                                                       function(x) x))
            Date                = matched$date[i]
            Overall_Acc         = NA
            Overall_Error       = NA
            Kappa               = NA
            Omission.Error      = NA
            Comission.Error     = NA
            temp <- data.frame (LSID, Date, Overall_Acc,
                                 Overall_Error, Kappa, Omission.Error, Comission.Error)
            ## Build DF
            data_219_76 <- rbind (data_219_76, temp)
            }
        }

## Build maeged DFs
val_data <- rbind (data_219_76, data_220_75, data_221_74, data_222_76)
val_data$version <- "size16"

## Export data
write.table (val_data, "./validation/_tables/size16.txt", sep="\t")
