library(shiny)
## Load the functions
source("./R/severe-weather-functions.R")
## load libraries
load_libraries()
## load data
weather <- load_data("./data/severe-weather-compact-db.csv")


shinyServer(
        function(input, output){
                x <- reactive({ find_main_risk(weather, monthView = input$monthView, stateView = input$destinationState, variableView = input$variableView)})
                y <- reactive({input$variableView})
                output$topRisk <- renderText(x())
                
                output$weatherMap <- renderPlot(plot_weather_map(weather, monthView = input$monthView, eventType = x(), variableView = y()))
        }
)