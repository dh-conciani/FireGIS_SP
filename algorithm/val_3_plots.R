## LAFirA v.1
## Landsat Antrhopic Fire Algorithm 
## Dhemerson Conciani (dhemerson.conciani@unesp.br)

## Validation metrics plots:

## Read libraries:
library (ggplot2)
library (lubridate)
library (stringr)
library (tools)

## Read tables 
setwd("./")

## Summarized table
## Phase 1,2 and 3 = BQA, MapBiomas and Slope
data <- read.table ("./validation/_tables/validation_step1_step2.txt", header= T)

## Replace WRS2 by citie names
levels (data$LSID) <- c (
    "Franco da Rocha",     # 219_76
    "Itirapina",           # 220_75
    "Tanabi",              # 221_74
    "Rancharia",           # 222_76
    "Average Performance"  # Mean
)

## Replace version labels by legible names  
data$Filter <- gsub ("raw", "BQA", data$Filter)   # 1 pixel  =  0.01  ha
data$Filter <- gsub ("mapbiomas", "MapBiomas", data$Filter)  
data$Filter <- gsub ("slope40", "Slope 40º", data$Filter)   
data$Filter <- gsub ("slope30", "Slope 30º", data$Filter) 
data$Filter <- gsub ("slope30", "Slope 30º", data$Filter) 
data$Filter <- gsub ("slope20", "Slope 20º", data$Filter) 
data$Filter <- gsub ("slope10", "Slope 10º", data$Filter) 

## Re-order factors
data$Filter<- factor (data$Filter, levels = c("BQA", 
                                              "MapBiomas",
                                              "Slope 40º",
                                              "Slope 30º",
                                              "Slope 20º", 
                                              "Slope 10º"))


## Plot by each validation site
x11()
ggplot (data, aes (x= Filter, y= mean, group= metric, colour= metric)) +
    geom_line() + 
    geom_point() + 
    scale_color_manual (values= c ("red", "green4", "black")) +
    facet_grid(cols= vars(LSID)) +
    theme_bw() +
    theme (strip.text.x = element_text(size= 10, face= "bold"),
           axis.text.x = element_text(angle=45, hjust=1)) +
    xlab ("Applied mask") + ylab ("value") +
    scale_y_continuous(breaks= seq(0, 1, by= 0.2), limits= c(0,1))

######################### NEXT STEP #################################
## Phase 4= BQA, MapBiomas slope and size filter
data <- read.table ("./validation/_tables/validation_step3_v2.txt", header= T)

## Replace WRS2 by citie names
levels (data$LSID) <- c (
    "Franco da Rocha",     # 219_76
    "Itirapina",           # 220_75
    "Tanabi",              # 221_74
    "Rancharia",           # 222_76
    "Average Performance"  # Mean
)

## Replace version labels by legible names  
data$Filter <- gsub ("raw", "BQA", data$Filter)   # 1 pixel  =  0.01  ha
data$Filter <- gsub ("mapbiomas", "MapBiomas", data$Filter)  
data$Filter <- gsub ("slope30", "Slope 30º", data$Filter)   
data$Filter <- gsub ("size5", "0.5ha", data$Filter)   
data$Filter <- gsub ("size11", "1ha", data$Filter)   
data$Filter <- gsub ("size16", "1.5ha", data$Filter)   


## Re-order factors
data$Filter<- factor (data$Filter, levels = c("BQA", 
                                              "MapBiomas",
                                              "Slope 30º",
                                              "0.5ha",
                                              "1ha", 
                                              "1.5ha"))

## Plot by each validation site
x11()
ggplot (data, aes (x= Filter, y= mean, group= metric, colour= metric)) +
    geom_line() + 
    geom_point() + 
    scale_color_manual (values= c ("red", "green4", "black")) +
    facet_grid(cols= vars(LSID)) +
    theme_bw() +
    theme (strip.text.x = element_text(size= 10, face= "bold"),
           axis.text.x = element_text(angle=45, hjust=1)) +
    xlab ("Minimum detection size") + ylab ("value") +
    scale_y_continuous(breaks= seq(0, 1, by= 0.2), limits= c(0,1))













raw_lafira <- read.table ("./validation/_tables/SIZE11_lafira.txt", header=TRUE)


## Split Date
raw_lafira$Month <- as.factor(
    sapply (substr(raw_lafira$Date, start= 6, stop= 7), function(x) x))

## Plot
x11()
# Overall Error
ggplot (raw_lafira, aes(x=Month, y=Overall_Error, group= LSID, colour= LSID)) + 
    geom_smooth(aes(group=LSID, colour=LSID), method= "loess", se= F, size=0.8) + 
    scale_color_manual (values= c ("red", "orange", "black", "green4"), 
                        labels= c( "Franco da Rocha", "Itirapina", "Tanabi", "Rancharia"),
                        guide = guide_legend (reverse= TRUE)) +
    scale_x_discrete(labels=c ("J", "F", "M", "A", "M", "J", "J", "A", "S", "O", "N", "D")) +
    geom_point(aes(group= LSID, colour= LSID), alpha=0.3, size=0.5, shape=8) +
    xlab ("Meses do Ano") +
    ylab ("Overall Error") +
    theme_bw()

## Kappa
ggplot (raw_lafira, aes(x=Month, y=Kappa, group= LSID, colour= LSID)) + 
        geom_smooth(aes(group=LSID, colour=LSID), method= "loess", se= F, size=0.8) + 
        scale_color_manual (values= c ("red", "orange", "black", "green4"), 
                            labels= c( "Franco da Rocha", "Itirapina", "Tanabi", "Rancharia"),
                            guide = guide_legend (reverse= TRUE)) +
        scale_x_discrete(labels=c ("J", "F", "M", "A", "M", "J", "J", "A", "S", "O", "N", "D")) +
        geom_point(aes(group= LSID, colour= LSID), alpha=0.3, size=0.5, shape=8) +
        xlab ("Meses do Ano") +
        ylab ("Kappa")  +
    theme_bw()

## Omission Error
ggplot (raw_lafira, aes(x=Month, y=Omission.Error, group= LSID, colour= LSID)) + 
    geom_smooth(aes(group=LSID, colour=LSID), method= "loess", se= F, size=0.8) + 
    scale_color_manual (values= c ("red", "orange", "black", "green4"), 
                        labels= c( "Franco da Rocha", "Itirapina", "Tanabi", "Rancharia"),
                        guide = guide_legend (reverse= TRUE)) +
    scale_x_discrete(labels=c ("J", "F", "M", "A", "M", "J", "J", "A", "S", "O", "N", "D")) +
    geom_point(aes(group= LSID, colour= LSID), alpha=0.3, size=0.5, shape=8) +
    xlab ("Meses do Ano") +
    ylab ("Omission Error")  +
    theme_bw()

## Comission Error
ggplot (raw_lafira, aes(x=Month, y=Comission.Error, group= LSID, colour= LSID)) + 
    geom_smooth(aes(group=LSID, colour=LSID), method= "loess", se= F, size=0.8) + 
    scale_color_manual (values= c ("red", "orange", "black", "green4"), 
                        labels= c( "Franco da Rocha", "Itirapina", "Tanabi", "Rancharia"),
                        guide = guide_legend (reverse= TRUE)) +
    scale_x_discrete(labels=c ("J", "F", "M", "A", "M", "J", "J", "A", "S", "O", "N", "D")) +
    geom_point(aes(group= LSID, colour= LSID), alpha=0.3, size=0.5, shape=8) +
    xlab ("Messes do Ano") +
    ylab ("Comission Error")  +
    theme_bw()

