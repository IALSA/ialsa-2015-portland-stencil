

options(width=160)
rm(list=ls())
cat("\f")

# ---- load_packages ---------------------------------------------------------
library(dplyr)
library(magrittr) #Pipes

# ---- preceding_scripts ------------------------------------------------------
# source("./scripts/data/0-import-raw.R")

# ---- @knitr load_data -------------------------------------------------------
ds0 <- readRDS("./data/unshared/raw/map/ds0.rds")
ds <- ds0
str(ds)


ds %>% dplyr::count(study)

# todo: change factors to characters in the initial MAP configuration
# keep only MAP
ds <- ds %>% dplyr::filter(study == "MAP")

d <- ds[]
