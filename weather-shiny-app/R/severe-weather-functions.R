## =============================================================
##
##      Functions for severe weather USA Map
##
##      load_libraries
##      load_data
##      group_data
##      plot_weather_map
## =============================================================

## Load libraries
load_libraries <- function() {
        library(dplyr)
        library(grid)
        library(ggplot2)
        library(ggthemes)
        library(maps)
        
}

## Load data
load_data <- function(fileName) {
        dF <- read.csv(fileName, sep = ",", header = TRUE, stringsAsFactors = FALSE, strip.white=TRUE)
        ## create the health impact
        dF$health_impact <- dF$FATALITIES + dF$INJURIES
        
        ## create the riskIndex
        dF$riskIndex <- log(dF$DMG+1)+5*log(dF$health_impact+1)
#        dF$DMG <- log(dF$DMG + 1)
#        dF$health_impact <- log(dF$health_impact + 1)
        dF
}

## group data per state
group_data <- function(dF) {
        # Group the data per grouping formula
        dFgrouped <- dF %>% group_by(STATE)
        dFgrouped <- dFgrouped %>% summarise_each(funs(sum(., na.rm = TRUE)), DMG, health_impact, riskIndex)
        ## Create the health impact variable and total damage
        dFgrouped
        
}

find_main_risk <- function(dF, monthView = 8, stateView = "texas", variableView = "riskIndex") {
        # get the state name
        ## USA States data
        states <- data.frame(STATE = state.abb, region = tolower(state.name))
        stateView <- states[states$region == tolower(stateView),]$STATE
        
        subdF <- dF[dF$STATE == stateView & dF$month == monthView,]
        subdFgrouped <- subdF %>% group_by(EVENT_TYPE)
        subdFgrouped <- subdFgrouped %>% summarise_each(funs(sum(., na.rm = TRUE)), DMG, health_impact, riskIndex)
        
        if(variableView == "DMG") {
                subdFgrouped <- arrange(subdFgrouped, desc(DMG))
        }
        if(variableView == "health_impact") {
                subdFgrouped <- arrange(subdFgrouped, desc(health_impact))
                
        }
        if(variableView == "riskIndex") {
        subdFgrouped <- arrange(subdFgrouped, desc(riskIndex))
        }
        #subdFgrouped[1:3,]$EVENT_TYPE
        subdFgrouped[1,]$EVENT_TYPE
}


## plot map
plot_weather_map <- function(dF, eventType = "FLOOD", monthView = 8 , variableView = "riskIndex", mapTitle = "Map of same events over the same month") {
        geodF <- dF[dF$month == monthView & dF$EVENT_TYPE == eventType,]
        geodF <- group_data(geodF)
        states <- data.frame(STATE = state.abb, region = tolower(state.name))
        states_map <-map_data("state")
        cnames <-aggregate(cbind(long, lat) ~ region, data = states_map, FUN = function(x) mean(range(x)))
        cnames$angle <-0
        geodF <- merge(geodF, states, by.x = "STATE", by.y = "STATE", all.y = TRUE)
        
        
        p1 <- ggplot(geodF, aes(map_id = region))
        p1 <- p1 + geom_map(aes_string(fill = variableView, label = "STATE"), map = states_map, color ="black")
        p1 <- p1 + expand_limits(x = states_map$long, y = states_map$lat)
        p1 <- p1 + theme_few()
        p1 <- p1 + geom_text(data=cnames, aes(long, lat, label = region,  
                                              angle=angle, map_id =NULL), size=2.5)
        p1 <- p1 + theme(legend.position = "bottom",
                                      axis.ticks = element_blank(), 
                                      axis.title = element_blank(), 
                                      axis.text =  element_blank())
        p1 <- p1 + scale_fill_gradient(low="green", high="red", na.value = "white")
        p1 <- p1 + guides(fill = guide_colorbar(barwidth = 10, barheight = .5))
        #p1 <- p1 + facet_wrap(~EVENT_TYPE, nrow = 7)
        p1 <- p1 + ggtitle(mapTitle)
        print(p1)
        
}


        
        












