## read libraries
library (raster)
library (rgeos)
library (rgdal)

## list JBYR
r_list <- list.files("./qa_S30MB1HA_JDYR/", pattern=".tif$", full.names= TRUE)
r_names <- tools::file_path_sans_ext(list.files("./qa_S30MB1HA_JDYR/", pattern=".tif$", full.names= FALSE))

## Define binarization matrix
bin_mat = cbind(c(0,   1),
                c(0,   366),
                c(0,   1))

## batch bin
for (i in 1:length(r_list)) {
  print ("reading raster")
  r <- raster(r_list[i])
  print ("01100010 01101001 01101110")
  rcl <- reclassify (r, bin_mat)
  print ("exporting bin")
  print (names(r[i]))
  writeRaster(rcl, paste0 ('./qa_S30MB1HA_YR_BIN/',r_names[i],"_BIN.tif"), overwrite=TRUE, NAflag=-9999)
  print ("-----> done")
  removeTmpFiles(h=0)
  gc()
}