targets::tar_option_set(packages = "fossilagents")

list(
  targets::tar_target(
    package_sources,
    list.files("R", pattern = "\\.R$", full.names = TRUE)
  )
)
