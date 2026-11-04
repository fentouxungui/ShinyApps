library(shiny)

ui <- fluidPage(
  titlePanel("About ShinyApps Store"),
  p("ShinyApps Store is a desktop app store for Shiny applications."),
  p("Applications are delivered as per-app bundles from the store; use", strong("Manage apps"), "to install them."),
  p(a("github.com/fentouxungui/ShinyApps", href = "https://github.com/fentouxungui/ShinyApps"))
)

server <- function(input, output, session) {}

shinyApp(ui, server)