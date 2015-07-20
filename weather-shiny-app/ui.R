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
                selectInput('destinationState', 'Where are you going to ?', state.name),
                sliderInput('monthView', 'Which month are you travelling ?', min = 1, max = 12, value = 3),
                selectInput('variableView', 'What is your concern?', c("Death or Injury" = "health_impact",
                                                                       "Property and Crop Damages" = "DMG",
                                                                       "Global risks (risk index)" = "riskIndex"), selected = "riskIndex"),
                
                helpText("Data are cumulated amount between 1950 and 2011"),
                helpText("Death of Injuries in number of cases"),
                helpText("Damages in USD for properties and crop"),
                helpText("Global risk index [0-100] is an agregated index, see documentation for details")
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
                                 h4('The safest month to travel in this state is :'),
                                 h3(textOutput('topMonth')),
                                 hr(),
                                 dataTableOutput('bestMonth')
                        ),
                        tabPanel("Best state to travel",
                                 h4('The safest state to travel during this month is :'),
                                 h3(textOutput('topState')),
                                 hr(),
                                 dataTableOutput('bestState')
                        ),
                        tabPanel("Documentation",
                                p('The purpose of this app is to inform the user about the biggest potential server weather risk she/he may encounter while travelling in a specific state for a specific month. Then the app will recommend the best month to travel to this location (for which the risk is the lowest) as well as where in USA would be the safest during the same period.'),
                                p('In addition, a map of USA illustrates the distribution risk of similar severe weather events during the same period.'),
                                 hr(),
                                 p('To use the app, select your destination of travel (State name), and the month of travel.'),
                                p('Per default, the app use a composite risk index to compare the severe weather events. Nevertheless, other choice are possible, such as health impact, measuring the total fatalitites and injuries over the period or the damages, measuring the total damages in USD over the period, both for property and crop'),
                                hr(),
                                 p('The data used by this app is a cleaned and tidy data set of severe weather events in the US since 1950 evaluated from both financial and health impact cumed for each month of the year, each state and event type. Initial data is from the NOAA Storm Database (see http://rpubs.com/longwei66/87696).')
                        )
                )
        )
))