library("data.table")
library("reshape2")

#1: Merges the training and the test sets to create one data set
setwd("./UCI HAR Dataset/")
if(!file.exists("./merged")){dir.create("./merged")}
if(!file.exists("./merged/Inertial Signals")){dir.create("./merged/Inertial Signals")}
files_train <- list.files("./train/", recursive = TRUE)
files_test <- gsub("train", "test", files_train)
files_merged <- gsub("train", "merged", files_train)
for(i in 1:length(files_train)) {
        train <- read.table(paste("./train/", files_train[i], sep =""))
        test <- read.table(paste("./test/", files_test[i], sep =""))
        merged <- rbind(train, test)
        write.table(merged, file=paste("./merged/", files_merged[i], sep =""), quote = F, row.names = F, col.names = F)
}

#2: Extracts only the measurements on the mean and standard deviation for each measurement
activity_labels <- read.table("./activity_labels.txt")[,2]
features <- read.table("./features.txt")[,2]
extract_features <- grepl("mean|std", features)
setwd("./merged/")
X_merged <- read.table("./X_merged.txt")
names(X_merged) = features
X_extracted <- X_merged[,extract_features]

#Uses descriptive activity names to name the activities in the data set
#Appropriately labels the data set with descriptive variable names
y_merged <- read.table("./y_merged.txt")
y_merged[,2] = activity_labels[y_merged[,1]]
names(y_merged) = c("Activity_ID", "Activity_Label")
subject_merged <- read.table("./subject_merged.txt")
names(subject_merged) = "subject"

#From the data set in step 4, creates a second, independent tidy data set
#with the average of each variable for each activity and each subject
data <- cbind(as.data.table(subject_merged), y_merged, X_extracted)
id   = c("subject", "Activity_ID", "Activity_Label")
labels = setdiff(colnames(data), id)
melt_data      = melt(data, id = id, measure.vars = labels)
tidy_data   = dcast(melt_data, subject + Activity_Label ~ variable, mean)
setwd("./..")
write.table(tidy_data, file = "./tidy_data.txt")
