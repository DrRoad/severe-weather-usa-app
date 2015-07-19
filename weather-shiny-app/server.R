library(shiny)
## Load the functions
source("./R/severe-weather-functions.R")
## load libraries
load_libraries()
## load data
weather <- load_data("./data/severe-weather-compact-db.csv")


shinyServer(
        function(input, output){
                ## use reactive function to get update of top risk for state / month
                x <- reactive({ find_main_risk(weather, monthView = input$monthView, stateView = input$destinationState, variableView = input$variableView)})
                y <- reactive({input$variableView})
                z <- reactive({find_best_month(weather, stateView = input$destinationState)})
                w <- reactive({find_best_state(weather, monthView = input$monthView)})
                q <- reactive({find_best_month(weather, stateView = input$destinationState)[1,]$month})
                k <- reactive({find_best_state(weather, monthView = input$monthView)[1,]$State})
                
                ## generate output variables, toprisk and weathermap
                output$topRisk <- renderText(x())
                output$weatherMap <- renderPlot(plot_weather_map(weather, monthView = input$monthView, eventType = x(), variableView = y()))
                output$bestMonth <- renderDataTable(z())
                output$bestState <- renderDataTable(w())
                output$topMonth <- renderText(q())
                output$topState <- renderText(k())
                
        }
)