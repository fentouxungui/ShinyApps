library(shiny)

ui <- fluidPage(
  titlePanel("Welcome to ShinyApps"),
  p("This is the ShinyApps desktop launcher."),
  p("Install and run applications from the app store: open", strong("Manage apps"), "to browse and install available apps.")
)

server <- function(input, output, session) {}

shinyApp(ui, server)