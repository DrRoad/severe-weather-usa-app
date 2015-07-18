library(shiny)
shinyUI(pageWithSidebar(
        headerPanel("USA severe weather maps"),
        sidebarPanel(
                h3('Options'),
                sliderInput('monthView', 'Month', min = 1, max = 12, value = 6),
                selectInput('eventview', 'Type of event', unique(weather$EVENT_TYPE))
        ),
        mainPanel(
                h3('USA Map'),
                textOutput('text1'),
                plotOutput('weatherMap')
        )
))