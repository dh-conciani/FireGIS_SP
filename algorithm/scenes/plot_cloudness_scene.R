## Process USGS raw scenes list
## Convert to scenes list by path/row to order ESPA level-2 surface reflectance

## read libraries
library (plyr)
library (ggplot2)
library (gridExtra)

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
## extract YYYY and MM datestring
landsat_scenes$Year <-  sapply(strsplit(as.character(
  landsat_scenes$Acquisition.Date), split='/', fixed=TRUE), function(x) (x[1]))
landsat_scenes$Month <- sapply(strsplit(as.character(
  landsat_scenes$Acquisition.Date), split='/', fixed=TRUE), function(x) (x[2]))

## Plot cloudness
ggplot (landsat_scenes, aes (x= Month, y= Scene.Cloud.Cover, 
  colour= Path.Row, group= Path.Row)) +
  geom_jitter(alpha=0.03) + 
  geom_smooth(method="loess", alpha=0.2, se=F, size= 0.8) +
  scale_color_manual(values=c("firebrick4", "red", "orange", "yellow", "olivedrab", "green1", "blueviolet","blue","black")) +
  xlab('Mês do ano') + 
  ylab('Cobertura de nuvens (%)') +
  theme_bw() 

## Plot exploratory graphs scenes avaliability 
## split using 0.25 intervals
landsat_scenes_75 <- subset (landsat_scenes, Scene.Cloud.Cover < 76, drop=TRUE )
landsat_scenes_50 <- subset (landsat_scenes, Scene.Cloud.Cover < 51, drop=TRUE )
landsat_scenes_25 <- subset (landsat_scenes, Scene.Cloud.Cover < 25, drop=TRUE )
landsat_scenes_0 <- subset (landsat_scenes, Scene.Cloud.Cover < 1, drop=TRUE )

## all scenes
cl_100 <- ggplot (landsat_scenes, aes (x= Month, colour= Path.Row, group= Path.Row)) +
  geom_line(stat="count", size=0.7) +
  scale_color_manual(name=NULL, values=c("firebrick4", "red", "orange", "yellow", "olivedrab", "green1", "blueviolet","blue","black")) +
  xlab(NA) + 
  ylab('Disponibilidade de cenas') +
  ggtitle("<100% Nuvem") +
#  scale_y_continuous(breaks= c(0,20,40,60,80,100), labels=c (0, 20,40,60,80,100)) +
  theme_bw() +
  theme(legend.position = "none") +
  theme(axis.title.x=element_blank()) +
  ylim(0, 70)

## 75% cloud cover
cl_75 <- ggplot (landsat_scenes_75, aes (x= Month, colour= Path.Row, group= Path.Row)) +
  geom_line(stat="count", size=0.7) +
  scale_color_manual(name=NULL, values=c("firebrick4", "red", "orange", "yellow", "olivedrab", "green1", "blueviolet","blue","black")) +
  xlab('Meses do ano') + 
  ylab('Disponibilidade de cenas') +
  ggtitle("<75% Nuvem") +
  theme_bw() +
  theme(legend.position = "none") +
  theme(axis.title.x=element_blank()) +
  ylim(0, 70)

## 50% cloud cover
cl_50 <- ggplot (landsat_scenes_50, aes (x= Month, colour= Path.Row, group= Path.Row)) +
  geom_line(stat="count", size=0.7) +
  scale_color_manual(name=NULL, values=c("firebrick4", "red", "orange", "yellow", "olivedrab", "green1", "blueviolet","blue","black")) +
  xlab('Meses do ano') + 
  ylab('Disponibilidade de cenas') +
  ggtitle("<50% Nuvem") +
  theme_bw() +
  theme(legend.position = "none") +
  theme(axis.title.x=element_blank()) +
  ylim(0, 70)

## 25% cloud cover
cl_25 <- ggplot (landsat_scenes_25, aes (x= Month, colour= Path.Row, group= Path.Row)) +
  geom_line(stat="count", size=0.7) +
  scale_color_manual(name=NULL, values=c("firebrick4", "red", "orange", "yellow", "olivedrab", "green1", "blueviolet","blue","black")) +
  xlab('Meses do ano') + 
  ylab('Disponibilidade de cenas') +
  ggtitle("<25% Nuvem") +
  theme_bw() +
  theme(legend.position = "none") +
  theme(axis.title.x=element_blank()) +
  ylim(0, 70)

## 0% cloud cover
cl_0 <- ggplot (landsat_scenes_0, aes (x= Month, colour= Path.Row, group= Path.Row)) +
  geom_line(stat="count", size=0.7) +
  scale_color_manual(name= NULL, values=c("firebrick4", "red", "orange", "yellow", "olivedrab", "green1", "blueviolet","blue","black")) +
  xlab('Meses do ano') + 
  ylab('Disponibilidade de cenas') +
  ggtitle("0% Nuvem") +
  theme_bw() +
  theme(legend.position = "none") +
  ylim(0, 70) +
  theme(axis.title.x=element_blank())

##Plot
grid.arrange(cl_100, cl_75, cl_50, cl_25, cl_0, nrow=5, ncol=1)

## Plot 75
ggplot (landsat_scenes_75, aes (x= Month, colour= Path.Row, group= Path.Row)) +
  geom_line(stat="count", size=0.8) +
  scale_color_manual(name="Path.Row", values=c("firebrick4", "red", "orange", "yellow", "olivedrab", "green1", "blueviolet","blue","black")) +
  xlab('Mês do ano') + 
  ylab('n de cenas disponíveis') +
#  ggtitle("<75% Nuvem") +
  theme_bw() +
#  theme(legend.position = "none") +
  ylim(0, 70)
