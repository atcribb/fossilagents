# fossilagents

FossilAgents is a reusable R package for agent-based modelling of marine fossil
ecophysiotype populations through environmental change. Its initial scientific
focus is the end-Triassic extinction and the roles of habitat tracking and
physiological adaptation in explaining observed survivors.

The simulation engine is intended run based on PBDB input, or some
other dataset of spatially resolved fossil occurrences. Model agents
are local ecophysiotype populations (an ecophysiotype in a grid cell), and
initial weights derived from fossil occurrence frequencies are relative weights,
not estimates of true abundance.

## Install development dependencies

Install R, then install the suggested packages used for tests and the targets
workflow:

```r
install.packages(c("testthat", "targets"))
```

Install the package from the repository root:

```sh
R CMD INSTALL .
```

## Tests

Run the testthat suite from the repository root:

```r
testthat::test_local()
```

## Targets workflow

Run the configured targets pipeline from the repository root:

```r
targets::tar_make()
```

The initial pipeline tracks the package's R source files. Extend `_targets.R`
as model inputs and analysis steps are added.
