## Match list of rasters and Spatial Polygons using string parameter
## Extract cell values in stack 
## Runs on Landsat 7 (ETM+) sensor
## Dhemerson Conciani (dh.conciani@gmail.com)

## Read packages
library (raster)
library (rgdal)
library (tools)
library (lubridate)
library (stringr)
library (dplyr)
library (maptools)

## Map rasters and polygons location into a list
raster_loc <- list.files(path = './train_scenes/s_barb/ETM', pattern = '.tif$', full.names = T)
ba_loc <- list.files(path = './train_pols/burned_area/s_barb/', pattern = '.shp$', full.names = T)
const_loc <- list.files(path = './train_pols/construction/s_barb/', pattern = '.shp$', full.names = T)
esoil_loc <- list.files(path = './train_pols/e_soil/s_barb/', pattern = '.shp$', full.names = T)
gcover_loc <- list.files(path = './train_pols/green_cover/s_barb/', pattern = '.shp$', full.names = T)
harv_loc <- list.files(path = './train_pols/harvest/s_barb/', pattern = '.shp$', full.names = T)
road_loc <- list.files(path = './train_pols/road/s_barb/', pattern = '.shp$', full.names = T)
shadow_loc <- list.files(path = './train_pols/shadow/s_barb/', pattern = '.shp$', full.names = T)
water_loc <- list.files(path = './train_pols/water/s_barb/', pattern = '.shp$', full.names = T)

# Get only basenames
raster_list_names <- file_path_sans_ext(basename(raster_loc))
ba_list_names <- file_path_sans_ext(basename(ba_loc))
const_list_names <- file_path_sans_ext(basename(const_loc))
esoil_list_names <- file_path_sans_ext(basename(esoil_loc))
gcover_list_names <- file_path_sans_ext(basename(gcover_loc))
harv_list_names <- file_path_sans_ext(basename(harv_loc))
road_list_names <- file_path_sans_ext(basename(road_loc))
shadow_list_names <- file_path_sans_ext(basename(shadow_loc))
water_list_names <- file_path_sans_ext(basename(water_loc))

## Extract dates from string names
raster_dates = sapply(substr(raster_list_names, start=16, stop=25), function(x) x)
ba_dates = sapply(substr(ba_list_names, start=1, stop=10), function(x) x)
const_dates = sapply(substr(const_list_names, start=1, stop=10), function(x) x)
esoil_dates = sapply(substr(esoil_list_names, start=1, stop=10), function(x) x)
gcover_dates = sapply(substr(gcover_list_names, start=1, stop=10), function(x) x)
harv_dates = sapply(substr(harv_list_names, start=1, stop=10), function(x) x)
road_dates = sapply(substr(road_list_names, start=1, stop=10), function(x) x)
shadow_dates = sapply(substr(shadow_list_names, start=1, stop=10), function(x) x)
water_dates = sapply(substr(water_list_names, start=1, stop=10), function(x) x)

## Replace "_" separators for "-" used in date variables
raster_dates = sapply(gsub("_", "-", raster_dates), function(x) x)
ba_dates = sapply(gsub("_", "-", ba_dates), function(x) x)
const_dates = sapply(gsub("_", "-", const_dates), function(x) x)
esoil_dates = sapply(gsub("_", "-", esoil_dates), function(x) x)
gcover_dates = sapply(gsub("_", "-", gcover_dates), function(x) x)
harv_dates = sapply(gsub("_", "-", harv_dates), function(x) x)
road_dates = sapply(gsub("_", "-", road_dates), function(x) x)
shadow_dates = sapply(gsub("_", "-", shadow_dates), function(x) x)
water_dates = sapply(gsub("_", "-", water_dates), function(x) x)

## Convert character variables into date
raster_dates <- ymd (raster_dates)
ba_dates <- ymd (ba_dates)
const_dates <- ymd (const_dates)
esoil_dates <- ymd (esoil_dates)
gcover_dates <- ymd (gcover_dates)
harv_dates <- ymd (harv_dates)
road_dates <- ymd (road_dates)
shadow_dates <- ymd (shadow_dates)
water_dates <- ymd (water_dates)

## Make data_frames
df_raster = data.frame (raster_loc, raster_dates)
df_ba = data.frame (ba_loc, ba_dates)
df_const = data.frame (const_loc, const_dates)
df_esoil = data.frame (esoil_loc, esoil_dates)
df_gcover = data.frame (gcover_loc, gcover_dates)
df_harv = data.frame (harv_loc, harv_dates)
df_road = data.frame (road_loc, road_dates)
df_shadow = data.frame (shadow_loc, shadow_dates)
df_water = data.frame (water_loc, water_dates)

