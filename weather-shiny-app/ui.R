library(shiny)

## Load the functions
source("./R/severe-weather-functions.R")
## load libraries
load_libraries()
## load data
weather <- load_data("./data/severe-weather-compact-db.csv")


shinyUI(pageWithSidebar(
        headerPanel("USA severe weather maps"),
        sidebarPanel(
                h3('Options'),
                sliderInput('monthView', 'Month', min = 1, max = 12, value = 6),
                selectInput('eventview', 'Type of event', unique(weather$EVENT_TYPE)),
                helpText("Documentation note 1",
                         "Documentation note 2",
                         "Documentation note 3")
        ),
        
        mainPanel(
                h3('USA Map'),
                textOutput('text1'),
                plotOutput('weatherMap')
        )
))