library(shiny)

## Load the functions
source("./R/severe-weather-functions.R")
## load libraries
load_libraries()
## load data
weather <- load_data("./data/severe-weather-compact-db.csv")


shinyUI(pageWithSidebar(
        headerPanel("Travel in USA ~ severe weather risk assesment"),
        sidebarPanel(
                selectInput('destinationState', 'Where are you going ?', state.name),
                sliderInput('monthView', 'Which month are you travelling ?', min = 1, max = 12, value = 3),
                selectInput('variableView', 'What is your concern?', c("Death or Injury" = "health_impact",
                                                                       "Property and Crop Damages" = "DMG",
                                                                       "Global risks (risk index)" = "riskIndex"), selected = "riskIndex"),
                
                helpText("Data are cumulated amount between 1950 and 2011"),
                helpText("Death of Injuries in number of cases"),
                helpText("Damages in USD for properties and crop"),
                helpText("Global risk index is an agregated index, see documentation for details")
        ),
        
        mainPanel(
                tabsetPanel(
                        tabPanel("Risk evaluation",
                                 h4('Prepare yourself to face risks of'),
                                 h3(textOutput('topRisk')),
                                 hr(),
                                 h5('This type of severe weather events are also very active in other states during this perdiod, check-out the map bellow'),
                                 plotOutput('weatherMap'),
                                 helpText("If states are shown in white, it means no available data")),
                        tabPanel("Best Month to travel",
                                 p('Calculate the best month to travel in the same place'),
                                 dataTableOutput('bestMonth')
                        ),
                        tabPanel("Best state to travel",
                                 p('Calculate the best state to travel in the same month'),
                                 dataTableOutput('bestState')
                        ),
                        tabPanel("Help / documentation",
                                 p('data sources'),
                                 p('scrip sources'),
                                 p('license')
                        )
                )
        )
))