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


weatherdf<-read.csv("weather.csv", header=TRUE, stringsAsFactors = TRUE)
#drop weather data that does not have an average value; seems to only have data from airports now; maybe focus o'hare
weatherdf<-weatherdf[!is.na(weatherdf$TAVG), ]

#may need to select one weather station

trandf<-read.csv("Transit mar25 mar26.csv", header=TRUE, stringsAsFactors = TRUE, )


trandf$service_date<-lubridate::mdy(trandf$service_date)

#weatherdf<-unique(weatherdf)

