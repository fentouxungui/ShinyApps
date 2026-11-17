library(shiny)

# Brand tokens mirror brand/tokens.json; keep this screen in sync with brand/README.md.
ui <- fluidPage(
  tags$head(
    tags$title("About ShinyApps Store"),
    tags$style(HTML("
      .sa-hero {
        display: flex; align-items: center; gap: 18px;
        padding: 18px 22px; margin-bottom: 18px;
        border: 1px solid #1A2E49; border-radius: 24px;
        background: linear-gradient(180deg, #0C1A2C 0%, #0A1424 100%);
        color: #EAF2FF;
      }
      .sa-hero img { width: 72px; height: 72px; flex: none; }
      .sa-hero .sa-name { margin: 0; font-size: 26px; font-weight: 700; color: #EAF2FF; }
      .sa-hero .sa-name em { font-style: italic; }
      .sa-hero .sa-tag {
        margin: 6px 0 0; font-size: 11px; font-weight: 600;
        letter-spacing: .18em; color: #8FB0D8;
      }
      .sa-body { max-width: 760px; }
      .sa-body a { color: #2F6BFF; }
    "))
  ),
  div(
    class = "sa-body",
    div(
      class = "sa-hero",
      img(src = "logo.svg", alt = "ShinyApps Store"),
      div(
        h1(class = "sa-name", HTML("<em>Shiny</em>Apps Store")),
        p(class = "sa-tag", "THE APP STORE FOR R SHINY")
      )
    ),
    p("ShinyApps Store is a desktop app store for Shiny applications."),
    p("Applications are delivered as per-app bundles from the store; use",
      strong("Manage apps"), "to install them."),
    p(a("github.com/fentouxungui/ShinyApps",
        href = "https://github.com/fentouxungui/ShinyApps"))
  )
)

server <- function(input, output, session) {}

shinyApp(ui, server)
