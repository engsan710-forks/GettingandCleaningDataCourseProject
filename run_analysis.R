##################################################################
## This script:
## 1. Merges the training and the test sets to create one data set.
## 2. Extracts only the measurements on the mean and standard
## deviation for each measurement.
## 3. Uses descriptive activity names to name the activities in the
## data set
## 4. Appropriately labels the data set with descriptive variable
## names.
## 5. From the data set in step 4, creates a second, independent
## tidy data set with the average of each variable for each activity
## and each subject.
##
## Inputs:
## Data from https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
##
## Output:
## tidy_data.txt that can be viewed with:
##       data <- read.table(file_path, header = TRUE)
##       View(data)
##################################################################
create_tidy_data <- function() {
  ## Download the zip file:
  download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", "UCI_HAR_Dataset.zip", "curl")

  ## unzip file
  unzip("UCI_HAR_Dataset.zip", exdir = "uci_har_dataset", junkpaths = TRUE)

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
                read.table("./uci_har_dataset/subject_test.txt", header = FALSE,  sep = "" ),
                read.table("./uci_har_dataset/y_test.txt", header = FALSE,  sep = "" )
              ),
              read.table( "./uci_har_dataset/X_test.txt", header = FALSE,  sep = "" )
  )

  train_data <- cbind(
              cbind(
                read.table("./uci_har_dataset/subject_train.txt", header = FALSE,  sep = "" ),
                read.table("./uci_har_dataset/y_train.txt", header = FALSE,  sep = "" )
              ),
              read.table( "./uci_har_dataset/X_train.txt", header = FALSE,  sep = "" )
  )


  ## Merges the training and the test sets to create one data set. (Goal #1)
  all_data <- rbind(test_data, train_data)
  names(all_data) <- column_names

  ##Extracts only the measurements on the mean and standard
  ## deviation for each measurement. (Goal #2)
  mean_std_columns <- all_data[ grepl("subjectid|activity|std|mean", names(all_data), ignore.case = TRUE)]


  ## Uses descriptive activity names to name the activities in the
  ## data set (Goal #3)
  mean_std_columns$activity <- factor(mean_std_columns$activity,
                              levels = activity_mapping$V1,
                              labels = activity_mapping$V2)


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


  ## From the data set in step 4, creates a second, independent
  ## tidy data set with the average of each variable for each activity
  ## and each subject.
  library(dplyr)
  average_activity_subject <- summarise_each(
    group_by(mean_std_columns, activity, subjectid),
    funs(mean))
  write.table(average_activity_subject, "tidy_data.txt", row.name=FALSE)


}


