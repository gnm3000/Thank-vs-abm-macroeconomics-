# THANK vs ABM Macroeconomics Simulator

Aplicación **R Shiny** para comparar trayectorias macro entre un modelo THANK simplificado y un ABM con heterogeneidad de agentes.

## Estructura

- `app/app.R`: entrypoint de Shiny.
- `app/ui.R`: layout con sidebar de parámetros y tabs THANK/ABM/COMPARACIÓN.
- `app/server.R`: simulación reactiva, gráficos y semáforo de convergencia.
- `app/modules/`: motores THANK y ABM + lógica de comparación.
- `app/scenarios/`: 4 escenarios YAML.

## Ejecutar

```r
install.packages(c("shiny", "bslib", "plotly", "igraph", "dplyr", "tidyr", "purrr", "yaml", "viridis"))
shiny::runApp("app")
```

## Escenarios

1. `fiscal_transfer`: convergencia esperada.
2. `financial_crisis`: divergencia por contagio financiero.
3. `supply_shock`: divergencia fuerte por heterogeneidad distributiva.
4. `liquidity_trap`: falla de THANK en régimen de pánico con ZLB.
