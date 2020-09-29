## LAFirA v.1
## Landsat Antrhopic Fire Algorithm 
## Dhemerson Conciani (dhemerson.conciani@unesp.br)

## Post-processing - Phase 2
## Filter impermeable zones (urban and roads)
## Use edge filters

## Read libraries:
library (doParallel)
library (dplyr)
library (raster)
library (rsacc)
library (rgdal)
library (tools)

## Define dedicated threads:
## Core i7 5820K 3.3GHz // 64GB RAM // GTX 1060 6GB
cl <- makePSOCKcluster(11) 
registerDoParallel(cl)
options (scipen = 999) 

## Set root:
setwd('./')
## Define path and list LAFirA size filtered products:
path_lafira <- ('./validation/val_scenes/size11/')
lafira_list <- list.files (path_lafira, full.names=TRUE, pattern= ".tif$")

## Create a reclassification matrix:
## 1= BA; 4= Construction
lafira_reclass = cbind(c(1,   2,    4,  5,   6,  7,    255),
                       c(1,   3,    4,  5,   6,  244,  255),
                       c(1,   NA,   4,  NA,  4,  NA,   NA))

## Run urban zones filter:
for (i in 1:length(lafira_list)) {
    ## Read LAFirA product
    r_lafira <- raster (lafira_list[i])

    ## Reclassify LAFirA product to BA and construction raster:  
    r_class <- reclassify (r_lafira, lafira_reclass, 
                           right= NA, datatype= "INT2S")
    ## Compute data.frame of cell positions
    data <- as.data.frame (r_class); names (data)[1] = "value"

    ## Binarize BA, clump and extract total edges
    r_ba <- r_class; r_ba[r_ba > 1] <- NA
    r_ba <- clump (r_ba, directions = 4)
    ba_edge <- boundaries (r_ba, type= "inner", direction= 4, asNA = T)

    ## Extract class pixel positions 
    ID_BA <- as.numeric(row.names(subset (data, value==1)))
    ID_UR <- as.numeric(row.names(subset (data, value==4)))

    ## Extract adjacencies between BA and Constructions
    r_adj <- adjacent (r_class, cells= ID_UR, target = ID_BA, 
                       pairs = FALSE, directions= 4)

    ## Create adjacent edge raster
    ## value == 50 as the bitcode for adjacent pixel 
    overlap_edge <- r_class 
    overlap_edge [1:ncell(overlap_edge) %in% r_adj] <- 50
    overlap_edge [overlap_edge < 50] <- NA

    ## Build scene stack
    r <- stack (r_ba, ba_edge, overlap_edge)
    names (r) <- c ("BA clumps", 
                    "Total edges", 
                    "Shared edges")

    ## Extract BA ID and edge presences, put on a data.frame:
    data <- as.data.frame (r)

    ## Extract informations by BA ID
    size <- as.data.frame(table (data$BA.clumps))
    n.edge <- as.data.frame (table (data$BA.clumps,data$Total.edges))
    shared <- as.data.frame (table (data$BA.clumps, data$Shared.edges))

    ## Create filter data.frame
    data <- size 
    names (data)[1] <- "ID"; names (data)[2] <- "size"
    data$n.edge     <- n.edge$Freq
    data$shared     <- shared$Freq
    data$p.edge     <- data$n.edge / data$size * 100
    data$p.shared   <- data$shared / data$n.edge * 100

    ## Apply filters
    ## Exclude shared borders among BA and Constructions 
    ## The criteria as percentage of total BA border shared 
    excludeID <- as.numeric (data$ID[which(data$p.shared > 50)])
    r_ba [r_ba %in% excludeID] <- NA
    r_ba [r_ba > 0] <- 1

    ## Mask into LAFirA 
    r_lafira [r_lafira ==1] <- 91 ## Create label to masked areas
    v2 <- mask (r_lafira, r_ba, maskvalue= 1, updatevalue= 1)

    ## Write filtered raster
    writeRaster(v2, paste0 ('./validation/val_scenes/imper50/', names(v2),
                        '_imper50.tif'), overwrite=TRUE)
    ## Clean memory
    print (names(v2))
    rm (ba_edge, data, n.edge, overlap_edge,r, r_ba, r_lafira, shared,
    size, v2, excludeID, ID_BA, ID_UR, r_adj, r_class)
    print (i/length(lafira_list)*100)
    print ("done! next...")
}