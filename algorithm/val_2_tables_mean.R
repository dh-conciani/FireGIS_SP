## LAFirA v.1
## Landsat Antrhopic Fire Algorithm 
## Dhemerson Conciani (dhemerson.conciani@unesp.br)

## Build general tables to test filter size improvement:

## Read libraries:
library (ggplot2)
library (lubridate)
library (plyr)
library (stringr)
library (tools)

## Read validation tables: 
data <- read.table ("./validation/_tables/validation_step1_step2.txt", header=TRUE)
data <- na.omit (data)

## Calc metrics by class:
##  Raw LAFirA
kappa <- ddply (subset (data, version == "raw"), ~LSID, summarise, mean= mean(Kappa))
Comis <- ddply (subset (data, version == "raw"), ~LSID, summarise, mean= mean(Comission.Error))
Omiss <- ddply (subset (data, version == "raw"), ~LSID, summarise, mean= mean(Omission.Error))
kappa$metric <- "Kappa"; kappa$Filter <- "raw"
Comis$metric <- "Comission"; Comis$Filter <- "raw"
Omiss$metric <- "Omission"; Omiss$Filter <- "raw"
raw <- rbind (kappa, Omiss, Comis)
Mean <- ddply (raw, ~metric, summarise, mean= mean (mean))
Mean$LSID = "Mean"; Mean$Filter = "raw"
raw <- rbind (raw, Mean)
rm (kappa, Omiss, Comis, Mean)

## MapBiomas Filter:
kappa <- ddply (subset (data, version == "mapbiomas"), ~LSID, summarise, mean= mean(Kappa))
Comis <- ddply (subset (data, version == "mapbiomas"), ~LSID, summarise, mean= mean(Comission.Error))
Omiss <- ddply (subset (data, version == "mapbiomas"), ~LSID, summarise, mean= mean(Omission.Error))
kappa$metric <- "Kappa"; kappa$Filter <- "mapbiomas"
Comis$metric <- "Comission"; Comis$Filter <- "mapbiomas"
Omiss$metric <- "Omission"; Omiss$Filter <- "mapbiomas"
mapbiomas <- rbind (kappa, Omiss, Comis)
Mean <- ddply (mapbiomas, ~metric, summarise, mean= mean (mean))
Mean$LSID = "Mean"; Mean$Filter = "mapbiomas"
mapbiomas <- rbind (mapbiomas, Mean)
rm (kappa, Omiss, Comis, Mean)

## Slope 40:
kappa <- ddply (subset (data, version == "slope40"), ~LSID, summarise, mean= mean(Kappa))
Comis <- ddply (subset (data, version == "slope40"), ~LSID, summarise, mean= mean(Comission.Error))
Omiss <- ddply (subset (data, version == "slope40"), ~LSID, summarise, mean= mean(Omission.Error))
kappa$metric <- "Kappa"; kappa$Filter <- "slope40"
Comis$metric <- "Comission"; Comis$Filter <- "slope40"
Omiss$metric <- "Omission"; Omiss$Filter <- "slope40"
slope40 <- rbind (kappa, Omiss, Comis)
Mean <- ddply (slope40, ~metric, summarise, mean= mean (mean))
Mean$LSID = "Mean"; Mean$Filter = "slope40"
slope40 <- rbind (slope40, Mean)
rm (kappa, Omiss, Comis, Mean)

## Slope 30
kappa <- ddply (subset (data, version == "slope30"), ~LSID, summarise, mean= mean(Kappa))
Comis <- ddply (subset (data, version == "slope30"), ~LSID, summarise, mean= mean(Comission.Error))
Omiss <- ddply (subset (data, version == "slope30"), ~LSID, summarise, mean= mean(Omission.Error))
kappa$metric <- "Kappa"; kappa$Filter <- "slope30"
Comis$metric <- "Comission"; Comis$Filter <- "slope30"
Omiss$metric <- "Omission"; Omiss$Filter <- "slope30"
slope30 <- rbind (kappa, Omiss, Comis)
Mean <- ddply (slope30, ~metric, summarise, mean= mean (mean))
Mean$LSID = "Mean"; Mean$Filter = "slope30"
slope30 <- rbind (slope30, Mean)
rm (kappa, Omiss, Comis, Mean)


