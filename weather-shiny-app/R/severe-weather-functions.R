## ============================================================================
##
##      Functions for severe weather USA Map
##      ************************************
##      
##      1. load_libraries................Load necessary libs
##      2. load_data.....................Load weather data from csv
##      3. group_data....................Group weather data per State
##      4. find_main_risk................Return main risk for a state / month
##      5. plot_weather_map..............Generate map of weather impact
## ============================================================================

##      [1]
##      Load libraries
## ======================================
load_libraries <- function() {
        library(dplyr)
        library(grid)
        library(ggplot2)
        library(ggthemes)
        library(maps)
        library(Hmisc)
}

##      [2]
##      Load severe weather data from csv
## ======================================
load_data <- function(fileName) {
        dF <-
                read.csv(
                        fileName, sep = ",", header = TRUE, stringsAsFactors = FALSE, strip.white =
                                TRUE
                )
        ## create the health impact
        dF$health_impact <- dF$FATALITIES + dF$INJURIES
        
        ## create the riskIndex
        dF$riskIndex <- log(dF$DMG + 1)/2 + 3 * log(dF$health_impact + 1)
        
        ## return the dataframe of severe weather events
        dF
}

##      [3]
##      group data per state
## ======================================
group_data <- function(dF) {
        # Group the data per grouping formula
        dFgrouped <- dF %>% group_by(STATE)
        dFgrouped <-
                dFgrouped %>% summarise_each(funs(sum(., na.rm = TRUE)), DMG, health_impact, riskIndex)
        ## Create the health impact variable and total damage
        dFgrouped
        
}


##      [4]
##      return main risk for a state / month
## ======================================
find_main_risk <-
        function(dF, monthView = 8, stateView = "texas", variableView = "riskIndex") {
                # get the state name
                ## USA States data
                states <-
                        data.frame(STATE = state.abb, region = tolower(state.name))
                stateView <-
                        states[states$region == tolower(stateView),]$STATE
                
                subdF <- dF[dF$STATE == stateView & dF$month == monthView,]
                subdFgrouped <- subdF %>% group_by(EVENT_TYPE)
                subdFgrouped <-
                        subdFgrouped %>% summarise_each(funs(sum(., na.rm = TRUE)), DMG, health_impact, riskIndex)
                
                if (variableView == "DMG") {
                        subdFgrouped <- arrange(subdFgrouped, desc(DMG))
                }
                if (variableView == "health_impact") {
                        subdFgrouped <- arrange(subdFgrouped, desc(health_impact))
                        
                }
                if (variableView == "riskIndex") {
                        subdFgrouped <- arrange(subdFgrouped, desc(riskIndex))
                }
                #subdFgrouped[1:3,]$EVENT_TYPE
                capitalize(tolower(subdFgrouped[1,]$EVENT_TYPE))
        }




##      [5]
##      plot severe weather event map / month
## =======================================
plot_weather_map <-
        function(dF, eventType = "FLOOD", monthView = 8 , variableView = "riskIndex", mapTitle = "Map of same events over the same month") {
                eventType <- toupper(eventType)
                mapTitle <- paste("Map of", eventType, "for the month of", month.name[monthView])
                
                ## subset weather events for the month and the type
                geodF <- dF[dF$month == monthView & dF$EVENT_TYPE == eventType,]
                geodF <- group_data(geodF)
                
                ## create data frame of states and abreviations
                states <-
                        data.frame(STATE = state.abb, region = tolower(state.name))
                
                ## merge with severe weather data
                geodF <-
                        merge(
                                geodF, states, by.x = "STATE", by.y = "STATE", all.y = TRUE
                        )
                
                ## generate names for ggplot map
                states_map <- map_data("state")
                cnames <-
                        aggregate(
                                cbind(long, lat) ~ region, data = states_map, FUN = function(x)
                                        mean(range(x))
                        )
                cnames$angle <- 0                
                
                ## generate the choropleth
                p1 <- ggplot(geodF, aes(map_id = region))
                p1 <- p1 + geom_map(
                        aes_string(fill = variableView, label = "STATE"), map = states_map, color =
                                "black"
                )
                p1 <- p1 + expand_limits(x = states_map$long, y = states_map$lat)
                p1 <- p1 + theme_few()
                p1 <- p1 + geom_text(
                        data = cnames, aes(
                                long, lat, label = region,
                                angle = angle, map_id = NULL
                        ), size = 3.5
                )
                p1 <- p1 + theme(
                        legend.position = "bottom",
                        axis.ticks = element_blank(),
                        axis.title = element_blank(),
                        axis.text =  element_blank()
                )
                p1 <- p1 + scale_fill_gradient(low = "green", high = "red", na.value = "white")
                p1 <- p1 + guides(fill = guide_colorbar(barwidth = 10, barheight = .5))
                p1 <- p1 + ggtitle(mapTitle)
                print(p1)
        }


