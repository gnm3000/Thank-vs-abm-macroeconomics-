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
        "Select scenario",
        choices = c(
          "Fiscal Transfer" = "fiscal_transfer",
          "Financial Crisis" = "financial_crisis",
          "Supply Shock" = "supply_shock",
          "Liquidity Trap" = "liquidity_trap"
        )
      ),
      h5("THANK Parameters"),
      sliderInput("lambda", "Hand-to-mouth share (lambda)", min = 0.05, max = 0.8, value = 0.35, step = 0.01),
      sliderInput("iMPC_poor", "iMPC poor", min = 0.3, max = 1, value = 0.8, step = 0.01),
      sliderInput("iMPC_rich", "iMPC rich", min = 0, max = 0.2, value = 0.05, step = 0.005),
      sliderInput("transfer", "Transfer (% GDP)", min = 0, max = 8, value = 3, step = 0.1),
      sliderInput("phi_pi", "Taylor rule φπ", min = 0.5, max = 2.5, value = 1.5, step = 0.05),
      sliderInput("phi_y", "Taylor rule φy", min = 0, max = 0.5, value = 0.125, step = 0.01),
      sliderInput("rho_shock", "Shock persistence", min = 0.1, max = 0.95, value = 0.7, step = 0.05),
      h5("ABM Parameters"),
      sliderInput("N_households", "Households", min = 200, max = 2000, value = 500, step = 50),
      sliderInput("N_firms", "Firms", min = 20, max = 200, value = 100, step = 10),
      sliderInput("N_banks", "Banks", min = 5, max = 30, value = 10, step = 1),
      sliderInput("markup_mean", "Average markup", min = 0.05, max = 0.4, value = 0.15, step = 0.01),
      sliderInput("credit_multiplier", "Bank leverage", min = 2, max = 15, value = 8, step = 1),
      sliderInput("abm_T", "ABM horizon (quarters)", min = 20, max = 120, value = 80, step = 5),
      sliderInput("mc_runs", "Monte Carlo runs", min = 20, max = 300, value = 200, step = 10),
      actionButton("run_sim", "Run simulation", class = "btn-primary")
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
        "COMPARISON",
        plotlyOutput("comparison_overlay", height = "350px"),
        verbatimTextOutput("divergence_metrics"),
        uiOutput("traffic_light_ui"),
        div(class = "comparison-text", textOutput("comparison_text"))
      )
    )
  )
}
