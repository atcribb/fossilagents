# Project
Build a reusable R package for agent-based modelling of marine fossil ecophysiotypes through environmental change, initially the end-Triassic extinction. However, users should eventually be able to apply this to any time period given they have an environmental state and fossil occurrences with relevant ecophysiotype traits.

## Science
Goal: infer which strategies—migration/habitat tracking and physiological adaptation—best explain observed survivors.

Inputs:
- PBDB genus occurrences + palaeocoordinates
- Ecospace traits: tiering, motility, feeding
- Ecophysiotype assignments
- cGENIE grids: temperature, oxygen, pH, omega, Corg/productivity, phosphorus
- Rhaetian start, Hettangian endpoint; intermediate states initially interpolated

Agents are **local ecophysiotype populations** (`ecophysiotype × grid cell`), not individuals.

Initial population weights come from relative PBDB occurrence frequencies and are not true abundance estimates.

Adaptable traits initially:
- temperature preference/tolerance
- oxygen tolerance

Food/resource requirements remain fixed initially.

## Package design
Users should be able to:
1. create/import environments
2. define ecophysiotypes/populations
3. initialise at `t=0`
4. run environmental change
5. choose interchangeable response policies
6. record population, range, adaptation, and extinction outcomes

Policies should support:
- no response
- migration
- adaptation
- migration + adaptation
- future RL policy

Rinforcement Learning is **out of scope for the initial prototype**, but architecture must support it later.

## Principles
- Keep simulation engine dataset-independent
- Prefer modular/testable R functions
- Prefer data.frame/data.table state over complex mutable objects
- Ensure deterministic reproducibility
- Write unit tests
- Optimise only after profiling

Validation: compare predicted survival and geographic distributions with empirical Hettangian fossil data. Primary scientific target is inferred survival strategy.

# Repository Guidelines

## Project Structure & Module Organization

This repository is an early-stage scaffold for FossilAgents, a project on agent-based ecological dynamics using fossil occurrence data. The root currently contains `README.md`, which introduces the project, and `LICENSE`. There are no source, test, or asset directories yet. As implementation is added, keep application code in a clearly named source directory (for example, `src/`), tests in a parallel `tests/` directory, and data or visual assets in dedicated directories. Avoid committing large or sensitive datasets; document retrieval and provenance instead.

## Build, Test, and Development Commands

No build system or development commands are configured yet. When adding a language or framework, provide a reproducible setup and document its commands here and in `README.md`. Use project-local tooling and dependency lockfiles where the ecosystem supports them. Before proposing a change, run the relevant formatter, linter, and tests once those are available.

## Coding Style & Naming Conventions

# Coding style
Write clear, explicit R; optimise for readability over terseness. Do not use dplyr, %>%, or |>. Prefer base R for simple operations and data.frame where performance or grouped operations justify it. Avoid non-standard evaluation where possible. Explicit for loops are acceptable when clearer than vectorised alternatives. Avoid deeply nested code. Prioritise extracting reusable logic into function where possible. Functions should be pure, usually do one thing, and return a predictable object. Functions should also have defensive tests and prefer early validation/errors over fixing a bad input. Do not add dependencies unless specified, or when base R or an existing dependency is sufficient. Use explicit namespaces for less-common package functions, e.g. palaeoverse::palaeorotate(). Set seed 201 for stochastic code. Avoid hidden global state and side effects. Use NA over NA_Character_, etc.

# Naming
Use snake_case throughout. Lowercase variables. Functions sohuld be verbs or verb phrases and not conflict with other base R functions or dependency functions. Objects/data are descriptive nouns. Counts start with n_ . Identifiers have a suffix _id. indices are short names i, j, k. Avoid cryptic abberviations unless standard in the domain (e.g., temp, o2, pH are fine). Use consistent scientific terminology across code, documentation, and outsputs.

# Figures
Use ggplot2 for all publication-quality figures with theme_bw(). Do not use base R for plotting final figures. Build plots explicitly rather than through wrapper packages. Use informative axis labels including units. Do not give plot titles. Figures should be clean and publication-ready for a variety of journals. Avoid unncesary legends, colours, facets, or annotations. Colour palettes should be colourblind-friendly. Return ggplot objects from plotting functions rather than printing or saving them internally unless explicitly requested.

# Comments and documentation
Comments should explain what lines of the script are doing. Also include why, assumptions, or scientific reasoning where relevant. Document exported functions with roxygen2. Include units, parameter meaning, return type, and important biological assumptions. Mark unresolved scientific decisions with TODO comments rather than silently choosing assumptions. Avoid excessive comments in straightforward code, but a user with limited experience should be able to follow along.

# Tests and workflows
Use testthat and targets. Test biological/model behavior, not only implementation. Tests should be designed to actually test function behavior, not force the tests to pass. Include edge cases such as zeros, invalid inputs, unsuitable habitats, local extinctions, no available dispersal cells, and other extreme phenomena where relevant. Use small deterministic fixtures where possible. Tests involving randomness must set seed 201.

## Testing Guidelines

No testing framework or coverage target is configured. Add tests alongside each feature, using the selected framework's standard test discovery and naming patterns. Prioritize checks for data validation, time or trait calculations, and deterministic model behavior. Document a single command contributors can use to run the complete suite.

## Commit & Pull Request Guidelines

The available history has only two short commits and does not establish a formal commit convention. Write concise, imperative commit subjects that explain the change (for example, `Add occurrence parsing`). Pull requests should summarize the motivation and implementation, note validation performed, link related issues when applicable, and include figures or screenshots when outputs have a visual component.

## Data & Configuration

Keep credentials and machine-specific settings out of version control. Document required configuration with safe example values. For datasets, include source, license, preprocessing steps, and version or retrieval date so analyses can be reproduced.

## Agent restrictions

Operate with a **human-in-the-loop workflow**. Make only the changes needed for the current task and leave broader decisions to the user.

- Do not add, stage, commit, amend, merge, rebase, tag, or push with `git`.
- Do not change branches or modify repository history.
- Do not create or modify remote repositories, issues, pull requests, or releases.
- You may inspect `git diff`, `git status`, and file history when useful, but repository changes remain uncommitted for human review.
- Do not modify files that are not `.R` scripts unless the user explicitly gives permission for that file or file type.
- In particular, do not alter documentation, configuration, metadata, dependency files, tests, workflows, `.gitignore`, `DESCRIPTION`, `NAMESPACE`, or `AGENTS.md` without explicit permission.
- Do not create new non-`.R` files without explicit permission.
- Do not delete, rename, or move files without explicit permission.
- Do not make unrelated refactors or formatting changes while completing another task.
- If a requested change appears to require modifying a restricted file, explain why and ask for permission rather than modifying it.
- Treat the repository root as the complete accessible workspace.
- Do not read, inspect, search, write, or execute files outside the repository.
- Do not access user home directories, system configuration, credentials, environment secrets, unrelated repositories, or external local files.
- Do not make network calls, upload repository content, or send code/data to external services unless explicitly authorised.
- Before substantial or scientifically consequential changes, present the intended approach for human review.
- When assumptions are scientifically meaningful or ambiguous, surface them rather than silently deciding.
- After edits, summarise which files changed, what changed, and any decisions that still require human review.

## Monitoring agent progress
Keep a PROGRESS.md log that timestamps every single change made by the agent. In no scenario should a change be made without updating the PROGRESS.md log to explain the change. Changes should be concise in description and make explicit reference to the file changed.
