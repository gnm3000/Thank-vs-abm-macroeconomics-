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
    return("✅ Los supuestos NK se sostienen en este escenario.")
  }

  if (status == "yellow") {
    return(sprintf("⚠️ THANK subestima la dinámica de output en %.1f%% respecto al ABM.", abs(gap)))
  }

  reason <- switch(
    scenario,
    financial_crisis = "se rompe el supuesto de mercados financieros pasivos y aparece contagio de crédito",
    supply_shock = "la heterogeneidad distributiva se vuelve no lineal y THANK la promedia en exceso",
    liquidity_trap = "las expectativas racionales no capturan el pánico y la contracción endógena de demanda",
    "sus supuestos estructurales se rompen bajo no linealidades de agentes"
  )

  sprintf("🔴 THANK falla porque %s.", reason)
}
