library(data.table)
library(plyr)
library(dplyr)

# Download zip file & unzip:
setwd("C:/Users/izlat/Documents/Getting and Cleaning Data JHU/Course Project")
zipUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(zipUrl, destfile = "project_data.zip")
unzip(zipfile = "project_data.zip")



# Measurements Data
#---------------------------------------------------------------------------------------------------------------------
# Read Measurements Data
file1 <- c("C:/Users/izlat/Documents/Getting and Cleaning Data JHU/Course Project/UCI HAR Dataset/test/X_test.txt")
file2 <- c("C:/Users/izlat/Documents/Getting and Cleaning Data JHU/Course Project/UCI HAR Dataset/train/X_train.txt")

testData <- fread(file1) # str(testData)
trainData <- fread(file2) # str(trainData)

# Merge Measurements Data
mergeData <- rbind(testData,trainData)  # str(mergeData) 

# Add + clean variable names
varNames <- fread(c("C:/Users/izlat/Documents/Getting and Cleaning Data JHU/Course Project/UCI HAR Dataset/features.txt")) # str(varNames)
fnames <- gsub("[()]", "", varNames$V2) 
fnames <- gsub("^t", "Time_", fnames)
fnames <- gsub("^f", "Frequency_", fnames)
fnames <- gsub("Acc", "Accelerometer", fnames)
fnames <- gsub("Mag", "Magnitude", fnames)
fnames <- gsub("-", "_", fnames)
fnames <- gsub(",", "_", fnames)
fnames <- gsub("std", "Standard_Deviation", fnames)
fnames <- gsub("mean", "Mean", fnames)

setnames(mergeData, fnames)

# Extract only mean and std columns
needed_cols <- grep("Mean|Standard_Deviation", colnames(mergeData), value = TRUE)

# mergeData[, needed_cols, with = FALSE] # from cran intro data.table: Select columns named in a variable using with = FALSE
neededData <- mergeData[, needed_cols, with = FALSE]



# Add Activity
#---------------------------------------------------------------------------------------------------------------------
# Read Activity Data
file3 <- c("C:/Users/izlat/Documents/Getting and Cleaning Data JHU/Course Project/UCI HAR Dataset/test/y_test.txt")
file4 <- c("C:/Users/izlat/Documents/Getting and Cleaning Data JHU/Course Project/UCI HAR Dataset/train/y_train.txt")

testDataActivity <- fread(file3) # str(testDataActivity)
trainDataActivity <- fread(file4) # str(trainDataActivity)

# Merge Activity Data
mergeDataActivity <- rbind(testDataActivity,trainDataActivity)  # str(mergeDataActivity) 
setnames(mergeDataActivity, "Activity")


# Add Subject
#---------------------------------------------------------------------------------------------------------------------
# Read Subject Data
file5 <- c("C:/Users/izlat/Documents/Getting and Cleaning Data JHU/Course Project/UCI HAR Dataset/test/subject_test.txt")
file6 <- c("C:/Users/izlat/Documents/Getting and Cleaning Data JHU/Course Project/UCI HAR Dataset/train/subject_train.txt")

testDataSubject <- fread(file5) # str(testDataSubject)
trainDataSubject <- fread(file6) # str(trainDataSubject)

# Merge Subject Data
mergeDataSubject <- rbind(testDataSubject,trainDataSubject)  # str(mergeDataSubject) 
setnames(mergeDataSubject, "Subject")


# COmbine Measures, Activity names, and Subjects
#---------------------------------------------------------------------------------------------------------------------
mergeDataAll <- cbind(neededData, mergeDataActivity, mergeDataSubject)  # str(mergeDataAll)



# Change to Friendly Activity Names
#---------------------------------------------------------------------------------------------------------------------
actNames <- fread(c("C:/Users/izlat/Documents/Getting and Cleaning Data JHU/Course Project/UCI HAR Dataset/activity_labels.txt")) 

friendlyAct <- actNames$V2 
# [1]  "WALKING"            "WALKING_UPSTAIRS"   "WALKING_DOWNSTAIRS" "SITTING"            "STANDING"           "LAYING" 

mergeDataAll$Activity <- mapvalues(mergeDataActivity$Activity, c(1:6), c(friendlyAct ))         # mapvalues from plyr



# Independent tidy data set with the average of each variable for each activity and each subject.
#---------------------------------------------------------------------------------------------------------------------
new_set <- mergeDataAll[, lapply(.SD, mean), by = .(Activity, Subject)]

## str(new_set) # makes sense: 30 subjects X 6 activities = 180

# Write to a file
write.table(new_set, file = "./tidy_data.txt", row.name=FALSE)
