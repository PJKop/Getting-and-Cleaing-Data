#Getting and Cleaning Data Project

#Set directory to folder with project files
setwd("D:/Documents/R/Getting and Cleaning Data/Project")

#Url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

#download.file(Url, destfile = "./Dataset.zip")

#unzip(zipfile="Dataset.zip")

library(plyr)
library(dplyr)

pathdata<- file.path("UCI HAR Dataset")

#Read in all the files needed

dataTrain <- read.table(file.path(pathdata, "train", "X_train.txt"),header = FALSE)
#Data from "Training" Group
dataTest <- read.table(file.path(pathdata, "test" , "X_test.txt" ),header = FALSE)
#Data from "Test" Group
ActTrain <- read.table(file.path(pathdata, "train", "Y_train.txt"),header = FALSE)
#List of activities as numerics for Training Group
ActTest <- read.table(file.path(pathdata, "test" , "Y_test.txt" ),header = FALSE)
#List of activities as numerics for Test Group
SubjTrain <- read.table(file.path(pathdata, "train", "subject_train.txt"),header = FALSE)
#List of subjects as numerics (no names are given in data). 30 subjects (numbered 1-30) for the train and test group with randomly
#chosen numbers seperated between the two to create the groups
SubjTest  <- read.table(file.path(pathdata, "test" , "subject_test.txt"),header = FALSE)
#List of subjects as numerics for the Test group
DataLabels <- read.table(file.path(pathdata, "features.txt"),header = FALSE)
#List of Data Labels
ActivityLabels <- read.table(file.path(pathdata, "activity_labels.txt"),header = FALSE)
#List of Activity Labels

DataCombined <- rbind(dataTrain, dataTest)
# Add the data from Training group and Tes to one dataframe

names(DataCombined) <- DataLabels$V2
#Add column names to the Combined Data for the Train and Test Data

Subjects <- rbind(SubjTrain,SubjTest)
#Add the two tables with the Subjects to line up with the DataCombined df. Now have one table with all of the Subjects

names(Subjects) <- "Subject"
#Adds name to column Subject

DataCombined <- cbind(DataCombined, Subjects)
#Add in the Subjects to the DataCombined df

Activities <- rbind(ActTrain,ActTest)
#Add activities together to one table (Still in numeric form)

Activities <- factor(Activities$V1)
#Now factored activities

levels(Activities) <- ActivityLabels$V2
#Change activity numeric to Activity Labels

names(Activities) <- "Activity"
#Adds name to column Activity

DataCombined <- cbind(DataCombined, Activities)
#All data is completed with labels and column names. Now need to pull out only the Data mean and std

SelectedColumns <- grepl("mean\\(|std|Subject|Activities", names(DataCombined))
#Creates a logical array of all the columns with either mean(excluding meanfreq, but requeing a ( after the word mean),std, Subject or
#Or activities in the name

DataClean <- subset(DataCombined,select = SelectedColumns)
#Creates a dataframe with only the desired columns

names(DataClean)<-gsub("\\(\\)", "", names(DataClean))
names(DataClean)<-gsub("\\-", ".", names(DataClean))
names(DataClean)<-gsub("^t", "Time.", names(DataClean))
names(DataClean)<-gsub("Acc", ".Accelerometer", names(DataClean))
names(DataClean)<-gsub("Gyro", ".Gyroscope", names(DataClean))
names(DataClean)<-gsub("Mag", ".Magnitude", names(DataClean))
names(DataClean)<-gsub("^f", "Frequency.", names(DataClean))
names(DataClean)<-gsub("BodyBody", "Body", names(DataClean))
names(DataClean)<-gsub("mean", "Mean", names(DataClean))
names(DataClean)<-gsub("std", "Std", names(DataClean))
#Changes names in DataClean to know all be more logical and easier to write, All words are capitilized and seperated by a "."
#paranthenses ahve also been removed

DataFinal <- aggregate(. ~Subject + Activities, DataClean, FUN = mean)
#Creates Data Frame with only the means per each Subject and Activity

write.table(DataFinal, file = "Final Data Set.txt", row.names = FALSE)