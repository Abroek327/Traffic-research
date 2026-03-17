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

crashdf<-read.csv("Crashes Mar25 Mar 26 1km MilPRK.csv", header = TRUE)
trandf<-read.csv("Transit mar25 mar26.csv", header=TRUE, stringsAsFactors = TRUE) #stops in nov 2025




#remove time from CRASH_DATE
crashdf$CRASH_DATE=substr(crashdf$CRASH_DATE, 1, nchar(crashdf$CRASH_DATE)-5)

crashdf$CRASH_DATE<-lubridate::mdy(crashdf$CRASH_DATE)

#convert trandf service_date to actual date field

trandf$service_date<-lubridate::mdy(trandf$service_date)

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


#turn everything to a stoner
DATA$ROADWAY_SURFACE_COND<-as.numeric(as.factor(DATA$ROADWAY_SURFACE_COND))
DATA$LIGHTING_CONDITION<-as.numeric(as.factor(DATA$LIGHTING_CONDITION))
DATA$WEATHER_CONDITION<-as.numeric(as.factor(DATA$WEATHER_CONDITION))
DATA$day_type<-as.numeric(as.factor(DATA$day_type))

DATA$rail_boardings<-as.numeric(DATA$rail_boardings)
#sapply(DATA, class)

#default_prior(rail_boardings~total_accidents+ROADWAY_SURFACE_COND+LIGHTING_CONDITION+WEATHER_CONDITION+
#                ROADWAY_SURFACE_COND*WEATHER_CONDITION+day_type+ LIGHTING_CONDITION*WEATHER_CONDITION+
#                LIGHTING_CONDITION*ROADWAY_SURFACE_COND+WEATHER_CONDITION*ROADWAY_SURFACE_COND, 
#                data=DATA)



#priors<-set_prior("normal(1,10)", class="b")
  

#First attempt; blind gaussian brms 

#mod1<-brm(rail_boardings~total_accidents+ROADWAY_SURFACE_COND+LIGHTING_CONDITION+WEATHER_CONDITION+
#            ROADWAY_SURFACE_COND*WEATHER_CONDITION+day_type+ LIGHTING_CONDITION*WEATHER_CONDITION+
#            LIGHTING_CONDITION*ROADWAY_SURFACE_COND+WEATHER_CONDITION*ROADWAY_SURFACE_COND, 
#            data=DATA, sample_prior = "only", prior = priors, iter = 2000, warmup=1500)

#summary(mod1)
#bayesplot::mcmc_dens_chains(mod1)
#posterior_summary(mod1)

#bayesplot::mcmc_areas(mod1, pars="b_total_accidents")


#getting more advanced, attemtping non-linear fit for total_accidents since coef was 0 under gausian linear regression
default_prior(rail_boardings~s(total_accidents, by=ROADWAY_SURFACE_COND) + ROADWAY_SURFACE_COND + 
                LIGHTING_CONDITION + WEATHER_CONDITION + day_type, data=DATA)

priors<-c(set_prior("student_t(3,138,102.3", class="Intercept"), 
          set_prior("student_t(3,0,102.3", class="sds"),
          set_prior("normal(1,10)", class="b" ) )

prior3<-c(set_prior("student_t(3,138,102.3", class="Intercept"), 
          
          set_prior("normal(1,10)", class="b" ) )

mod2<-brm (rail_boardings~s(total_accidents, by=ROADWAY_SURFACE_COND) + ROADWAY_SURFACE_COND + LIGHTING_CONDITION + WEATHER_CONDITION + day_type, 
          data=DATA, family=negbinomial(), prior=priors, sample_prior = "only", save_pars = save_pars(all=TRUE))
summary(mod2)
posterior_summary(mod2)

mod3<-brm (rail_boardings~ROADWAY_SURFACE_COND + LIGHTING_CONDITION + WEATHER_CONDITION + day_type, 
           data=DATA, family=negbinomial(), prior=prior3, sample_prior = "only", save_pars = save_pars(all=TRUE))

#Posterior probability HT rough
post_prob(mod2, mod3)

#mod2      mod3 
#0.5000395 0.4999605 

#mod2|> pp_check()
#yrep<-posterior_predict(mod2, draws=500)
#ppc_stat(DATA$total_accidents, stat="mean", binwidth = 0.005)

#mcmc_dens(mod2)
#mcmc_trace(mod2)

#Correlation plots
#big_corr<-cor(DATA$CRASH_HOUR, DATA$total_accidents)
#p.mat<-cor_pmat(DATA)
#head(big_corr)


#crr<-cor_pmat(DATA, vars=c("CRASH_HOUR", "total_accidents"))
#head(crr)
#ggcorrplot(big_corr)

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
#crash_count$CRASH_DATE<-as.Date(crash_count$CRASH_DATE)
#crash_count$CRASH_DATE<-as.Date(as.POSIXct((as.numeric(as.character(crash_count$CRASH_DATE)))))
#typeof(crash_count$CRASH_DATE)


#whole date vs total accidents, seems to spike the most in summer interestingly
#ggplot(data=crash_count, aes(x=CRASH_DATE, y=total_accidents))+
#  geom_point()+
#  geom_line()
#type.convert(trandf$rail_boardings, as.is=TRUE)
#typeof(trandf$rail_boardings)



#trandf$service_date<-as.Date(trandf$service_date, "%y/%m/%d")


#typeof(trandf$service_date)

#really needed this one
#trandf$rail_boardings<-as.integer(trandf$rail_boardings)


#ggplot(data=trandf, aes(x=day_type, y=rail_boardings, fill=day_type))+
#  geom_violin()

#ggplot(data=trandf, aes(x=service_date, y=rail_boardings))+
#  geom_point()+
#  geom_line()

#Visualize relationship between weather and rail boarding (weather seems to be a severe dampener)
#DATA$rail_boardings<-as.integer(DATA$rail_boardings)
#ggplot(data=DATA, aes(x=WEATHER_CONDITION, y=rail_boardings, fill=WEATHER_CONDITION))+
#  geom_bar(stat="identity")

#day of week vs rail boarding; lowest at the start of of the week and jumps back up 
#DATA$CRASH_DAY_OF_WEEK<-as.factor(DATA$CRASH_DAY_OF_WEEK)
#ggplot(data=DATA, aes(x=CRASH_DAY_OF_WEEK, y=rail_boardings, fill=CRASH_DAY_OF_WEEK))+
#  geom_bar(stat="identity")

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