## Rename date columns to same var
colnames(df_raster)[2] <- "date"
colnames(df_ba)[2] <- "date"
colnames(df_const)[2] <- "date"
colnames(df_esoil)[2] <- "date"
colnames(df_gcover)[2] <- "date"
colnames(df_harv)[2] <- "date"
colnames(df_road)[2] <- "date"
colnames(df_shadow)[2] <- "date"
colnames(df_water)[2] <- "date"

## Match date coincidences between rasters and polygons
match_ba <- left_join(df_raster, df_ba, by= "date")
match_const <- left_join(df_raster, df_const, by= "date")
match_esoil <- left_join(df_raster, df_esoil, by= "date")
match_gcover <- left_join(df_raster, df_gcover, by= "date")
match_harv <- left_join(df_raster, df_harv, by= "date")
match_road <- left_join(df_raster, df_road, by= "date")
match_shadow <- left_join(df_raster, df_shadow, by= "date")
match_water <- left_join(df_raster, df_water, by= "date")

## Remove non-match rows (unburned; cloudy; noData)
match_ba <- na.omit (match_ba)
match_const <- na.omit (match_const)
match_esoil <- na.omit (match_esoil)
match_gcover <- na.omit (match_gcover)
match_harv <- na.omit (match_harv)
match_road <- na.omit (match_road)
match_shadow <- na.omit (match_shadow)
match_water <- na.omit (match_water)

## extract per class
## burned area
r_list <- as.character (match_ba$raster_loc)
p_list <- as.character (match_ba$ba_loc)
date_list <- as.character (match_ba$date)
sensor_list <- rep ("ETM", length(r_list))
class_list <- rep ("BA", length(r_list))

## List length, used to build 'for'
list_count <- length (r_list)

# Create a data.frame to receive data
BA_ETM_data_entries <- data.frame (NULL)

## Extract values for each stack and build a data.frame
for (i in 1:list_count) {
  #read stack
  r <- stack(r_list[[i]])
  #extract only basename
  bname <- file_path_sans_ext(basename(r_list[[i]]))
  #define band names
  names(r) <- c("Blue", "Green", "Red", "NIR", "SWIR1", "SWIR2")
  #read shapefile
  r_poly <- shapefile(p_list[[i]])
  #read date
  date <- date_list[[i]]
  ##read sensor
  sensor <- sensor_list[[i]]
  ## read class
  class <- class_list[[i]]
  ## extract values
  temp <- extract(r, r_poly, cellnumbers=FALSE, df=TRUE)
  temp <- data.frame (bname, date, class, sensor, temp)
  ## build data.frame
  BA_ETM_data_entries <- rbind (BA_ETM_data_entries, temp)
}

## extract per class
## construction
r_list <- as.character (match_const$raster_loc)
p_list <- as.character (match_const$const_loc)
date_list <- as.character (match_const$date)
sensor_list <- rep ("ETM", length(r_list))
class_list <- rep ("const", length(r_list))

## List length, used to build 'for'
list_count <- length (r_list)

# Create a data.frame to receive data
CONST_ETM_data_entries <- data.frame (NULL)

## Extract values for each stack and build a data.frame
for (i in 1:list_count) {
  #read stack
  r <- stack(r_list[[i]])
  #extract only basename
  bname <- file_path_sans_ext(basename(r_list[[i]]))
  #define band names
  names(r) <- c("Blue", "Green", "Red", "NIR", "SWIR1", "SWIR2")
  #read shapefile
  r_poly <- shapefile(p_list[[i]])
  #read date
  date <- date_list[[i]]
  ##read sensor
  sensor <- sensor_list[[i]]
  ## read class
  class <- class_list[[i]]
  ## extract values
  temp <- extract(r, r_poly, cellnumbers=FALSE, df=TRUE)
  temp <- data.frame (bname, date, class, sensor, temp)
  ## build data.frame
  CONST_ETM_data_entries <- rbind (CONST_ETM_data_entries, temp)
}

## extract per class
## esoil
r_list <- as.character (match_esoil$raster_loc)
p_list <- as.character (match_esoil$esoil_loc)
date_list <- as.character (match_esoil$date)
sensor_list <- rep ("ETM", length(r_list))
class_list <- rep ("esoil", length(r_list))

## List length, used to build 'for'
list_count <- length (r_list)

# Create a data.frame to receive data
ESOIL_ETM_data_entries <- data.frame (NULL)

