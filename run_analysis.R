library(plyr) 

#Download the file from Internet
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile = "getdata.zip")
# UnZip the package
unzip(zipfile = "getdata.zip")

# Reading of all Test & Train data from respective files.
path_files <- file.path(".","UCI HAR Dataset")
dataActivityTrain <- read.table(file.path(path_files,"train", "y_train.txt"),header = FALSE)
dataActivityTest <- read.table(file.path(path_files,"test", "y_test.txt"), header = FALSE)
dataSubjectTest <- read.table(file.path(path_files, "test", "subject_test.txt"), header = FALSE)
dataSubjectTrain <- read.table(file.path(path_files, "train", "subject_train.txt"), header = FALSE)
dataFeaturesTest <- read.table(file.path(path_files, "test", "X_test.txt"), header = FALSE)
dataFeaturesTrain <- read.table(file.path(path_files, "train", "X_train.txt"), header = FALSE)

# Merge of training & test data for creating a single dataset.
dataSubject <- rbind(dataSubjectTrain, dataSubjectTest)
dataActivity <- rbind(dataActivityTrain, dataActivityTest)
dataFeatures <- rbind(dataFeaturesTrain, dataFeaturesTest)
dataFeaturesNames <- read.table(file.path(path_files, "features.txt"), header = FALSE)
names(dataSubject) <- c("subject")
names(dataActivity) <- c("activity")
names(dataFeatures) <- dataFeaturesNames$V2
dataMerge <- cbind(dataActivity, dataSubject)
allData <- cbind(dataFeatures, dataMerge)

# Extract only the mean & Std. deviation for each measurement
setdataFeaturesNames <- dataFeaturesNames$V2[grep("mean\\(\\)|std\\(\\)", dataFeaturesNames$V2)]
selectNames <- c(as.character(setdataFeaturesNames),"subject", "activity")
Data <- subset(allData, select = selectNames)


# Description of activity type mapping
activityNames <- read.table(file.path(path_files,"activity_labels.txt"), header = FALSE)
Data$activity <- as.character(Data$activity)
Data$activity[Data$activity == 1] <- "Walking"
Data$activity[Data$activity == 2] <- "Walking Upstairs"
Data$activity[Data$activity == 3] <- "Walking Downstairs"
Data$activity[Data$activity == 4] <- "Sitting"
Data$activity[Data$activity == 5] <- "Standing"
Data$activity[Data$activity == 6] <- "Laying"
Data$activity <- as.factor(Data$activity)

# Appropriate Labels for descriptive Variable names.
names(Data) <- gsub("^t", "time", names(Data))
names(Data) <- gsub("^f", "frequency", names(Data))
names(Data) <- gsub("Acc", "Accelerometer", names(Data))
names(Data) <- gsub("Gyro", "Gyroscope", names(Data))
names(Data) <- gsub("Mag", "Magnitude", names(Data))
names(Data) <- gsub("BodyBody", "Body", names(Data))

# Create a final indepenent tidy DataSet
tidyData <- aggregate(. ~ subject + activity, Data, mean)
tidyData <- tidyData[order(tidyData$subject, tidyData$activity),]
write.table(tidyData, file = "tidyData.txt", row.names = FALSE)
