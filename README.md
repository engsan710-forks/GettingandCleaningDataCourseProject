# Getting and Cleaning Data

## Content:
This project contains the required artifacts for the _Peer-graded Assignment: Getting and Cleaning Data Course Project_

* README.md - information about this project
* CodeBook.md - information about the columns in the tidy_data.csv data set
* run_analysis.R - script to generate the tidy_data.csv
* tidy_data.csv - data set outcome of the above script


This project is the outcome of reading the following links:
* [Class project](https://www.coursera.org/learn/data-cleaning/peer/FIZtT/getting-and-cleaning-data-course-project)
* [Getting and Cleaning the Assignment](https://thoughtfulbloke.wordpress.com/2015/09/09/getting-and-cleaning-the-assignment/)
* [Tidy Data](http://vita.had.co.nz/papers/tidy-data.pdf)

## The Data:

One of the most exciting areas in all of data science right now is wearable computing - see for example this article . Companies like Fitbit, Nike, and Jawbone Up are racing to develop the most advanced algorithms to attract new users. The data linked to from the course website represent data collected from the accelerometers from the Samsung Galaxy S smartphone. A full description is available at the site where the data was obtained:

http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

Here are the data for the project:

https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

## The Assignment:

Create one R script called run_analysis.R that does the following:

1. Merges the training and the test sets to create one data set.
2. Extracts only the measurements on the mean and standard deviation for each measurement.
3. Uses descriptive activity names to name the activities in the data set
4. Appropriately labels the data set with descriptive variable names.
5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

The script will download the zip file and unpack it in a directory named: `uci_har_dataset` under the current directory, then read into R the relevant data. Based on [Getting and Cleaning the Assignment](https://thoughtfulbloke.wordpress.com/2015/09/09/getting-and-cleaning-the-assignment/) the only files needed were `subject_*.txt, y_*.txt and X_*.txt` under test and train. The following files were read:
* features.txt - names of the columns
* activity_labels.txt - activity numeric value and label mapping
* subject_test.txt - subject id assigned
* y_test.txt - activity record
* X_test.txt - data
* subject_train.txt - subject id assigned
* y_train.txt - activity record
* X_train.txt - data


```
## read the column names
column_names_orig <- read.table("./uci_har_dataset/features.txt", header = FALSE, stringsAsFactors = FALSE )[,2]
## add the subject and the activity to the beginning
column_names <- append( c("subjectid", "activity"), column_names_orig, 3)


## read the activity value-label mapping
activity_mapping <- read.table("./uci_har_dataset/activity_labels.txt", header = FALSE, col.names = c("V1", "V2"))


## The data is in 2 directories, where 70% of the volunteers was selected for
## generating the training data and 30% the test data., append them to have the
## full set
test_data <- cbind(
            cbind(
              read.table("./uci_har_dataset/subject_test.txt", header = FALSE,  s* ep = "" * ),
              rea* d.table("./uci_har_dataset/y_test.txt", header = FALSE,  sep = "" )
            * ),
            * read.table( "./uci_har_dataset/X_test.tx* * * t

            read.table("./uci_har_dataset/y_test.txt", header = FALSE,  sep = "" )
      rainrain        read.table( "./uci_har_dataset/X_test.txt
          rainheader = FALSE,  sep = "" )
)

train_data <- cbind(
            cbind(
              read.table("./uci_har_dataset/subject_train.txt", header = FALSE,  sep = "" ),
              read.table("./uci_har_dataset/y_train.txt", header = FALSE,  sep = "" )
            ),
            read.table( "./uci_har_dataset/X_train.txt", header = FALSE,  sep = "" )
)

```
### Goal 1:
Once the data is loaded, the first part of the assignment requires to merge the test data with the train data:
```
## Merges the training and the test sets to create one data set. (Goal #1)
all_data <- rbind(test_data, train_data)
names(all_data) <- column_names
```
### Goal 2:
Once the data is merged, the second part of the assignment requires to extract measurements of the mean and standard deviation. Including the subject id and the activity:
```
##Extracts only the measurements on the mean and standard
## deviation for each measurement. (Goal #2)
mean_std_columns <- all_data[ grepl("subjectid|activity|std|mean", names(all_data), ignore.case = TRUE)]
```
### Goal 3
The third part of the assignment requires to update the activity values with labels:

```
## Uses descriptive activity names to name the activities in the
## data set (Goal #3)
mean_std_columns$activity <- factor(mean_std_columns$activity,
                            levels = activity_mapping$V1,
                            labels = activity_mapping$V2)
```
### Goal 4
The fifth part of the assignment requires update the column names. Following the principles of tidy data, each variable should only have letters, dots or dashes. The abbreviations have been expanded as well:
```
## Appropriately labels the data set with descriptive variable
## names. (Goal #4)

#prefix 't' to denote time
names(mean_std_columns) <- sub("^t", "time", names(mean_std_columns))
#prefix 'f' indicates frequency domain
names(mean_std_columns) <- sub("^f", "frequency", names(mean_std_columns))
#remove "(" ")"
names(mean_std_columns) <- sub("\\(", "", names(mean_std_columns))
names(mean_std_columns) <- sub("\\)", "", names(mean_std_columns))
#lower case all names
names(mean_std_columns) <- tolower(names(mean_std_columns))
#Acc is short for acceleration
names(mean_std_columns) <- sub("acc", "acceleration", names(mean_std_columns))
#mag is short for magnitude
names(mean_std_columns) <- sub("mag", "magnitude", names(mean_std_columns))
```
### Goal 5
The last part of the assignment requires to create a summary table of averages:
```
## From the data set in step 4, creates a second, independent
## tidy data set with the average of each variable for each activity
## and each subject.
library(dplyr)
average_activity_subject <- summarise_each(
  group_by(mean_std_columns, activity, subjectid),
  funs(mean))
write.table(average_activity_subject, "tidy_data.txt", row.name=FALSE)
```
To read the tidy_data.txt file use the following code:
```
data <- read.table(file_path, header = TRUE)
View(data)
```
