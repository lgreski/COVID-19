#
# read JHU covid-19 data
#
# 2020-04-17 lgreski 
# 2020-11-10 updated for 2 corrections of column names after 5/29/2020

# edit this line to reflect where data is stored on local machine 
directory <- "./csse_covid_19_data/csse_covid_19_daily_reports/"

# read all files in directory
theFiles <- list.files(path=directory,pattern="*.csv",full.names = TRUE)
filenames <- list.files(path=directory,pattern="*.csv")

# read and clean column information, add missing columns for earliest data
# for details, see ./R/analyzeColumnNamesByDay.R in github repository 
library(lubridate)

dataList <- lapply(1:length(theFiles),function(x){
  y <-read.csv(theFiles[x],stringsAsFactors=FALSE)
  # clean column names and add missing columns 
  fileDate <- mdy(substr(filenames[x],1,10))

    # common processing across all files
  colnames(y) <- gsub("\\.","_",colnames(y))
  colnames(y) <- sub("ï__","",colnames(y)) 

  # processing specific to first batch of files
  if(fileDate < mdy("02/01/2020")) {
    y$Province_State <- NA
    y$Lat <- NA
    y$Long_ <- NA
    y$Active <- NA
    y$Admin2 <- NA
    y$FIPS <- NA 
    y$Combined_Key <- NA 
    y$Case_Fatality_Ratio <- NA
    y$Incident_Rate <- NA 
  } else if (fileDate < mdy("03/01/2020")){
    # cleaning specific to first wave of files
    y$Lat <- NA
    y$Long_ <- NA
    y$Active <- NA
    y$Admin2 <- NA
    y$FIPS <- NA 
    y$Combined_Key <- NA     
    y$Case_Fatality_Ratio <- NA
    y$Incident_Rate <- NA 
  } else if(fileDate < mdy("03/22/2020")) {
       colnames(y) <- sub("Latitude","Lat",colnames(y))
       colnames(y) <- sub("Longitude","Long_",colnames(y))
       
       colnames(y) <- sub("Last.Update","Last_Update",colnames(y))
       colnames(y) <- sub("Province.State","Province_State",colnames(y))
       colnames(y) <- sub("Longitude","Long_",colnames(y))
       y$Active <- NA
       y$Admin2 <- NA 
       y$FIPS <- NA
       y$Combined_Key <- NA 
       y$Case_Fatality_Ratio <- NA
       y$Incident_Rate <- NA 
  } else if(fileDate < mdy("05/29/2020")){
    y$Case_Fatality_Ratio <- NA
    y$Incident_Rate <- NA 
  }
  else if (fileDate <= mdy("11/09/2020")){
    colnames(y) <- sub("Case.Fatality_Ratio","Case_Fatality_Ratio",colnames(y))
    colnames(y) <- sub("Incidence_Rate","Incident_Rate",colnames(y))
    
  }
  # extract date from file name, assign to date column because
  # Last_Update field format varies day by day and a good programmer is 
  # a lazy programmer
  y$date <- substr(filenames[x],1,10)
  y
  })

# check number of columns, should be 15 for all files 
table(unlist(lapply(1:length(theFiles),function(x) length(names(dataList[[x]])))))

data <- do.call(rbind,dataList)