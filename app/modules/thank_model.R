library(dplyr)

# THANK (simplified HANK-style linearized simulator)
thank_simulate <- function(
  lambda = 0.35,
  iMPC_poor = 0.8,
  iMPC_rich = 0.05,
  transfer = 3,
  phi_pi = 1.5,
  phi_y = 0.125,
  rho_shock = 0.7,
  scenario = "fiscal_transfer",
  T = 20
) {
  t <- seq_len(T)

  sigma_hat <- 1 / (lambda * iMPC_poor + (1 - lambda) * iMPC_rich + 1e-6)
  chi <- lambda * iMPC_poor + (1 - lambda) * iMPC_rich

  # Scenario-specific exogenous shock paths
  shock <- rep(0, T)
  supply <- rep(0, T)

  shock[1] <- transfer / 100

  if (scenario == "financial_crisis") {
    shock[1:4] <- -0.02 * rho_shock^(0:3)
  } else if (scenario == "supply_shock") {
    supply[1:6] <- 0.03 * rho_shock^(0:5)
    shock[1:4] <- -0.01 * rho_shock^(0:3)
  } else if (scenario == "liquidity_trap") {
    shock[1:8] <- -0.015 * rho_shock^(0:7)
    supply[1:8] <- -0.01 * rho_shock^(0:7)
  }

  x <- rep(0, T)
  pi <- rep(0, T)
  i_rate <- rep(0, T)
  c_poor <- rep(0, T)
  c_rich <- rep(0, T)

  # Backward-looking approximation to keep app tractable
  for (k in 2:T) {
    i_rate[k - 1] <- pmax(0, phi_pi * pi[k - 1] + phi_y * x[k - 1])

    real_rate_gap <- i_rate[k - 1] - pi[k - 1]
    x[k] <- 0.55 * x[k - 1] - (1 / sigma_hat) * real_rate_gap + chi * shock[k - 1] + shock[k - 1]
    pi[k] <- 0.65 * pi[k - 1] + 0.25 * x[k - 1] + supply[k - 1]

    c_poor[k] <- c_poor[k - 1] + iMPC_poor * (0.8 * shock[k - 1] + 0.4 * x[k])
    c_rich[k] <- c_rich[k - 1] + iMPC_rich * (0.5 * shock[k - 1] + 0.4 * x[k])

    if (scenario == "liquidity_trap") {
      # THANK fails to capture panic; still mechanically bounded
      x[k] <- x[k] * 0.75
      pi[k] <- pi[k] * 0.8
    }
  }

  i_rate[T] <- pmax(0, phi_pi * pi[T] + phi_y * x[T])

  cum_output <- cumsum(x)
  horizons <- c(1, 4, 8, 12)
  horizons <- horizons[horizons <= T]
  multiplier <- if (abs(transfer) < 1e-8) {
    rep(NA_real_, length(horizons))
  } else {
    cum_output[horizons] / (transfer / 100)
  }

  multipliers <- tibble(
    horizon = horizons,
    fiscal_multiplier = as.numeric(multiplier)
  )

  irf <- tibble(
    t = t,
    output_gap = x,
    inflation = pi,
    interest_rate = i_rate,
    cons_poor = c_poor,
    cons_rich = c_rich
  )

  consumption_distribution <- tibble(
    group = c("Poor (HtM)", "Rich"),
    average_consumption_response = c(mean(c_poor), mean(c_rich))
  )

  list(
    irf = irf,
    multipliers = multipliers,
    consumption_distribution = consumption_distribution
  )
}
