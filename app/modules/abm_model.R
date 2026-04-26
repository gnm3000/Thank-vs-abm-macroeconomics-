library(dplyr)
library(tidyr)
library(purrr)
library(igraph)

calc_gini <- function(x) {
  x <- sort(as.numeric(x))
  n <- length(x)
  if (n == 0 || sum(x) == 0) return(0)
  (2 * sum(x * seq_len(n)) / (n * sum(x))) - (n + 1) / n
}

abm_single_run <- function(
  N_households,
  N_firms,
  N_banks,
  markup_mean,
  credit_multiplier,
  scenario,
  T
) {
  wealth <- 1 / (runif(N_households)^1.5)
  wealth <- wealth / mean(wealth)

  employment <- rep(0.94, T)
  output <- rep(0, T)
  inflation <- rep(0.02, T)
  income_gini <- rep(0, T)
  consumption_gini <- rep(0, T)

  contagion_edges <- tibble(from = integer(), to = integer(), weight = numeric())

  income <- wealth * runif(N_households, 0.7, 1.3)
  consumption <- income * runif(N_households, 0.75, 0.95)

  for (tt in 2:T) {
    demand_signal <- mean(consumption) / mean(income)
    credit_supply <- pmax(0.2, rnorm(1, mean = credit_multiplier / 10, sd = 0.1))

    scenario_drag <- switch(
      scenario,
      fiscal_transfer = 0,
      financial_crisis = ifelse(tt > 6, -0.035 * exp(-(tt - 6) / 12), 0),
      supply_shock = ifelse(tt <= 14, -0.02, -0.005),
      liquidity_trap = ifelse(tt > 4, -0.03, 0),
      0
    )

    if (scenario == "fiscal_transfer" && tt <= 5) {
      transfer_boost <- quantile(wealth, 0.35)
      poor_idx <- which(wealth <= transfer_boost)
      income[poor_idx] <- income[poor_idx] + 0.12
    }

    panic <- if (scenario == "liquidity_trap" && tt > 5) runif(1, 0.05, 0.15) else 0
    output[tt] <- 0.55 * output[tt - 1] + 0.5 * (demand_signal - 0.8) + 0.15 * credit_supply + scenario_drag - panic

    unemployment_shock <- pmax(0, -output[tt] * runif(1, 0.15, 0.35))
    employment[tt] <- pmax(0.65, pmin(0.98, employment[tt - 1] - unemployment_shock + runif(1, -0.01, 0.01)))

    inflation[tt] <- 0.6 * inflation[tt - 1] + 0.3 * output[tt] + ifelse(scenario == "supply_shock", 0.01, 0)

    income <- pmax(0.01, income * (1 + output[tt] + rnorm(N_households, 0, 0.02)))
    consumption_prop <- pmin(1.1, pmax(0.5, 0.65 + 0.25 * (income / (wealth + 1)) + rnorm(N_households, 0, 0.04) - panic))
    consumption <- pmax(0.01, income * consumption_prop)

    income_gini[tt] <- calc_gini(income)
    consumption_gini[tt] <- calc_gini(consumption)

    if (scenario == "financial_crisis" && tt %in% 5:20) {
      troubled <- sample(seq_len(N_banks), size = sample(2:4, 1), replace = FALSE)
      counterparties <- sample(seq_len(N_banks), size = length(troubled), replace = TRUE)
      contagion_edges <- bind_rows(
        contagion_edges,
        tibble(from = troubled, to = counterparties, weight = runif(length(troubled), 0.2, 1))
      )
    }
  }

  deciles <- ntile(wealth, 10)
  baseline_consumption <- wealth * 0.8
  gain_loss <- tapply(consumption - baseline_consumption, deciles, mean)

  list(
    macro = tibble(t = seq_len(T), output = output, inflation = inflation, employment = employment,
                   income_gini = income_gini, consumption_gini = consumption_gini),
    gain_loss = tibble(decile = seq_len(10), value = as.numeric(gain_loss)),
    contagion = contagion_edges
  )
}

abm_simulate <- function(
  N_households = 500,
  N_firms = 100,
  N_banks = 10,
  wealth_gini = 0.45,
  markup_mean = 0.15,
  credit_multiplier = 8,
  scenario = "fiscal_transfer",
  T = 80,
  MC_runs = 200
) {
  set.seed(123)

  runs <- map(seq_len(MC_runs), ~abm_single_run(
    N_households = N_households,
    N_firms = N_firms,
    N_banks = N_banks,
    markup_mean = markup_mean,
    credit_multiplier = credit_multiplier,
    scenario = scenario,
    T = T
  ))

  macro_all <- map2_dfr(runs, seq_len(MC_runs), ~.x$macro %>% mutate(run = .y))

  percentiles <- macro_all %>%
    group_by(t) %>%
    summarize(
      p10 = quantile(output, 0.1),
      p25 = quantile(output, 0.25),
      p50 = quantile(output, 0.5),
      p75 = quantile(output, 0.75),
      p90 = quantile(output, 0.9),
      .groups = "drop"
    )

  gini_series <- macro_all %>%
    group_by(t) %>%
    summarize(
      income_gini = median(income_gini),
      consumption_gini = median(consumption_gini),
      .groups = "drop"
    )

  gain_loss <- map_dfr(runs, "gain_loss", .id = "run") %>%
    group_by(decile) %>%
    summarize(value = median(value), .groups = "drop")

  all_edges <- map_dfr(runs, "contagion")
  network <- if (nrow(all_edges) > 0) {
    graph_from_data_frame(all_edges, directed = TRUE)
  } else {
    make_empty_graph(n = N_banks)
  }

  list(
    fan_chart = percentiles,
    gini = gini_series,
    gain_loss = gain_loss,
    contagion_graph = network
  )
}
