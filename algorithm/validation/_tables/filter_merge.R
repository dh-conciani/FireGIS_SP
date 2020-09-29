## LAFirA v.1
## Landsat Antrhopic Fire Algorithm 
## Dhemerson Conciani (dhemerson.conciani@unesp.br)

## Build general tables to test filter size improvement:

## Read libraries:
library (ggplot2)
library (lubridate)
library (stringr)
library (tools)
library (dplyr)

## Set local file as work directory:
setwd("./")

## Labels to remove
remove_dates = c ("2017-06-24", 
                  "2015-05-09",
                  "1985-04-20",
                  "2006-07-26",
                  "2015-01-17")

## Read tables
raw <- read.table ("./raw.txt", header= TRUE)
mapbiomas  <- read.table ("./mapbiomas.txt", header= TRUE)
slope10  <- read.table ("./slope10.txt", header= TRUE)
slope20  <- read.table ("./slope20.txt", header= TRUE)
slope30  <- read.table ("./slope30.txt", header= TRUE)
slope40 <- read.table ("./slope40.txt", header= TRUE)

## Merge tables:
data <- rbind (raw, mapbiomas, slope10, slope20, slope30, slope40)

## Remove rows with error
data <- subset (data, !(Date %in% remove_dates))

## Export:
write.table (data, "./validation_step1_step2.txt", sep="\t")

## Phase 3
## Read tables
raw <- read.table ("./raw.txt", header= TRUE)
mapbiomas  <- read.table ("./mapbiomas.txt", header= TRUE)
slope20  <- read.table ("./slope30.txt", header= TRUE)
size5  <- read.table ("./size5.txt", header= TRUE)
size11 <- read.table ("./size11.txt", header= TRUE)
size16 <- read.table ("./size16.txt", header= TRUE)

## Merge tables:
data <- rbind (raw, mapbiomas, slope20, size5, size11, size16)

## Remove rows with error
data <- subset (data, !(Date %in% remove_dates))

## Export:
write.table (data, "./validation_step3_v2.txt", sep="\t")
