library(shiny)
library(plotly)
library(dplyr)
library(tidyr)
library(igraph)
library(viridis)

source("modules/thank_model.R")
source("modules/abm_model.R")
source("modules/comparison.R")
source("modules/scenario_loader.R")

app_server <- function(input, output, session) {
  simulations <- eventReactive(input$run_sim, {
    req(
      !is.null(input$run_sim),
      !is.null(input$lambda),
      !is.null(input$iMPC_poor),
      !is.null(input$iMPC_rich),
      !is.null(input$transfer),
      !is.null(input$phi_pi),
      !is.null(input$phi_y),
      !is.null(input$rho_shock),
      !is.null(input$scenario),
      !is.null(input$N_households),
      !is.null(input$N_firms),
      !is.null(input$N_banks),
      !is.null(input$markup_mean),
      !is.null(input$credit_multiplier),
      !is.null(input$abm_T),
      !is.null(input$mc_runs)
    )

    thank <- thank_simulate(
      lambda = input$lambda,
      iMPC_poor = input$iMPC_poor,
      iMPC_rich = input$iMPC_rich,
      transfer = input$transfer,
      phi_pi = input$phi_pi,
      phi_y = input$phi_y,
      rho_shock = input$rho_shock,
      scenario = input$scenario,
      T = 20
    )

    abm <- abm_simulate(
      N_households = input$N_households,
      N_firms = input$N_firms,
      N_banks = input$N_banks,
      markup_mean = input$markup_mean,
      credit_multiplier = input$credit_multiplier,
      scenario = input$scenario,
      T = input$abm_T,
      MC_runs = input$mc_runs
    )

    div <- compute_divergence(thank$irf$output_gap, abm$fan_chart$p50)

    list(thank = thank, abm = abm, divergence = div)
  }, ignoreInit = FALSE)

  output$thank_irf_plot <- renderPlotly({
    sim <- simulations()
    df <- sim$thank$irf %>%
      select(t, output_gap, inflation, interest_rate) %>%
      pivot_longer(-t, names_to = "series", values_to = "value")

    plot_ly(df, x = ~t, y = ~value, color = ~series, type = "scatter", mode = "lines") %>%
      layout(title = "IRF THANK", xaxis = list(title = "Quarter"), yaxis = list(title = "Response"))
  })

  output$thank_multipliers <- renderTable({
    simulations()$thank$multipliers
  }, digits = 3)

  output$thank_consumption_plot <- renderPlotly({
    df <- simulations()$thank$consumption_distribution
    plot_ly(df, x = ~group, y = ~average_consumption_response, type = "bar", color = ~group) %>%
      layout(title = "Average consumption by type")
  })

  output$abm_fan_chart <- renderPlotly({
    df <- simulations()$abm$fan_chart

    plot_ly(df, x = ~t) %>%
      add_ribbons(ymin = ~p10, ymax = ~p90, name = "P10-P90", fillcolor = "rgba(76, 201, 240, 0.15)", line = list(color = "transparent")) %>%
      add_ribbons(ymin = ~p25, ymax = ~p75, name = "P25-P75", fillcolor = "rgba(72, 149, 239, 0.25)", line = list(color = "transparent")) %>%
      add_lines(y = ~p50, name = "P50 (median)", line = list(color = "#f72585", width = 3)) %>%
      layout(title = "ABM Fan Chart (Output)", yaxis = list(title = "Output"), xaxis = list(title = "Quarter"))
  })

  output$abm_gini_plot <- renderPlotly({
    df <- simulations()$abm$gini %>%
      pivot_longer(cols = c(income_gini, consumption_gini), names_to = "series", values_to = "value")

    plot_ly(df, x = ~t, y = ~value, color = ~series, type = "scatter", mode = "lines") %>%
      layout(title = "Gini evolution", yaxis = list(title = "Gini"), xaxis = list(title = "Quarter"))
  })

  output$abm_contagion_plot <- renderPlot({
    sim <- simulations()
    if (input$scenario != "financial_crisis") {
      plot.new()
      text(0.5, 0.5, "Contagion network available only in Financial Crisis", cex = 1)
      return(invisible(NULL))
    }

    g <- sim$abm$contagion_graph
    if (ecount(g) == 0) {
      plot.new()
      text(0.5, 0.5, "No contagion links detected", cex = 1)
      return(invisible(NULL))
    }
    plot(g, vertex.size = 20, vertex.color = "tomato", edge.arrow.size = 0.3)
  })

  output$abm_heatmap <- renderPlotly({
    df <- simulations()$abm$gain_loss
    plot_ly(
      x = ~df$decile,
      y = ~1,
      z = matrix(df$value, nrow = 1),
      type = "heatmap",
      colorscale = "RdBu",
      reversescale = TRUE
    ) %>%
      layout(title = "Heatmap: winners/losers by decile", yaxis = list(showticklabels = FALSE), xaxis = list(title = "Decile"))
  })

  output$comparison_overlay <- renderPlotly({
    sim <- simulations()
    thank <- sim$thank$irf
    abm <- sim$abm$fan_chart

    n <- min(nrow(thank), nrow(abm))
    thank <- thank[seq_len(n), ]
    abm <- abm[seq_len(n), ]

    plot_ly(abm, x = ~t) %>%
      add_ribbons(ymin = ~p25, ymax = ~p75, name = "ABM P25-P75", fillcolor = "rgba(58, 134, 255, 0.2)", line = list(color = "transparent")) %>%
      add_lines(y = ~p50, name = "ABM P50", line = list(color = "#3a86ff", width = 2)) %>%
      add_lines(data = thank, y = ~output_gap, name = "THANK", line = list(color = "#ff006e", width = 3)) %>%
      layout(title = "Trajectory comparison (Output)")
  })

  output$divergence_metrics <- renderPrint({
    div <- simulations()$divergence
    cat(sprintf("RMSE: %.4f\n", div$rmse))
    cat(sprintf("Normalized index: %.4f\n", div$normalized))
  })

  output$traffic_light_ui <- renderUI({
    div <- simulations()$divergence

    color <- switch(div$status, green = "#38b000", yellow = "#ffbe0b", red = "#e63946")
    label <- switch(div$status, green = "GREEN: converging", yellow = "YELLOW: partial divergence", red = "RED: diverging")

    tags$div(
      style = sprintf("display:flex;align-items:center;gap:12px;margin:12px 0;"),
      tags$div(style = sprintf("width:20px;height:20px;border-radius:50%%;background:%s;", color)),
      tags$strong(label)
    )
  })

  output$comparison_text <- renderText({
    sim <- simulations()
    comparison_message(
      sim$divergence$status,
      input$scenario,
      sim$thank$irf$output_gap,
      sim$abm$fan_chart$p50
    )
  })
}