## Slope 20
kappa <- ddply (subset (data, version == "slope20"), ~LSID, summarise, mean= mean(Kappa))
Comis <- ddply (subset (data, version == "slope20"), ~LSID, summarise, mean= mean(Comission.Error))
Omiss <- ddply (subset (data, version == "slope20"), ~LSID, summarise, mean= mean(Omission.Error))
kappa$metric <- "Kappa"; kappa$Filter <- "slope20"
Comis$metric <- "Comission"; Comis$Filter <- "slope20"
Omiss$metric <- "Omission"; Omiss$Filter <- "slope20"
slope20 <- rbind (kappa, Omiss, Comis)
Mean <- ddply (slope20, ~metric, summarise, mean= mean (mean))
Mean$LSID = "Mean"; Mean$Filter = "slope20"
slope20 <- rbind (slope20, Mean)
rm (kappa, Omiss, Comis, Mean)

## Slope 10
kappa <- ddply (subset (data, version == "slope10"), ~LSID, summarise, mean= mean(Kappa))
Comis <- ddply (subset (data, version == "slope10"), ~LSID, summarise, mean= mean(Comission.Error))
Omiss <- ddply (subset (data, version == "slope10"), ~LSID, summarise, mean= mean(Omission.Error))
kappa$metric <- "Kappa"; kappa$Filter <- "slope10"
Comis$metric <- "Comission"; Comis$Filter <- "slope10"
Omiss$metric <- "Omission"; Omiss$Filter <- "slope10"
slope10 <- rbind (kappa, Omiss, Comis)
Mean <- ddply (slope10, ~metric, summarise, mean= mean (mean))
Mean$LSID = "Mean"; Mean$Filter = "slope10"
slope10 <- rbind (slope10, Mean)
rm (kappa, Omiss, Comis, Mean)

## Build validation summarizes:
data2 <- rbind (raw, mapbiomas, slope10, slope20, slope30, slope40)

## Export tables
write.table (data2, "./validation/_tables/validation_step1_step2.txt", sep="\t")


######################## NEXT STEP ######################################
## Read validation tables: 
data <- read.table ("./validation/_tables/validation_step3.txt", header=TRUE)
data <- na.omit (data)

## Calc metrics by class:
##  Raw LAFirA (BQA)
kappa <- ddply (subset (data, version == "raw"), ~LSID, summarise, mean= mean(Kappa))
Comis <- ddply (subset (data, version == "raw"), ~LSID, summarise, mean= mean(Comission.Error))
Omiss <- ddply (subset (data, version == "raw"), ~LSID, summarise, mean= mean(Omission.Error))
kappa$metric <- "Kappa"; kappa$Filter <- "raw"
Comis$metric <- "Comission"; Comis$Filter <- "raw"
Omiss$metric <- "Omission"; Omiss$Filter <- "raw"
raw <- rbind (kappa, Omiss, Comis)
Mean <- ddply (raw, ~metric, summarise, mean= mean (mean))
Mean$LSID = "Mean"; Mean$Filter = "raw"
raw <- rbind (raw, Mean)
rm (kappa, Omiss, Comis, Mean)

## MapBiomas Filter:
kappa <- ddply (subset (data, version == "mapbiomas"), ~LSID, summarise, mean= mean(Kappa))
Comis <- ddply (subset (data, version == "mapbiomas"), ~LSID, summarise, mean= mean(Comission.Error))
Omiss <- ddply (subset (data, version == "mapbiomas"), ~LSID, summarise, mean= mean(Omission.Error))
kappa$metric <- "Kappa"; kappa$Filter <- "mapbiomas"
Comis$metric <- "Comission"; Comis$Filter <- "mapbiomas"
Omiss$metric <- "Omission"; Omiss$Filter <- "mapbiomas"
mapbiomas <- rbind (kappa, Omiss, Comis)
Mean <- ddply (mapbiomas, ~metric, summarise, mean= mean (mean))
Mean$LSID = "Mean"; Mean$Filter = "mapbiomas"
mapbiomas <- rbind (mapbiomas, Mean)
rm (kappa, Omiss, Comis, Mean)

