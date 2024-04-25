# preparation # 
library(tidyverse)
production <- read.csv(".csv") # path
production %>% count(Element)
production %>% count(Area)

production <- production %>% 
  reframe(Area, Year, Item, Element, Unit, 
          Value, Flag, Flag.Description, Note)



# splitting the tables in three groups and change the name of the "Value" column #
production_area <- production %>% 
  filter(Element == "Area harvested")
colnames(production_area)[6] <- "Area.Harvested"
  View(production_area)

production_t <- production %>% 
  filter(Element == "Production")
colnames(production_t)[6] <- "Production.t"
View(production_t)

production_yield <- production %>% 
  filter(Element == "Yield")
colnames(production_yield)[6] <- "Production.Yield"
View(production_yield)


# merge data frames and export #
# the details of each data (Flag and Note) will be removed with this action
# please use individual tables if you want to look each data
df <- merge(production_t, production_area, by = c("Area", "Year"))
df <- merge(df, production_yield, by = c("Area", "Year"))
production_v2 <- df %>% 
  reframe(Area, Year, Production.t, Area.Harvested, Production.Yield)
View(production_v2)



# add continent and region #
#install.packages("countrycode")
library(countrycode)
production_v2 <- production_v2 %>% 
  mutate(Continent = countrycode(sourcevar = production_v2[, "Area"], 
                                origin = "country.name",
                                destination = "continent")) %>% 
  mutate(Region = countrycode(sourcevar = production_v2[, "Area"],
                              origin = "country.name",
                              destination = "region"))
View(production_v2)

# export #
write_csv(production_v2, "Coffee_Production_1961-2022.csv")

# individual data table #
write_csv(production_area, "Coffee_Production_Area_Harvested.csv")
write_csv(production_t, "Coffee_Production_Volume.csv")
write_csv(production_yield, "Coffee_Production_Yield.csv")



# alternatively, you can use sqldf function to operate the same merge  
# below were unused, but useful method using sqldf function if you are more familiar with SQL

# install.packages("sqldf")
# library(sqldf)
#
# df <- sqldf('SELECT production_t.*, production_area.Area_harvested
#              FROM production_t
#              LEFT JOIN production_area
#              ON production_t.Area = production_area.Area AND production_t.Year = production_area.Year')
#
# df <- sqldf('SELECT df.*, production_yield.Yield_g_ha
#              FROM df
#              LEFT JOIN production_yield
#              ON df.Area = production_yield.Area AND df.Year = production_yield.Year')
#
# production_v2 <- df %>% 
#   reframe(Area, Year, Production_t, Area_harvested, Yield_g_ha)

