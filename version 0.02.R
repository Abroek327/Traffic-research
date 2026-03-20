library(ggplot2)
library(tidyverse)
library(dplyr)
library(lubridate)
library(ggdag)
library(dagitty)
library(brms)
library(ggcorrplot)
library(bayesplot)
library(splines2)
library(bayestestR)
library(fbst)
library(BayesFactor)
library(rwunderground)


#attempted api call to weatherunderground; TODO: somehow reslove server errors
#set_api_key("6ab73a8c61de4de6b73a8c61de5de6be")
#weather_station<-"KILCHICA130"
#weather_data<-history_range(set_location(PWS_id = "KILCHICA843" ), date_start = "20250101", date_end = "20250102")

weatherdf<-read.csv("weather.csv", header=TRUE, stringsAsFactors = TRUE)

weatherdf<-cbind()
#weatherdf<-transform(weatherdf, date=paste(mo,DY,year))
#may need to select one weather station

trandf<-read.csv("transit apr21 to nov2025.csv", header=TRUE, stringsAsFactors = TRUE, )


trandf$service_date<-lubridate::mdy(trandf$service_date)


combine<-bind_rows(list(a=weatherdf, b=trandf), .id="id")
view(combine)
#DATA<-Reduce(function(x,y) merge(x,y, all=TRUE), list(weatherdf, trandf))

#DATA<-unique(DATA)
#view(DATA)

#trainPrior<-c(set_prior())
