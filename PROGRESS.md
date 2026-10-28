# Agent Progress

- 2026-10-28 00:00:00 UTC — Updated `R/read_environment.R` to bound oxygen, food, component, and harmonic-mean overall suitability scores to [0, 1].

- 2026-10-13 14:30:16 BST — Updated `scripts/agent_population_suitabilities.R` to catch per-cluster initialization errors, report them, and continue the loop.

- 2026-10-12 15:27:47 UTC — Updated `R/read_environment.R` to validate that required climate columns are numeric and `environment_nc_path` is a single existing filepath.

- 2026-10-12 15:24:59 UTC — Updated `R/read_environment.R` to stop with an error when `agent_state` is missing any required climate variable, regardless of column order or additional columns.

- 2026-10-05 10:32:16 UTC — Created `PROGRESS.md` with this initial entry after reading `AGENTS.md`.
- 2026-10-05 14:36:42 UTC — Updated `PROGRESS.md` to record the package, testthat, targets, and README scaffolding changes in this task.
- 2026-10-05 14:36:42 UTC — Added `DESCRIPTION` with package metadata and optional testthat/targets development dependencies.
- 2026-10-05 14:36:42 UTC — Added `NAMESPACE` for the initial package namespace.
- 2026-10-05 14:36:42 UTC — Added `R/fossilagents-package.R` as the documented package entry point.
- 2026-10-05 14:36:42 UTC — Added `tests/testthat.R` as the standard testthat test runner.
- 2026-10-05 14:36:42 UTC — Added `tests/testthat/test-package.R` with a package namespace load smoke test.
- 2026-10-05 14:36:42 UTC — Added `_targets.R` with a source-file tracking target as a minimal pipeline scaffold.
- 2026-10-05 14:36:42 UTC — Updated `README.md` with package installation, test, and targets commands.
- 2026-10-06 12:35:18 BST — Updated `R/init_population.R` to validate the total population, calculate sampling-normalised cell weights, preserve every occupied cell, and allocate an exact integer agent total using deterministic largest-remainder rounding.
- 2026-10-06 12:35:18 BST — Updated `PROGRESS.md` to record the `R/init_population.R` population-normalisation change.
- 2026-10-06 12:36:08 BST — Updated `R/init_population.R` to make invalid zero-length and nonnumeric population inputs fail cleanly before numeric validation.
- 2026-10-06 12:36:08 BST — Updated `PROGRESS.md` to record the population-validation correction in `R/init_population.R`.
- 2026-10-06 15:21:55 BST — Updated `R/init_population.R` to expand cell population counts into one row per agent, assign IDs and ecophysiotype tags, use mean within-cell palaeocoordinates, leave unresolved trait fields empty, and return the agent population.
- 2026-10-06 15:21:55 BST — Updated `PROGRESS.md` to record the agent-population table implementation in `R/init_population.R`.
