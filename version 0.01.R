library(ggplot2)
library(tidyverse)
library(dplyr)
library(lubridate)
library(ggdag)
library(dagitty)
library(brms)
crashdf<-read.csv("Crashes Mar25 Mar 26 1km MilPRK.csv", header = TRUE)
trandf<-read.csv("Transit mar25 mar26.csv", header=TRUE)



#remove time form date field
crashdf$CRASH_DATE<-as.Date(crashdf$CRASH_DATE, "%m/%d/%y")
crashdf$CRASH_DATE<-as.character(crashdf$CRASH_DATE)


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

#view(crash_count)

#create one nice big dataframe for simple model computation

DATA<-Reduce(function(x,y) merge(x,y, all=TRUE), list(crashdf, trandf, crash_count))

#DATA$WEATHER_CONDITION <-as.numeric(levels(DATA$WEATHER_CONDITION)[DATA$WEATHER_CONDITION])
#DATA$WEATHER_CONDITION<-as.factor(DATA$WEATHER_CONDITION)
#DATA$WEATHER_CONDITION<levels(DATA$WEATHER_CONDITION)
#sapply(DATA, class)

#head(DATA)

#view(DATA)
#head(crashdf)

#create dag
rail_dag<-dagify(
  
total_accidents~ROADWAY_SURFACE_COND+LIGHTING_CONDITION+WEATHER_CONDITION+TRAFFICWAY_TYPE,
ROADWAY_SURFACE_COND~WEATHER_CONDITION,
WEATHER_CONDITION~CRASH_MONTH+CRASH_HOUR+CRASH_DAY+LIGHTING_CONDITION,
rail_boardings~total_accidents+day_type,


labels = c(total_accidents="accident total", ROADWAY_SURFACE_COND="Road Condition",
           LIGHTING_CONDITION="Lighting", WEATHER_CONDITION="Weather", 
           day_type="Day", rail_boardings="Rail total", CRASH_MONTH="Month",
           CRASH_HOUR="Hour", CRASH_DAY="Day", day_type="Day Type", TRAFFICWAY_TYPE="Road Type"),

exposure = "total_accidents",
outcome = "rail_boardings"
)



#I think I need to graph my data first
#mod1<-brm(rail_boardings~total_accidents+ROADWAY_SURFACE_COND+LIGHTING_CONDITION+WEATHER_CONDITION+
#            ROADWAY_SURFACE_COND*WEATHER_CONDITION+day_type, data=DATA)

#summarise(mod1)





#weather condition violin graph
#ggplot(DATA, aes(x=WEATHER_CONDITION, y=total_accidents, fill=WEATHER_CONDITION))+
#  geom_violin()
  
#Lighting violin graph
#ggplot(data=DATA, aes(x=LIGHTING_CONDITION, y=total_accidents, fill=LIGHTING_CONDITION))+
#  geom_violin()

#surface condition vs accidents
#ggplot(data=DATA, aes(x=ROADWAY_SURFACE_COND, y=total_accidents, fill=ROADWAY_SURFACE_COND))+
#geom_violin()
 

#day type and rail boardings (overwhelimg majority on weekday)
#ggplot(data=trandf, aes(x=day_type, y=rail_boardings))+
#  geom_bar(stat="identity")

 
#day type and total accidents (vast majority weekday but weekend/sunday/holiday larger)
#ggplot(data=DATA,aes(x=day_type, y=total_accidents))+
#  geom_bar(stat="identity")


#day of week violin graph
#DATA$CRASH_DAY_OF_WEEK<-as.factor(DATA$CRASH_DAY_OF_WEEK)
#ggplot(data=DATA, aes(x=CRASH_DAY_OF_WEEK, y=total_accidents, fill=CRASH_DAY_OF_WEEK))+
#  geom_violin()


#impliedConditionalIndependencies(rail_dag)
#adjustmentSets(rail_dag)
#ggdag_status(rail_dag, use_labels = "label")+
#  theme_dag()

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