##      [4]
##      return main risk for a state / month
## ======================================
find_best_month <-
        function(dF, stateView = "texas", variableView = "riskIndex") {
                # get the state name
                ## USA States data
                states <-
                        data.frame(STATE = state.abb, region = tolower(state.name))
                stateView <-
                        states[states$region == tolower(stateView),]$STATE
                
                subdF <- dF[dF$STATE == stateView,]
                subdFgrouped <- subdF %>% group_by(month)
                
                if(variableView == "riskIndex"){
                        subdFgrouped <-
                                subdFgrouped %>% summarise_each(funs(sum(., na.rm = TRUE)), riskIndex)
                        subdFgrouped$riskIndex <- round(subdFgrouped$riskIndex)
                        subdFgrouped <- arrange(subdFgrouped, riskIndex)
                }
                if(variableView == "health_impact"){
                        subdFgrouped <-
                                subdFgrouped %>% summarise_each(funs(sum(., na.rm = TRUE)), health_impact)
                        subdFgrouped$health_impact <- round(subdFgrouped$health_impact)
                        subdFgrouped <- arrange(subdFgrouped, health_impact)
                }
                if(variableView == "DMG"){
                        subdFgrouped <-
                                subdFgrouped %>% summarise_each(funs(sum(., na.rm = TRUE)), DMG)
                        subdFgrouped$DMG <- round(subdFgrouped$DMG)
                        subdFgrouped <- arrange(subdFgrouped, DMG)
                }
                
                subdFgrouped$month <- month.name[subdFgrouped$month]
                message(str(subdFgrouped))
                subdFgrouped
                #subdFgrouped[1:3,]$EVENT_TYPE
                #subdFgrouped[nrow(subdFgrouped),]$month
        }



##      [4]
##      return main risk for a state / month
## ======================================
find_best_state <-
        function(dF, monthView = 8, variableView = "riskIndex") {
                # get the state name
                ## USA States data
                states <-
                        data.frame(STATE = state.abb, region = tolower(state.name))
                dF <- merge(dF, states, by = "STATE")
                
                subdF <- dF[dF$month == monthView,]
                subdFgrouped <- subdF %>% group_by(region)
                
                if(variableView == "riskIndex"){
                        subdFgrouped <-
                                subdFgrouped %>% summarise_each(funs(sum(., na.rm = TRUE)), riskIndex)
                        subdFgrouped$riskIndex <- round(subdFgrouped$riskIndex)
                        subdFgrouped <- arrange(subdFgrouped, riskIndex)
                }
                
                if(variableView == "health_impact"){
                        subdFgrouped <-
                                subdFgrouped %>% summarise_each(funs(sum(., na.rm = TRUE)), health_impact)
                        subdFgrouped$health_impact <- round(subdFgrouped$health_impact)
                        subdFgrouped <- arrange(subdFgrouped, health_impact)
                }
                if(variableView == "DMG"){
                        subdFgrouped <-
                                subdFgrouped %>% summarise_each(funs(sum(., na.rm = TRUE)), DMG)
                        subdFgrouped$DMG <- round(subdFgrouped$DMG)
                        subdFgrouped <- arrange(subdFgrouped, DMG)
                }
                message(str(subdFgrouped))
                names(subdFgrouped) <- c("State", "risk_index")
                subdFgrouped$State <- capitalize(as.character(subdFgrouped$State))
                subdFgrouped
                
        }