## Extract values for each stack and build a data.frame
for (i in 1:list_count) {
  #read stack
  r <- stack(r_list[[i]])
  #extract only basename
  bname <- file_path_sans_ext(basename(r_list[[i]]))
  #define band names
  names(r) <- c("Blue", "Green", "Red", "NIR", "SWIR1", "SWIR2")
  #read shapefile
  r_poly <- shapefile(p_list[[i]])
  #read date
  date <- date_list[[i]]
  ##read sensor
  sensor <- sensor_list[[i]]
  ## read class
  class <- class_list[[i]]
  ## extract values
  temp <- extract(r, r_poly, cellnumbers=FALSE, df=TRUE)
  temp <- data.frame (bname, date, class, sensor, temp)
  ## build data.frame
  ESOIL_ETM_data_entries <- rbind (ESOIL_ETM_data_entries, temp)
}

## extract per class
## gcover
r_list <- as.character (match_gcover$raster_loc)
p_list <- as.character (match_gcover$gcover_loc)
date_list <- as.character (match_gcover$date)
sensor_list <- rep ("ETM", length(r_list))
class_list <- rep ("gcover", length(r_list))

## List length, used to build 'for'
list_count <- length (r_list)

# Create a data.frame to receive data
GCOVER_ETM_data_entries <- data.frame (NULL)

## Extract values for each stack and build a data.frame
for (i in 1:list_count) {
  #read stack
  r <- stack(r_list[[i]])
  #extract only basename
  bname <- file_path_sans_ext(basename(r_list[[i]]))
  #define band names
  names(r) <- c("Blue", "Green", "Red", "NIR", "SWIR1", "SWIR2")
  #read shapefile
  r_poly <- shapefile(p_list[[i]])
  #read date
  date <- date_list[[i]]
  ##read sensor
  sensor <- sensor_list[[i]]
  ## read class
  class <- class_list[[i]]
  ## extract values
  temp <- extract(r, r_poly, cellnumbers=FALSE, df=TRUE)
  temp <- data.frame (bname, date, class, sensor, temp)
  ## build data.frame
  GCOVER_ETM_data_entries <- rbind (GCOVER_ETM_data_entries, temp)
}

## extract per class
## harvest
r_list <- as.character (match_harv$raster_loc)
p_list <- as.character (match_harv$harv_loc)
date_list <- as.character (match_harv$date)
sensor_list <- rep ("ETM", length(r_list))
class_list <- rep ("harv", length(r_list))

## List length, used to build 'for'
list_count <- length (r_list)

# Create a data.frame to receive data
HARV_ETM_data_entries <- data.frame (NULL)

## Extract values for each stack and build a data.frame
for (i in 1:list_count) {
  #read stack
  r <- stack(r_list[[i]])
  #extract only basename
  bname <- file_path_sans_ext(basename(r_list[[i]]))
  #define band names
  names(r) <- c("Blue", "Green", "Red", "NIR", "SWIR1", "SWIR2")
  #read shapefile
  r_poly <- shapefile(p_list[[i]])
  #read date
  date <- date_list[[i]]
  ##read sensor
  sensor <- sensor_list[[i]]
  ## read class
  class <- class_list[[i]]
  ## extract values
  temp <- extract(r, r_poly, cellnumbers=FALSE, df=TRUE)
  temp <- data.frame (bname, date, class, sensor, temp)
  ## build data.frame
  HARV_ETM_data_entries <- rbind (HARV_ETM_data_entries, temp)
}

## extract per class
## road
r_list <- as.character (match_road$raster_loc)
p_list <- as.character (match_road$road_loc)
date_list <- as.character (match_road$date)
sensor_list <- rep ("ETM", length(r_list))
class_list <- rep ("road", length(r_list))

## List length, used to build 'for'
list_count <- length (r_list)

# Create a data.frame to receive data
ROAD_ETM_data_entries <- data.frame (NULL)

## Extract values for each stack and build a data.frame
for (i in 1:list_count) {
  #read stack
  r <- stack(r_list[[i]])
  #extract only basename
  bname <- file_path_sans_ext(basename(r_list[[i]]))
  #define band names
  names(r) <- c("Blue", "Green", "Red", "NIR", "SWIR1", "SWIR2")
  #read shapefile
  r_poly <- shapefile(p_list[[i]])
  #read date
  date <- date_list[[i]]
  ##read sensor
  sensor <- sensor_list[[i]]
  ## read class
  class <- class_list[[i]]
  ## extract values
  temp <- extract(r, r_poly, cellnumbers=FALSE, df=TRUE)
  temp <- data.frame (bname, date, class, sensor, temp)
  ## build data.frame
  ROAD_ETM_data_entries <- rbind (ROAD_ETM_data_entries, temp)
}

