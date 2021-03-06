library(RODBC)
ch <- odbcConnect("localdb")
# read from mssql database
res <- sqlQuery(
  ch,
  paste(
    "SELECT Satellite,Sigtype,
    FORMAT(Date,'yyyy-MM') as [MonthYear]
    ,avg([S4 Cor]) as S4
    
    FROM [S4LogFiles].[dbo].[REDOBS_GPS_LOG]
    where [CMC Avg] between -0.5 and 0.5
    and [Lock Time] > 60
    and Elv > 20
    group by date,Satellite,Sigtype"
  )
  )
close(ch)
library(ggplot2)
library(zoo)
df <- as.data.frame(res)
library(dplyr)
df<-df%>% group_by(Satellite,MonthYear,Sigtype)%>%
  dplyr::summarize(average=mean(S4))
df$Satellite<-as.character(paste('G',df$Satellite))
df$Sigtype<-as.character(df$Sigtype)
df$MonthYear <- as.Date(as.yearmon(df$MonthYear,"%Y-%m"))
library(plyr)
df$Sigtype <- revalue(df$Sigtype,c("1"="L1CA","7" ="L5Q"))
#Monthly Average Scintillation for all GPS Satellites
ggplot(df, aes(df$MonthYear,df$average)) + geom_point(aes(color = Satellite,group=Satellite), alpha = 0.9) + 
  geom_line(stat = "summary", fun.y = "mean") +
  xlab("Month") + ylab("Average S4 Corrected") +
  theme_bw() +
  theme(plot.title = element_text(hjust = 0.5)) +
  scale_x_date(date_breaks = waiver()) +
  theme(axis.text = element_text(colour = "black")) +
  facet_grid(Sigtype ~ .)