## Slope 20
kappa <- ddply (subset (data, version == "slope20"), ~LSID, summarise, mean= mean(Kappa))
Comis <- ddply (subset (data, version == "slope20"), ~LSID, summarise, mean= mean(Comission.Error))
Omiss <- ddply (subset (data, version == "slope20"), ~LSID, summarise, mean= mean(Omission.Error))
kappa$metric <- "Kappa"; kappa$Filter <- "slope20"
Comis$metric <- "Comission"; Comis$Filter <- "slope20"
Omiss$metric <- "Omission"; Omiss$Filter <- "slope20"
slope20 <- rbind (kappa, Omiss, Comis)
Mean <- ddply (slope20, ~metric, summarise, mean= mean (mean))
Mean$LSID = "Mean"; Mean$Filter = "slope20"
slope20 <- rbind (slope20, Mean)
rm (kappa, Omiss, Comis, Mean)

## Size 5
kappa <- ddply (subset (data, version == "size5"), ~LSID, summarise, mean= mean(Kappa))
Comis <- ddply (subset (data, version == "size5"), ~LSID, summarise, mean= mean(Comission.Error))
Omiss <- ddply (subset (data, version == "size5"), ~LSID, summarise, mean= mean(Omission.Error))
kappa$metric <- "Kappa"; kappa$Filter <- "size5"
Comis$metric <- "Comission"; Comis$Filter <- "size5"
Omiss$metric <- "Omission"; Omiss$Filter <- "size5"
size5<- rbind (kappa, Omiss, Comis)
Mean <- ddply (size5, ~metric, summarise, mean= mean (mean))
Mean$LSID = "Mean"; Mean$Filter = "size5"
size5 <- rbind (size5, Mean)
rm (kappa, Omiss, Comis, Mean)

## Size 11
kappa <- ddply (subset (data, version == "size11"), ~LSID, summarise, mean= mean(Kappa))
Comis <- ddply (subset (data, version == "size11"), ~LSID, summarise, mean= mean(Comission.Error))
Omiss <- ddply (subset (data, version == "size11"), ~LSID, summarise, mean= mean(Omission.Error))
kappa$metric <- "Kappa"; kappa$Filter <- "size11"
Comis$metric <- "Comission"; Comis$Filter <- "size11"
Omiss$metric <- "Omission"; Omiss$Filter <- "size11"
size11<- rbind (kappa, Omiss, Comis)
Mean <- ddply (size11, ~metric, summarise, mean= mean (mean))
Mean$LSID = "Mean"; Mean$Filter = "size11"
size11 <- rbind (size11, Mean)
rm (kappa, Omiss, Comis, Mean)

## Size 16
kappa <- ddply (subset (data, version == "size16"), ~LSID, summarise, mean= mean(Kappa))
Comis <- ddply (subset (data, version == "size16"), ~LSID, summarise, mean= mean(Comission.Error))
Omiss <- ddply (subset (data, version == "size16"), ~LSID, summarise, mean= mean(Omission.Error))
kappa$metric <- "Kappa"; kappa$Filter <- "size16"
Comis$metric <- "Comission"; Comis$Filter <- "size16"
Omiss$metric <- "Omission"; Omiss$Filter <- "size16"
size16<- rbind (kappa, Omiss, Comis)
Mean <- ddply (size16, ~metric, summarise, mean= mean (mean))
Mean$LSID = "Mean"; Mean$Filter = "size16"
size16 <- rbind (size16, Mean)
rm (kappa, Omiss, Comis, Mean)

## Build validation summarizes:
data2 <- rbind (raw, mapbiomas, slope20, size5, size11, size16)

## Export tables
write.table (data2, "./validation/_tables/validation_step3.txt", sep="\t")
