## read libraries
library (raster)

## read db
db <- read.table ("./product_db/filtered_db.txt")

## Loop for start
for (i in 1:nrow(db)) {
  r <- raster (db$dest[i])
  
  loading <- paste0(as.character(i), " of " , as.character(nrow(db))) 
  print (loading)
  print (names(r))
  
  reclass_matrix <- cbind(c(1, 2),
                          c(1, 999),
                          c(db$julian_day[i], 0))

  r_jd <- reclassify (r, reclass_matrix, right=NA, datatype="INT2S")

  writeRaster(r_jd, paste0 ('./qa_S30MB1HA_JD/', names(r_jd),'_JD16.tif'), overwrite=TRUE, NAflag=-9999)
  print ("----> done")
  removeTmpFiles(h=0.5)
}
