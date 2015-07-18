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
                selectInput('destinationState', 'Where are you going ?', state.name),
                sliderInput('monthView', 'Which month are you travelling ?', min = 1, max = 12, value = 3),
                selectInput('variableView', 'What is your concern?', c("Death or Injury" = "health_impact",
                                                          "Property or Crop Damages" = "DMG",
                                                          "Global risks (risk index)" = "riskIndex"), selected = "riskIndex"),
                
                helpText("Documentation note 1",
                         "Documentation note 2",
                         "Documentation note 3")
        ),
        
        mainPanel(
                h3('Main risk :'),
                h3(textOutput('topRisk')),
                
                plotOutput('weatherMap'))
))