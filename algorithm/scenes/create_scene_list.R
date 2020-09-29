## Process USGS raw scenes list
## Convert to scenes list by path/row to order ESPA level-2 surface reflectance

## read libraries
library (plyr)

## list csv
csv_files <- list.files ("./usgs_csv/", pattern = ".csv$", full.names= TRUE)
csv_length <- length (csv_files) ## extract length to apply for {}

## create empty recipe to bind
landsat_scenes <- as.data.frame(NULL)

## bind csvs 
for (i in 1:csv_length){
  icsv <- read.csv (csv_files[i], sep=",")
  landsat_scenes <- rbind.fill (icsv, landsat_scenes)
}
rm (icsv, csv_files, csv_length, i); gc()

## concatenate path_row
landsat_scenes$Path.Row <- paste0 (landsat_scenes$WRS.Path, sep="_", landsat_scenes$WRS.Row)

## split using 75% cloudness threeshould
landsat_scenes_75 <- subset (landsat_scenes, Scene.Cloud.Cover < 76, drop=TRUE )
landsat_scenes_75$Path.Row <- as.factor (landsat_scenes_75$Path.Row)

## create .txt files by path-row
list_count = length (levels(landsat_scenes_75$Path.Row))
for (i in 1:list_count){
splited_list <- subset (landsat_scenes_75, Path.Row==levels(landsat_scenes_75$Path.Row)[i], drop=TRUE)
write.table (splited_list[1],
             paste("./order_to_espa/", levels(landsat_scenes_75$Path.Row)[i], ".txt"),
             col.names=F, row.names= F)
}

## summary 
print("dist");table (landsat_scenes_75$Path.Row)
print("soma");sum(table (landsat_scenes_75$Path.Row))

