library(ggplot2)
library(tidyverse)
library(dplyr)
library(lubridate)
library(ggdag)
library(dagitty)
crashdf<-read.csv("Crashes Mar25 Mar 26 1km MilPRK.csv", header = TRUE)
trandf<-read.csv("Transit mar25 mar26.csv", header=TRUE)



#remove time form date field
crashdf$CRASH_DATE<-as.Date(crashdf$CRASH_DATE, "%m/%d/%y")
crashdf$CRASH_DATE<-as.character(crashdf$CRASH_DATE)



crash_temp<-crashdf |> group_by(CRASH_DATE) |>
  mutate(n())



keeps<-c("CRASH_DATE", "n()")


crash_count<-crash_temp[keeps]

crash_count<-unique(crash_count)
names(crash_count)[names(crash_count)=="n()"] <-"total_accidents"

#view(crash_count)


#head(crashdf)
rail_dag<-dagify(
  
total_accidents~ROADWAY_SURFACE_COND+LIGHTING_CONDITION+WEATHER_CONDITION,
ROADWAY_SURFACE_COND~WEATHER_CONDITION,
WEATHER_CONDITION~CRASH_MONTH+CRASH_HOUR+CRASH_DAY+LIGHTING_CONDITION,
rail_boardings~total_accidents+day_type,


labels = c(total_accidents="accident total", ROADWAY_SURFACE_COND="Road Condition",
           LIGHTING_CONDITION="Lighting", WEATHER_CONDITION="Weather", 
           day_type="Day", rail_boardings="Rail total", CRASH_MONTH="Month",
           CRASH_HOUR="Hour", CRASH_DAY="Day", day_type="Day Type"),

exposure = "total_accidents",
outcome = "rail_boardings"
)

#impliedConditionalIndependencies(rail_dag)
adjustmentSets(rail_dag)
ggdag_status(rail_dag, use_labels = "label")+
  theme_dag()

#ggdag_paths(rail_dag, layout="time_ordered")+
#  theme_dag()
#ggdag_adjustment_set(rail_dag)+
#    theme_dag()

#head(crashdf)
#crashdf
#View(trandf)

#point map of accidents
#ggplot(crashdf, aes(x=LONGITUDE, y=LATITUDE))+
#  geom_count()


#ggplot(crashdf, aes(x=CRASH_DATE, y=count(CRASH_DATE)))+
#  geom_bar()


#dateGroup<-crashdf
#dateGroup |> group_by(CRASH_DATE) |> tally()

#head(dateGroup)

