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
}

## Load data
load_data <- function(fileName) {
        dF <- read.csv(fileName, sep = ",", header = TRUE, stringsAsFactors = FALSE, strip.white=TRUE)
        dF
}

## group data per state
group_data <- function(dF) {
        # Group the data per grouping formula
        dFgrouped <- dF %>% group_by(STATE)
        dFgrouped <- dFgrouped %>% summarise_each(funs(sum(., na.rm = TRUE)), CROPDMG, PROPDMG, FATALITIES, INJURIES, DMG)
        dFgrouped
}


## plot map
plot_weather_map <- function(dF, eventType = "FLOOD", yearView = 1998, monthView = 8 ) {
        geodF <- dF[dF$year == yearView & dF$month == monthView & dF$EVENT_TYPE == eventType,]
        geodF <- group_data(geodF)
        states <- data.frame(STATE = state.abb, region = tolower(state.name))
        states_map <-map_data("state")

        geodF <- merge(geodF, states, by.x = "STATE", by.y = "STATE")
        geodF
        ## Create the health impact variable and total damage
        geodF$health_impact <- geodF$FATALITIES + geodF$INJURIES
        geodF$total_damages <- geodF$CROPDMG + geodF$PROPDMG
        
        p1 <- ggplot(geodF, aes(map_id = region))
        p1 <- p1 + geom_map(aes(fill = total_damages), map = states_map, color ="black")
        p1 <- p1 + expand_limits(x = states_map$long, y = states_map$lat)
        p1 <- p1 + theme_few()+ theme(legend.position = "bottom",
                                      axis.ticks = element_blank(), 
                                      axis.title = element_blank(), 
                                      axis.text =  element_blank())
        p1 <- p1 + scale_fill_gradient(low="white", high="purple")
        p1 <- p1 + guides(fill = guide_colorbar(barwidth = 10, barheight = .5))
        #p1 <- p1 + facet_wrap(~EVENT_TYPE, nrow = 7)
        p1 <- p1 + ggtitle("Total damages crop+property in USD")
        print(p1)
}


        
        












