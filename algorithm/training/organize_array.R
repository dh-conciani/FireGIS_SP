## Post processing and data management of 'match_extract' algorithm
## Dhemerson Conciani (dh.conciani@gmail.com)

## Read packages
library (stringr)
library (lubridate)
library (tools)

## Build a unified data.frame between all sensors
assis_reflectance <- data.frame (NULL)
assis_reflectance <- rbind (df_TM, df_ETM, df_OLI)
#assis_reflectance <- df_TM
#rm(df_TM, s_barb_reflectance)

## Rename columns
names(assis_reflectance)[1] <- "Scene"
names(assis_reflectance)[2] <- "Date"
names(assis_reflectance)[3] <- "Class"
names(assis_reflectance)[4] <- "Sensor"

## Insert local
Local <- rep ("assis", nrow(assis_reflectance))
assis_reflectance$Local <- Local

## Remove /*temp
rm (TM_data_entries, ETM_data_entries, OLI_data_entries,
    TM_non_burned, ETM_non_burned, OLI_non_burned, Local, dem, dem_focal,
    class_reflectance, df_ETM, df_OLI, df_TM)
