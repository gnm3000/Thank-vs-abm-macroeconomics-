library(dplyr)

compute_divergence <- function(thank_path, abm_median_path) {
  n <- min(length(thank_path), length(abm_median_path))
  thank_path <- thank_path[seq_len(n)]
  abm_median_path <- abm_median_path[seq_len(n)]

  rmse <- sqrt(mean((thank_path - abm_median_path)^2, na.rm = TRUE))
  denom <- sd(abm_median_path, na.rm = TRUE)
  normalized <- ifelse(is.na(denom) || denom == 0, rmse, rmse / denom)

  status <- case_when(
    normalized < 0.2 ~ "green",
    normalized < 0.5 ~ "yellow",
    TRUE ~ "red"
  )

  list(rmse = rmse, normalized = normalized, status = status)
}

comparison_message <- function(status, scenario, thank_path, abm_path) {
  gap <- (mean(abm_path, na.rm = TRUE) - mean(thank_path, na.rm = TRUE)) * 100

  if (status == "green") {
    return("✅ NK assumptions hold in this scenario.")
  }

  if (status == "yellow") {
    return(sprintf("⚠️ THANK underestimates output dynamics by %.1f%% relative to ABM.", abs(gap)))
  }

  reason <- switch(
    scenario,
    financial_crisis = "the passive-financial-markets assumption breaks and credit contagion emerges",
    supply_shock = "distributional heterogeneity becomes nonlinear and THANK over-averages it",
    liquidity_trap = "rational expectations do not capture panic and endogenous demand contraction",
    "its structural assumptions break under agent nonlinearities"
  )

  sprintf("🔴 THANK fails because %s.", reason)
}
