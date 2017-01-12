#Project on tidying up the data for Coursera training

##The purpose

This file describes the input format of the data, underlying transformations coded in R and the output file specifications. The source of original data file is 


## The source

Raw data downloaded from 
https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
on 10 JAN 2017.

##Input data

The input data contains the following data, splitted into test/train folders:

* Fixed width text files for measurements of recording devices: ~10k records on 561 variables(measurements), named as X_*.txt, *=train/test
* Each particular activity record out of these 10k is linked with the subject and activity label, given in separate files (subject_*.txt and y_*.txt)
* There are records for activities of 30 subjects
* There are 6 activity types: laying, standing, sitting, walking, walking down/upstairs, labels descriptions are in a separate file
* description of features

##Transformation

The processing R script, containing in this repo does the following:

* reads the train/test data files on measurements (see readme.md for requirements), merging them into a single file
* retains measurements only of mean/std (66 out of 561)
* joins the data on subjects and activity labels for each measurement files
* using function aggregate() retains means for each subject and activity
* label the variables using features description file
* "." is used as dec separator and ";" as variables separator
* saves to .csv format

##Tidy data

The  dataset containing the following attributes:

* data on avarage measurements for 30 subjects and 6 activities, 180 records in total
* 66 variable for each measurement  + 2 variables for index subject and activity 
* each numeric cell in the tidy datafile accounts for mean of particular measurement for given activity type and subject id\
* sorting order is primary by activity type and secondary subject
