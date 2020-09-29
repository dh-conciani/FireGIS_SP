## train models to classify burn scars into SP 
## Dhemerson Conciani

## read packages
library (AppliedPredictiveModeling)
library (caret)
library (pROC)
library (doParallel)
library (dplyr)
library (vegan)
library (randomForest)
library (e1071)

## configure parallel processing
cl <- makePSOCKcluster(8)
registerDoParallel(cl)

## P R E ~ P R O C E S S I N G
## import dataset
load ("./train_dfs/balancedClasses_df.RData")

## isolate non-numeric variable into independent objects
dataScene <- balanced$Scene
dataDate <- balanced$Date
dataSensor <- balanced$Sensor
dataID <- balanced$ID
dataLocal <- balanced$Local
dataClass <- balanced$Class

# now remove the columns
balanced <- balanced [,-1:-5] ## Remove descriptors
balanced <- balanced [,-7]     ## Remove Local
balanced <- balanced [,-16]    ## Remove SMI
balanced <- balanced [,-19]    ## Remove NULL


## S P L I T ~ D A T A
## TRAINING DATASET (with 70%)
trainingRows <- createDataPartition(dataClass, p = .70, list= FALSE)
# Subset objects for training using integer sub-setting.
## training dataset
trainPredictors <- balanced[trainingRows, ]
trainClasses <- dataClass[trainingRows]

## tTEST DATASET (with 30%)
testPredictors <- balanced[-trainingRows, ]
testClasses <- dataClass[-trainingRows]

## plot histograms
histogram(trainClasses, main ="train dataset")
histogram(testClasses, main = "test dataset")

## MODELs TRAINING
## control parameters for train
control <- trainControl(method="repeatedcv", number=5, repeats=3, classProbs=TRUE) 
## train randomForest model
rfModel <- randomForest(trainPredictors, trainClasses,
                        ntree= 750,
                        mtry= 5,
                        trControl=control,
                        preProc = c ("center", "scale"))

##load ("F:/dhemerson/rfClassifyBalanced750trees.RData")

## Evaluate Model
testClasses <- as.factor(testClasses)
## use to predict test dataset
options(scipen=999)
rfTestPred <- predict (rfModel, testPredictors, type= "response")
#rfTestProbs <- predict (rfModel, testPredictors, type= "prob")

#rfDF <- as.data.frame (rfTestPred)
#rfTestProbs <- as.data.frame (rfTestProbs)
#rfDF$probrfBA <- rfTestProbs$BA


## explore histogram among real-predict
histogram(rfTestPred, main="RF predictions")
histogram(testClasses, main="Real class (test dataset)")


#confusion matrix
confusionMatrix(data = rfTestPred,
                reference = testClasses,
                positive="BA")

