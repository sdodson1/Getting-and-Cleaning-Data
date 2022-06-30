
library(dplyr)

#setwd to main folder to avoid repetition, saving oldwd to switch back later
old_wd <- getwd()
setwd("./UCI HAR Dataset/")

#read in labels & data
features <- read.table("features.txt", col.names = c("n", "functions"))
activity_labels <- read.table("activity_labels.txt", 
                              col.names = c("ActivityCode", "Activity"))
subject_test <- read.table("test/subject_test.txt", col.names = "Subject")
x_test <- read.table("test/X_test.txt", col.names=features$functions)
y_test <- read.table("test/Y_test.txt", col.names = "ActivityCode")
subject_train <- read.table("train/subject_train.txt", col.names = "Subject")
x_train <- read.table("train/X_train.txt", col.names = features$functions)
y_train <- read.table("train/y_train.txt", col.names = "ActivityCode")

#switch back to main wd
setwd(old_wd)

#1: merge training and test sets to create 1 dataset
Subject <- rbind(subject_test, subject_train)
x <- rbind(x_test, x_train)
y <- rbind(y_test, y_train)
data <- cbind(Subject, y, x)
##3:: label descriptive activity names
data <- merge(data, activity_labels, by = "ActivityCode")
data$Activity <- as.factor(data$Activity)

#2: extract mean and sd for each measurement
meanstd <- data %>% select(Subject, Activity, matches("mean|std"))

#4:label dataset with descriptive variable names
library(stringr)
strings <- c('Acc' = 'Accelerometer', 'Gyro' = 'Gyroscope', 'Mag' = 'Magnitude', 
             'Freq' = 'Frequency', 'gravity' = 'Gravity', 'mean' = 'Mean', 
             'std' = 'StDev', 'angle' = 'Angle', '^f' = 'Frequency', 
             '^t' = 'Time')

colnames(meanstd) <- str_replace_all(colnames(meanstd), strings)

#5:create second, independent tidy data set with average of each variable for 
#each activity and each subject

groupedData <- meanstd %>%
       group_by(Subject, Activity) %>%
       summarize_all(funs(mean))
