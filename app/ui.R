library(shiny)
library(bslib)
library(plotly)

app_ui <- function() {
  page_sidebar(
    tags$head(tags$link(rel = "stylesheet", type = "text/css", href = "styles.css")),
    title = "THANK vs ABM Macro Simulator",
    theme = bs_theme(version = 5, bootswatch = "darkly", primary = "#4cc9f0"),
    sidebar = sidebar(
      width = 360,
      radioButtons(
        "scenario",
        "Seleccionar escenario",
        choices = c(
          "Transferencia Fiscal" = "fiscal_transfer",
          "Crisis Financiera" = "financial_crisis",
          "Shock de Oferta" = "supply_shock",
          "Trampa de Liquidez" = "liquidity_trap"
        )
      ),
      h5("Parámetros THANK"),
      sliderInput("lambda", "Fracción hand-to-mouth (lambda)", min = 0.05, max = 0.8, value = 0.35, step = 0.01),
      sliderInput("iMPC_poor", "iMPC pobres", min = 0.3, max = 1, value = 0.8, step = 0.01),
      sliderInput("iMPC_rich", "iMPC ricos", min = 0, max = 0.2, value = 0.05, step = 0.005),
      sliderInput("transfer", "Transferencia (% PIB)", min = 0, max = 8, value = 3, step = 0.1),
      sliderInput("phi_pi", "Regla Taylor φπ", min = 0.5, max = 2.5, value = 1.5, step = 0.05),
      sliderInput("phi_y", "Regla Taylor φy", min = 0, max = 0.5, value = 0.125, step = 0.01),
      sliderInput("rho_shock", "Persistencia shock", min = 0.1, max = 0.95, value = 0.7, step = 0.05),
      h5("Parámetros ABM"),
      sliderInput("N_households", "Hogares", min = 200, max = 2000, value = 500, step = 50),
      sliderInput("N_firms", "Firmas", min = 20, max = 200, value = 100, step = 10),
      sliderInput("N_banks", "Bancos", min = 5, max = 30, value = 10, step = 1),
      sliderInput("markup_mean", "Markup promedio", min = 0.05, max = 0.4, value = 0.15, step = 0.01),
      sliderInput("credit_multiplier", "Apalancamiento bancario", min = 2, max = 15, value = 8, step = 1),
      sliderInput("abm_T", "Horizonte ABM (trimestres)", min = 20, max = 120, value = 80, step = 5),
      sliderInput("mc_runs", "Monte Carlo runs", min = 20, max = 300, value = 200, step = 10),
      actionButton("run_sim", "Correr simulación", class = "btn-primary")
    ),
    navset_card_tab(
      nav_panel(
        "THANK",
        plotlyOutput("thank_irf_plot", height = "420px"),
        tableOutput("thank_multipliers"),
        plotlyOutput("thank_consumption_plot", height = "260px")
      ),
      nav_panel(
        "ABM",
        plotlyOutput("abm_fan_chart", height = "350px"),
        plotlyOutput("abm_gini_plot", height = "300px"),
        plotOutput("abm_contagion_plot", height = "260px"),
        plotlyOutput("abm_heatmap", height = "260px")
      ),
      nav_panel(
        "COMPARACIÓN",
        plotlyOutput("comparison_overlay", height = "350px"),
        verbatimTextOutput("divergence_metrics"),
        uiOutput("traffic_light_ui"),
        div(class = "comparison-text", textOutput("comparison_text"))
      )
    )
  )
}
