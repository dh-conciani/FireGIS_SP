## Read libraries
library (lubridate)

## List LAFirA files
dest <- list.files ("./qa_S30MB1HA/", pattern = ".tif$", full.names=T)
file <- list.files ("./qa_S30MB1HA/", pattern = ".tif$", full.names=F)

## Extract metadata from filenames
sensor <- sapply(strsplit(file, split='_', fixed=TRUE), function(x) (x[1]))
processing_level <- sapply(strsplit(file, split='_', fixed=TRUE), function(x) (x[2]))
path_row <- sapply(strsplit(file, split='_', fixed=TRUE), function(x) (x[3]))
scene_date <- ymd(sapply(strsplit(file, split='_', fixed=TRUE), function(x) (x[4])))
year <- year(scene_date)
julian_day <- yday (scene_date)

## Create empty recipe
db_lafira <- as.data.frame(NULL)
db_lafira <- cbind (dest, file, sensor,processing_level, path_row, scene_date, year, julian_day)

## Export db
write.table(db_lafira, "./product_db/db_lafira.txt")
