library(yaml)

load_scenario <- function(name, scenarios_dir = "app/scenarios") {
  path <- file.path(scenarios_dir, paste0(name, ".yaml"))
  if (!file.exists(path)) {
    stop(sprintf("Scenario file not found: %s", path))
  }
  yaml::read_yaml(path)
}

available_scenarios <- function(scenarios_dir = "app/scenarios") {
  files <- list.files(scenarios_dir, pattern = "\\.yaml$", full.names = FALSE)
  sub("\\.yaml$", "", files)
}
