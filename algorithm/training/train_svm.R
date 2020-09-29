## train models to classify burn scars into SP 
## Dhemerson Conciani

## read packages
library (AppliedPredictiveModeling)
library (caret)
library (e1071)
library (doParallel)
library (dplyr)

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
balanced <- balanced [,-1:-2] ## Remove descriptors
balanced <- balanced [,-2:-3] ## Remove descriptors
balanced <- balanced [,-8]    ## Remove Local
balanced <- balanced [,-21]    ## Remove NULL
balanced <- balanced [,-17]    ## Remove SMI

## scale features
balanced[-1] = scale(balanced[-1]) 

## S P L I T ~ D A T A

## TRAINING DATASET (with 70%)
trainingRows <- createDataPartition(dataClass, p = .70, list= FALSE)
# Subset objects for training using integer sub-setting.
## training dataset
trainPredictors <- balanced[trainingRows, ]
trainClasses <- balanced[trainingRows]

## test/validation dataset
testPredictors <- balanced[-trainingRows, ]
testClasses <- balanced[-trainingRows]

## MODELs TRAINING
## Support Vector Machine
## control parameters for train
#control <- trainControl(method="repeatedcv", number=10, repeats=5, classProbs=TRUE) 
## train SVM model
#svmModel <- train(Class ~ ., data= balanced,
 #                method = "svmRadial",
  #               preProc = c ("center", "scale"),
   #              tuneLength = 4,
    #             trControl=control)

## train
svmModel <- svm(formula = Class ~ ., 
                             data = trainPredictors, 
                             type = 'C-classification', 
                             kernel = 'radial',
                             probability= TRUE,
                             cross = 2) 


## inspect SVM model
svmModel
varImp(svmModel)
summary (svmModel)


svmTestPred <- predict (svmModel, testPredictors, type= "raw")


