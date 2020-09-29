## Check homogenity between classes
## LAFirA (v1SP) dataset 

## Read packages
library (caret)
library (DMwR)

## Read raw dataset omiting NAs
load("./train_dfs/df_train_full.RData"); train_df <- na.omit (train_df)

## Check classes balance 
histogram(train_df$Class) # Plot classes histogram
## Calc classes distribution (%)
classSums <- as.data.frame(table(train_df$Class)) 
classSums$percent <- classSums$Freq / sum(classSums$Freq) * 100

## Calc ideal" scenario (equally balanced)
classSums$idealFreq <- sum(classSums$Freq) / nlevels(classSums$Var1)
classSums$idealPercent <- classSums$idealFreq / sum(classSums$Freq) * 100

## Calc distance (ideal - observed)
classSums$distance <- classSums$idealPercent - classSums$percent
## Select reference to balance (min distance)

## Calc distance betweeen reference (minDistance) to other predictors
classSums$distToRef <- min(abs(classSums$distance)) - classSums$distance

## decide action to balance
classSums$action = 
    ifelse (classSums$distToRef > 0,
            yes= "downSample",
            no= "upSample")

## Extract levels to downsample
downLevels <- droplevels(subset(classSums, action=="downSample", drop=FALSE)$Var1)

## Mount downSample dataframe
down_df <- droplevels(subset (train_df, Class =="esoil" | Class =="gcover" | Class=="BA"))
histogram (down_df$Class)

## compute downsamples
downSampledTrain <- downSample(x = down_df,
                           y = down_df$Class,
                           yname = "NULL")
histogram(downSampledTrain$Class)
table(downSampledTrain$Class)

## Extract levels to upSample
upLevels <- droplevels(subset(classSums, action=="upSample", drop=FALSE)$Var1); upLevels

## Mount upSample dataframe
up_df <- droplevels(subset (train_df, Class =="const" | Class =="harv" | Class=="road" | Class== "shadow" | Class=="water" | Class=="BA"))
histogram (up_df$Class)

## compute upSamples
upSampledTrain <- upSample(x = up_df,
                               y = up_df$Class,
                               yname = "NULL")
histogram(upSampledTrain$Class)
table(upSampledTrain$Class)

## Remove BA from upSampled 
upSampledTrain <- droplevels(subset (upSampledTrain, Class!="BA", drop=TRUE))
histogram(upSampledTrain$Class)

## Merge balanced dataset
balanced <- rbind (downSampledTrain, upSampledTrain)
histogram (balanced$Class)

## remove temps
rm (classSums, down_df, downSampledTrain, train_df, up_df, upSampledTrain, downLevels, upLevels, yname)