## extract per class
## shadow
r_list <- as.character (match_shadow$raster_loc)
p_list <- as.character (match_shadow$shadow_loc)
date_list <- as.character (match_shadow$date)
sensor_list <- rep ("ETM", length(r_list))
class_list <- rep ("shadow", length(r_list))

## List length, used to build 'for'
list_count <- length (r_list)

# Create a data.frame to receive data
SHADOW_ETM_data_entries <- data.frame (NULL)

## Extract values for each stack and build a data.frame
for (i in 1:list_count) {
  #read stack
  r <- stack(r_list[[i]])
  #extract only basename
  bname <- file_path_sans_ext(basename(r_list[[i]]))
  #define band names
  names(r) <- c("Blue", "Green", "Red", "NIR", "SWIR1", "SWIR2")
  #read shapefile
  r_poly <- shapefile(p_list[[i]])
  #read date
  date <- date_list[[i]]
  ##read sensor
  sensor <- sensor_list[[i]]
  ## read class
  class <- class_list[[i]]
  ## extract values
  temp <- extract(r, r_poly, cellnumbers=FALSE, df=TRUE)
  temp <- data.frame (bname, date, class, sensor, temp)
  ## build data.frame
  SHADOW_ETM_data_entries <- rbind (SHADOW_ETM_data_entries, temp)
}

## extract per class
## water
r_list <- as.character (match_water$raster_loc)
p_list <- as.character (match_water$water_loc)
date_list <- as.character (match_water$date)
sensor_list <- rep ("ETM", length(r_list))
class_list <- rep ("water", length(r_list))

## List length, used to build 'for'
list_count <- length (r_list)

# Create a data.frame to receive data
WATER_ETM_data_entries <- data.frame (NULL)

## Extract values for each stack and build a data.frame
for (i in 1:list_count) {
  #read stack
  r <- stack(r_list[[i]])
  #extract only basename
  bname <- file_path_sans_ext(basename(r_list[[i]]))
  #define band names
  names(r) <- c("Blue", "Green", "Red", "NIR", "SWIR1", "SWIR2")
  #read shapefile
  r_poly <- shapefile(p_list[[i]])
  #read date
  date <- date_list[[i]]
  ##read sensor
  sensor <- sensor_list[[i]]
  ## read class
  class <- class_list[[i]]
  ## extract values
  temp <- extract(r, r_poly, cellnumbers=FALSE, df=TRUE)
  temp <- data.frame (bname, date, class, sensor, temp)
  ## build data.frame
  WATER_ETM_data_entries <- rbind (WATER_ETM_data_entries, temp)
}

## merge 
df_ETM <- rbind (BA_ETM_data_entries, CONST_ETM_data_entries, ESOIL_ETM_data_entries,
                GCOVER_ETM_data_entries, HARV_ETM_data_entries, ROAD_ETM_data_entries,
                SHADOW_ETM_data_entries, WATER_ETM_data_entries)

## Remove /$~temp objects
rm (df, df_poly, df_raster, poly_dates, poly_list_count, poly_list_names, 
    poly_loc, raster_dates, raster_list_count, raster_list_names, 
    raster_loc, r_list, p_list, list_count, r, bname, r_poly, temp, matchs,
    i, date_list, sensor_list, date, sensor, hole, p_nba, ref_shp, scene_points,
    r_test, pol_ref, BA_ETM_data_entries, CONST_ETM_data_entries, df_ba, df_const,
    df_esoil, df_gcover, df_harv, df_road, df_shadow, df_water, ESOIL_ETM_data_entries,
    GCOVER_ETM_data_entries, HARV_ETM_data_entries, match_ba, match_const, match_esoil,
    match_gcover, match_harv, match_road, match_shadow, match_water, ROAD_ETM_data_entries,
    SHADOW_ETM_data_entries, WATER_ETM_data_entries, ba_dates, ba_list_names,
    ba_loc, class, class_list, const_dates, const_list_names, const_dates, const_loc,
    esoil_dates, esoil_list_names, esoil_loc, gcover_dates, gcover_list_names, gcover_loc,
    harv_dates, harv_list_names, harv_loc, road_dates, road_list_names, road_loc,
    shadow_dates, shadow_list_names, shadow_loc, water_dates, water_list_names, water_loc)

