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

view(weatherdf)

#attempt to calculate daily average
weatherdf %>%
  select(YEAR, MO, DY, HR, TEMP, PRCP, HMDT, WND_SPD, ATM_PRESS)%>%
  transmute(Date=dmy_h(paste(MO,DY,YEAR,HR, sep="/"))) %>%
  group_by(Date)%>%
  mutate(AVTMP=mean(weatherdf$TEMP))


#weatherdf<-cbind()
#wdate<-paste(weatherdf$MO, weatherdf$DY, weatherdf$YEAR, sep="/")
#wdate<-unique(wdate)
#wdate<-lubridate::mdy(wdate)

#weatherdate<-weatherdf |>  group_by(REF) |>
#  mutate(Date=wdate)
  



view(weatherdate)
#weatherdf<-mutate(wdate)

#may need to select one weather station

trandf<-read.csv("transit apr21 to nov2025.csv", header=TRUE, stringsAsFactors = TRUE, )


trandf$service_date<-lubridate::mdy(trandf$service_date)


#combine<-bind_rows(weatherdf,trandf)
#combine<-combine %>% 
##  drop_na()
#iew(combine)
#DATA<-Reduce(function(x,y) merge(x,y, all=TRUE), list(weatherdf, trandf))

#DATA<-unique(DATA)
#view(DATA)

#trainPrior<-c(set_prior())
