library(shiny)

ui <- fluidPage(
  titlePanel("Welcome to ShinyApps Store"),
  p("This is the ShinyApps Store desktop launcher."),
  p("Install and run applications from the app store: open", strong("Manage apps"), "to browse and install available apps.")
)

server <- function(input, output, session) {}

shinyApp(ui, server)