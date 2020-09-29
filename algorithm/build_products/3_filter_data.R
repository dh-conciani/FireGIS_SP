## Read db
db <- read.table ("./product_db/db_lafira.txt")

## Select only L1TP processing level data
filtered_db <- db[which(db$processing_level == "L1TP"),]
write.table(filtered_db, "./product_db/filtered_db.txt")

## Compute number of removed scenes by path/row
db_processing_level <- as.data.frame (table(db$path_row, db$processing_level))
write.table(db_processing_level, "./product_db/db_processing_level.txt")
