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

set_api_key("6ab73a8c61de4de6b73a8c61de5de6be")
weather_station<-"KILCHICA130"

weather_data<-history_range(set_location(PWS_id = "KILCHICA130" ), date_start = "20250101", date_end = "20250201")

#weatherdf<-read.csv("weather.csv", header=TRUE, stringsAsFactors = TRUE)
#drop weather data that does not have an average value; seems to only have data from airports now; maybe focus o'hare
#weatherdf<-weatherdf[!is.na(weatherdf$TAVG), ]

#may need to select one weather station

trandf<-read.csv("Transit mar25 mar26.csv", header=TRUE, stringsAsFactors = TRUE, )


trandf$service_date<-lubridate::mdy(trandf$service_date)

#weatherdf<-unique(weatherdf)

