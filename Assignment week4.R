setwd("~/Data Science/Assignments/3rdw4/UCI HAR dataset")
library(dplyr)
library(data.table)
library(tidyr)

filesPath <- "C:/Users/Yamil/Documents/Data Science/Assignments/3rdw4/UCI HAR Dataset"
# Reading files
SubjTrain <- tbl_df(read.table(file.path(filesPath, "train", "subject_train.txt")))
SubjTest  <- tbl_df(read.table(file.path(filesPath, "test" , "subject_test.txt" )))
ActTrain <- tbl_df(read.table(file.path(filesPath, "train", "Y_train.txt")))
ActTest  <- tbl_df(read.table(file.path(filesPath, "test" , "Y_test.txt" )))
datTrain <- tbl_df(read.table(file.path(filesPath, "train", "X_train.txt" )))
datTest  <- tbl_df(read.table(file.path(filesPath, "test" , "X_test.txt" )))
# merging and renaming
allSubj <- rbind(SubjTrain, SubjTest)
setnames(allSubj, "V1", "subject")
allAct <- rbind(ActTrain, ActTest)
setnames(allAct, "V1", "activityNum")
#combining train and test files
CombTable <- rbind(datTrain, datTest)
# naming variables
datFeat <- tbl_df(read.table(file.path(filesPath, "features.txt")))
setnames(datFeat, names(datFeat), c("featureNum", "featureName"))
colnames(CombTable) <- datFeat$featureName
#column names 
actLabels<- tbl_df(read.table(file.path(filesPath, "activity_labels.txt")))
setnames(actLabels, names(actLabels), c("activityNum","activityName"))
# Merging columns
allSubjAct<- cbind(allSubj, allAct)
CombTable <- cbind(allSubjAct, CombTable)
# Reading "features.txt" and extracting only the mean and standard deviation
dataFeatMeanStd <- grep("mean\\(\\)|std\\(\\)",datFeat$featureName,value=TRUE) 
# Taking only measurements for the mean and standard deviation and add "subject","activityNum"
dataFeatMeanStd <- union(c("subject","activityNum"), dataFeatMeanStd)
CombTable<- subset(CombTable,select=dataFeatMeanStd) 
##enter descriptive names
CombTable <- merge(actLabels, CombTable , by="activityNum", all.x=TRUE)
CombTable$activityName <- as.character(CombTable$activityName)

## create CombTable with variable means sorted by subject and Activity
CombTable$activityName <- as.character(CombTable$activityName)
dataAggr<- aggregate(. ~ subject - activityName, data = CombTable, mean) 
CombTable<- tbl_df(arrange(dataAggr,subject,activityName))

#previous names
head(str(CombTable),2)
names(CombTable)<-gsub("std()", "SD", names(CombTable))
names(CombTable)<-gsub("mean()", "MEAN", names(CombTable))
names(CombTable)<-gsub("^t", "time", names(CombTable))
names(CombTable)<-gsub("^f", "frequency", names(CombTable))
names(CombTable)<-gsub("Acc", "Accelerometer", names(CombTable))
names(CombTable)<-gsub("Gyro", "Gyroscope", names(CombTable))
names(CombTable)<-gsub("Mag", "Magnitude", names(CombTable))
names(CombTable)<-gsub("BodyBody", "Body", names(CombTable))
# Names after
head(str(CombTable),6)
##write to text file
write.table(CombTable, "TidyData.txt", row.name=FALSE)

