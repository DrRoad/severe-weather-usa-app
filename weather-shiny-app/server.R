library(shiny)
## Load the functions
source("./R/severe-weather-functions.R")
## load libraries
load_libraries()
## load data
weather <- load_data("./data/severe-weather-compact-db.csv")


shinyServer(
        function(input, output){
                output$weatherMap <- renderPlot(plot_weather_map(weather, monthView = input$monthView, eventType = input$eventview))
        }
)