## LAFirA v.1
## Landsat Antrhopic Fire Algorithm 
## Dhemerson Conciani (dhemerson.conciani@unesp.br)

## Post-processing - Build APP product
## Use reference data in sites when it exists

## Read libraries:
library (rgdal)
library (raster)
library (lubridate)

## Set root
setwd('./')

## Define path of the BA product (raster, actual version)
prod_loc <- "./qa_S30MB1HA_JDYRMIN_5HA_APP/"

## Define output to export reference rasterizations
ref_exp <- "./AQM_REF/raster/"

## Read references BA
ref_ba <- readOGR("./AQM_REF/AQMS_w_init.shp")

## create julian day variable
ref_ba$date <- as.Date(ref_ba$date)
ref_ba$julian <- yday(ref_ba$date)

## define path/row from id class
ref_ba$path <- ref_ba$city ## clone city 
ref_ba$path <- gsub("Assis","221076",ref_ba$path) ## rewrite using ID
ref_ba$path <- gsub("Santa Barbara","221076",ref_ba$path) ## rewrite using ID
ref_ba$path <- gsub("Itirapina","220075",ref_ba$path) ## rewrite using ID

## read mask extents and given pathrow
ref_out <- readOGR("./AQM_REF/extent_mask.shp")
ref_out$path <- ref_out$city ## clone city 
ref_out$path <- gsub("Assis","221076",ref_out$path) ## rewrite using ID
ref_out$path <- gsub("Santa Barbara","221076",ref_out$path) ## rewrite using ID
ref_out$path <- gsub("Itirapina","220075",ref_out$path) ## rewrite using ID

## rasterize by Landsat path/row
for (i in 1:length(unique(ref_ba$path))) {
  ### create subsamples of reference by path
  pol <- subset(ref_ba, path == unique(ref_ba$path)[i])
  ### remove 2012 (need revision)
  pol <- subset(pol, year != "2012")
  pol_ye <- subset(ref_out,  path == unique (ref_out$path)[i])
  #### create subsamples by year ~ path
  for (j in 1:length(levels(as.factor(pol$year)))) {
    ##### read a given yearly vector
    pol_y <- subset(pol, year== unique(pol$year)[j])
    ##### read the reference raster (actual product version)
    r <- raster(paste0(prod_loc,unique(pol_y$path),"_",unique(pol_y$year),"_","JDBAMIN","_","5HA",".tif"))
    print(names(r))
    ##### reproject ref outbounds to Landsat CRS
    pol_ye <- spTransform(pol_ye, crs(r))
    ##### Mask actual raster with the extent that we wanna update
    filled_r <- mask(r, pol_ye, inverse= TRUE)
    ##### reproject vector from BA to product CRS
    pol_y <- spTransform(pol_y, crs(r))
    ##### create mask
    r_mask <- raster(crs = projection(r), ext = extent(r))
    res(r_mask)=30 ## set 30x30 m as native resolution
    ##### rasterize reference vector
    r_ref <- rasterize(x= pol_y, y= r_mask, field = pol_y$julian, fun= "first", update= TRUE, updateValue= "NA")
    ##### stack update + filled actual product
    r_stack <- stack(r_ref, filled_r)
    ##### merge products 
    r_merged <- calc(r_stack, fun = max, na.rm=TRUE) 
    ##### Export rasterized
    writeRaster(r_merged, paste0(ref_exp,unique(pol_y$path),"_",unique(pol_y$year),"_","JDBAMIN_5HA",".tif"))
    ##### Remove temp files
    removeTmpFiles(h=0)
    print("done ---->")
  }
}
