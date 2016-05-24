# knitr::stitch_rmd(script="./___/___.R", output="./___/___/___.md")
#These first few lines run only when the file is run in RStudio, !!NOT when an Rmd/Rnw file calls it!!
rm(list=ls(all=TRUE))  #Clear the variables from previous runs.
cat("\f") # clear console

# ---- load-sources ------------------------------------------------
# Call `base::source()` on any repo file that defines functions needed below.  Ideally, no real operations are performed.
source("./scripts/common-functions.R") # used in multiple reports
# source("./scripts/general-graphs.R")
# source("./scripts/graph-presets.R") # fonts, colors, themes
# ---- load-packages ----------------------------------------------
# Attach these packages so their functions don't need to be qualified: http://r-pkgs.had.co.nz/namespace.html#search-path
library(magrittr) #Pipes
# Verify these packages are available on the machine, but their functions need to be qualified: http://r-pkgs.had.co.nz/namespace.html#search-path
requireNamespace("ggplot2")
requireNamespace("tidyr")
requireNamespace("dplyr") #Avoid attaching dplyr, b/c its function names conflict with a lot of packages (esp base, stats, and plyr).
requireNamespace("testit") #For asserting conditions meet expected patterns.


# ---- declare-globals ---------------------------------------------------------
data_path_input <- "./data/unshared/raw/elsa/ELSA_Portland_new.sav"

# ---- load-data ---------------------------------------------------------------
ds <- Hmisc::spss.get(data_path_input, use.value.labels = TRUE)
dto <- list("unitData" = ds)

# ---- collect-meta-data -----------------------------------------
# prepare metadata to be added to the dto
# we begin by extracting the names and (hopefuly their) labels of variables from each dataset
# and combine them in a single rectanguar object, long/stacked with respect to study names
save_csv <- names_labels(ds)
write.csv(save_csv,"./data/shared/meta/elsa/names-labels-live.csv",row.names = T)

# ----- import-meta-data-dead -----------------------------------------
meta <- read.csv("./data/shared/meta/elsa/meta-data-elsa.csv", header = T, stringsAsFactors = F)
meta["X"] <- NULL # remove native counter variable, not needed
names(meta)
dto[["metaData"]] <- meta

names(dto)

lapply(dto, names)
# attach metadata object as the 4th element of the dto
dto[["metaData"]] <- meta


# ---- save-to-disk --------------------------------
saveRDS(dto, "./data/unshared/raw/elsa/dto-elsa.rds")


# ---- object-verification ------------------------------------------------
# the production of the dto object is now complete
# we verify its structure and content:
dto <- readRDS("./data/unshared/raw/elsa/dto-elsa.rds")
# each element this list is another list:
names(dto)
names(dto[["unitData"]])
dplyr::glimpse(dto[["metaData"]])


