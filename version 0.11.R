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

crashdf<-read.csv("Crashes Mar25 Mar 26 1km MilPRK.csv", header = TRUE)

#remove time from CRASH_DATE
crashdf$CRASH_DATE=substr(crashdf$CRASH_DATE, 1, nchar(crashdf$CRASH_DATE)-5)

crashdf$CRASH_DATE<-lubridate::mdy(crashdf$CRASH_DATE)

#convert trandf service_date to actual date field

#trandf$service_date<-lubridate::mdy(trandf$service_date)

#class(crashdf$CRASH_DATE)
#crashdf$CRASH_DATE<-gsub("\\s+", "", crashdf$CRASH_DATE)

#create a temp dataframe to calculate daily accident totals
crash_temp<-crashdf |> group_by(CRASH_DATE) |>
  mutate(n())


#Vector of column names to transfer to new df
keeps<-c("CRASH_DATE", "n()")

#create new df for crash totals
crash_count<-crash_temp[keeps]

#remove duplicate days
crash_count<-unique(crash_count)

#rename the n() column to total_accidents
names(crash_count)[names(crash_count)=="n()"] <-"total_accidents"

#order crash count by earliest to latest date
crash_count<-crash_count[order(as.POSIXct(crash_count$CRASH_DATE)),]

#View(crash_count)

DATA<-Reduce(function(x,y) merge(x,y, all=TRUE), list(crashdf, crash_count))

DATA$ROADWAY_SURFACE_COND<-as.numeric(as.factor(DATA$ROADWAY_SURFACE_COND))
DATA$LIGHTING_CONDITION<-as.numeric(as.factor(DATA$LIGHTING_CONDITION))
DATA$WEATHER_CONDITION<-as.numeric(as.factor(DATA$WEATHER_CONDITION))


default_prior(total_accidents~WEATHER_CONDITION+ROADWAY_SURFACE_COND+CRASH_HOUR+CRASH_DAY_OF_WEEK+CRASH_MONTH,data=DATA)

priors<-c(set_prior("normal(5,1)", class="b", coef="CRASH_HOUR"),
          set_prior("normal(1,10)", class="b", coef="WEATHER_CONDITION"),
          set_prior("normal(7,3)", class="b", coef="CRASH_MONTH"),
          set_prior("normal(2,4)", class="b", coef="LIGHTING_CONDITION"))
#View(DATA)

fit1<-brm(total_accidents~WEATHER_CONDITION+ROADWAY_SURFACE_COND+LIGHTING_CONDITION+CRASH_HOUR+CRASH_DAY_OF_WEEK+
            CRASH_MONTH,data=DATA, sample_prior = "yes", prior = priors)

summary(fit1)

posterior_summary(fit1)

priors2<-c(set_prior("normal(5,1)", class="b", coef="CRASH_HOUR"),
          set_prior("normal(7,3)", class="b", coef="CRASH_MONTH"),
          set_prior("normal(2,4)", class="b", coef="LIGHTING_CONDITION"))

fit2<-brm(total_accidents~ROADWAY_SURFACE_COND+LIGHTING_CONDITION+CRASH_HOUR+CRASH_DAY_OF_WEEK+
            CRASH_MONTH,data=DATA, sample_prior = "yes", prior = priors2)
summary(fit2)

posterior_summary(fit2)

post_prob(fit1,fit2)
