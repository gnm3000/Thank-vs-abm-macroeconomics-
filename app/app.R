library(shiny)
source("ui.R")
source("server.R")

shinyApp(ui = app_ui(), server = app_server)
