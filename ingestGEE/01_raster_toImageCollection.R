## upload fire spp as GEE asset

## import libraries
library(rgee)
library(raster)
library(jsonlite)
library(googleCloudStorageR)

ee_Initialize(gcs= TRUE)

## set output
output <- 'users/dh-conciani/fire_sp/'

## list files to upload
## burned area
files <- list.files('./raster', pattern= 'JDBAMIN', full.names= TRUE)
filenames <- list.files('./raster', pattern= 'JDBAMIN', full.names= FALSE)

for (i in 1:length(files)) {
  print(paste0(i, ' from ', length(files)))
  ## upload
  raster_as_ee(
    x= raster(files[i]),
    assetId= paste0(output, filenames[i]),
    bucket = 'fire_sp',
    predefinedAcl = "bucketLevel",
    command_line_tool_path = NULL,
    overwrite = FALSE,
    monitoring = TRUE,
    quiet = FALSE,
  )
}
