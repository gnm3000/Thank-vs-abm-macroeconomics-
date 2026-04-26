library(shiny)
source("app/ui.R")
source("app/server.R")

shinyApp(ui = app_ui(), server = app_server)
