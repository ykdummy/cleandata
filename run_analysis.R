# downloading the data files - removed
# download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",
#               destfile = "_tmp_data.zip")
# unzip("_tmp_data.zip")

# Assumptions
## we presume, that project structure is as follows:
## ./run_analysis.R
## ./UCI HAR Dataset/features.txt
## ./UCI HAR Dataset/activity_labels.txt
## ./UCI HAR Dataset/train/X_train.txt
## ./UCI HAR Dataset/train/y_train.txt
## ./UCI HAR Dataset/train/subject_train.txt
## ./UCI HAR Dataset/train/X_test.txt
## ./UCI HAR Dataset/train/y_test.txt
## ./UCI HAR Dataset/train/subject_test.txt

##read the features list
 features<-read.csv(file = "UCI HAR Dataset/features.txt",sep=" ",header = F,stringsAsFactors = F)[,2]

## ------------------------------------------------------------------------------------------
# transformation REQUIRED BY ITEM#2:<step1>
## ---------------Extracts only the measurements on the mean and standard deviation for each measurement.
features_used_ids<-grep("(-mean\\(\\)|-std\\(\\))",features,value = F)
features_used_names<-grep("(-mean\\(\\)|-std\\(\\))",features,value = T)

##------------------------------------------------------------------------------------------
# Tackle the <data folder>(train/test) data
## 
## Function to read raw data for measurements, subjects and labels 
## as a single data from from a specified folder
##
read_actdata_folder_fast<-function(folder="test"){
  measurement_filename<-paste("UCI HAR Dataset/",folder,"/X_",folder,".txt",sep='')
  #read the number of variables in order not to hardcode this number, assuming the length is 16 symbols per record, including space
  N_measurevars<-nchar(readLines(measurement_filename,n=1))/16
  #read the file using readr package - much faster than standard read.fwf
  require(readr)
  dataRAW_measurements<-read_fwf(
    measurement_filename,
    fwf_widths(
      #vector of width - 561 column by 16 symbols each
      rep(16,N_measurevars)#, 
      # set the variable names, as it is asked in ITEM 4 of the specifications for the task
      ),
    progress = interactive()
  )  
  
  ##------------------------------------------------------------------------------------------
  #transformation REQUIRED BY ITEM#2:<step2>
  dataRAW_measurements<-dataRAW_measurements[,features_used_ids]
  
  ##------------------------------------------------------------------------------------------
  #transformation REQUIRED BY ITEM#4:
  ##---------------Label the data set with descriptive variable names.
  names(dataRAW_measurements)<-features_used_names
  ##read raw data for subjects
  subj_filename<-paste("UCI HAR Dataset/",folder,"/subject_",folder,".txt",sep='')
  dataRAW_subj<-read.csv(subj_filename,header = F,col.names = "subject")
  ##read raw data for labels
  labels_filename<-paste("UCI HAR Dataset/",folder,"/y_",folder,".txt",sep='')
  dataRAW_labels<-read.csv(labels_filename,header = F,col.names = "activity_id")
  ##combine the data from three files: subject :: activity id :: measurements
  
  ##return the binded dataset
  cbind(subject = dataRAW_subj,
        label   = dataRAW_labels,
                  dataRAW_measurements)
  
}
#------------------------------------------------------------------------------------------

##actually read test data
test_data<-read_actdata_folder_fast("test")
##actually read train data
train_data<-read_actdata_folder_fast("train")

##------------------------------------------------------------------------------------------
#transformation REQUIRED BY ITEM#1:
##---------------Merge the training and the test sets to create one data set.
all_data<-rbind(test_data,train_data)

##------------------------------------------------------------------------------------------
#transformation REQUIRED BY ITEM#3:
##---------------Uses descriptive activity names to name the activities in the data set
##read activities labels
activities<-read.csv("UCI HAR Dataset/activity_labels.txt",
                     sep=" ",header = F,stringsAsFactors = F,col.names = c("id","activity"))
##add activity, with description from activities file
all_data$activity<-as.factor(activities[all_data$activity_id,2])
all_data$subject<-as.factor(all_data$subject)
#remove activity id
TidyData1<-all_data[,!(names(all_data) %in% "activity_id")]


#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#the resulting second dataset <TidyData2>
attach(TidyData1)
TidyData2 <-aggregate(TidyData1[,features_used_names], by=list(subject,activity), 
                    FUN=mean, na.rm=TRUE)
names(TidyData2)[1:2]<-c("subject","activity")
detach(TidyData1)

#Output the result
write.table(TidyData2,"TidyData2.txt",row.name = FALSE)
