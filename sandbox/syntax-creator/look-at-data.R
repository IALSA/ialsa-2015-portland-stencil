# knitr::stitch_rmd(script="./manipulation/car-ellis.R", output="./manipulation/stitched-output/car-ellis.md")
#These first few lines run only when the file is run in RStudio, !!NOT when an Rmd/Rnw file calls it!!
rm(list=ls(all=TRUE))  #Clear the variables from previous runs.
cat("\f") # cleans console

# ---- load-sources ------------------------------------------------------------
# Call `base::source()` on any repo file that defines functions needed below.  Ideally, no real operations are performed.

# ---- load-packages -----------------------------------------------------------
# Attach these packages so their functions don't need to be qualified: http://r-pkgs.had.co.nz/namespace.html#search-path
library(magrittr) #Pipes

# Verify these packages are available on the machine, but their functions need to be qualified: http://r-pkgs.had.co.nz/namespace.html#search-path
requireNamespace("ggplot2")
requireNamespace("dplyr") #Avoid attaching dplyr, b/c its function names conflict with a lot of packages (esp base, stats, and plyr).
requireNamespace("testit")
requireNamespace("reshape2") # data transformations
loadNamespace("data.table") # data transformations

# ---- declare-globals ---------------------------------------------------------
# path_input  <- "./data/unshared/raw/map/ds0.rds"
path_input  <- "../MAP/data-unshared/derived/ds0.rds"
# figure_path <- 'manipulation/stitched-output/te/'

# put test assert here to check the connection.


# ---- load-data ---------------------------------------------------------------
ds <- readRDS(path_input)
str(ds)
ds %>% dplyr::count(study)
ds <- ds %>% dplyr::filter(study == "MAP ")# keep only MAP
ds %>% dplyr::count(study)

# ---- nl_function -----------------------------------------------------------
# Create function that inspects names and labels
names.labels <- function(ds){
  # ds <- dsDemo
  nl <- data.frame(matrix(NA, nrow=ncol(ds), ncol=2))
  names(nl) <- c("name","label")
  for (i in seq_along(names(ds))){
    nl[i,"name"] <- names(ds[i])
    if(is.null(attr(ds[[i]], "label")) ){
      nl[i,"label"] <- NA}else{
        nl[i,"label"] <- attr(ds[[i]], "label")
      }
  }
  return(nl)
}
# (nl <- names.labels(ds)) # usage example

# ---- load_varnames ---------------------------------------------------------
(nl <- names.labels(ds)) # nl for (n)ame and (l)ables

write.csv(nl, file="./data/unshared/derived/nl_raw.csv")
# augment the names with classifications. Directly edit the .csv
nl_augmentedPath <- "./data/unshared/derived/nl_augmented.csv"
# imported edited/augmented .csv containing a classification of variables
# varnames <- read.csv(nl_augmentedPath, stringsAsFactors = F)
# varnames$X <- NULL
# varnames
#
# dplyr::arrange(varnames, type)

# ----- select_subset ------------------------------------
# select variables you will need for modeling, be conservative
selected_items <- c(
  "id", # personal identifier
  "age_bl", #Age at baseline
  "htm", # Height(meters)
  "wtkg", # Weight (kilograms)
  "msex", # Gender
  "race", # Participant's race
  "educ", # Years of education



  # time-invariant above
  "fu_year", # Follow-up year ---###---
  # time-variant below

  "age_at_visit", #Age at cycle - fractional
  "dementia", # Dementia diagnosis

  "cts_bname", # Boston naming - 2014
  "cts_catflu", # Category fluency - 2014
  "cts_nccrtd", #  Number comparison - 2014

  "fev", # forced expiratory volume
  "gait_speed", # Gait Speed - MAP
  "gripavg" # Extremity strength
)

# ---- compute_time_difference -------------------------
d <- as.data.frame(ds[ , selected_items])
# d <- d[1:10 , c("id","age_bl", "fu_year", "age_at_visit")]
# d

d <- d %>%
  dplyr::group_by(id) %>%
  dplyr::arrange(fu_year) %>%
  dplyr::mutate(
    time_since_bl = (age_at_visit - dplyr::lag(age_at_visit, 1))
  ) %>%
  dplyr::ungroup()


set.seed(42)
random_subset <- sample(unique(d$id), size = 500)
d <- d[d$id %in% random_subset, ]

# ---- long_to_wide -----------------------------------------
# long to wide conversion might rely on the classification given to the variables with respect to time : variant or invariant
# should this classification be manual or automatic?
table(d$fu_year, useNA = "always")

d <- d[!is.na(d$fu_year),] # remove obs with NA for the follow up year

dw <- data.table::dcast(data.table::setDT(d), id + age_bl + htm + wtkg + msex + race + educ ~ fu_year, value.var = c(
  "age_at_visit", #Age at cycle - fractional
  "time_since_bl", # time elapsed since the baseline
  "dementia", # Dementia diagnosis

  "cts_bname", # Boston naming - 2014
  "cts_catflu", # Category fluency - 2014
  "cts_nccrtd", #  Number comparison - 2014

  "fev", # forced expiratory volume
  "gait_speed", # Gait Speed - MAP
  "gripavg" # Extremity strength


  ))


dw[is.na(dw)] <- -9999


# ---- export_data -------------------------------------
# At this point we would like to export the data in .dat format
# to be fed to Mplus for any subsequent modeling

write.table(d,"./sandbox/syntax-creator/outputs/grip-numbercomp/long-dataset.dat", row.names=F, col.names=F)
write(names(d), "./sandbox/syntax-creator/outputs/grip-numbercomp/long-variable-names.txt", sep=" ")

write.table(dw,"./sandbox/syntax-creator/outputs/grip-numbercomp/wide-dataset.dat", row.names=F, col.names=F)
write(names(dw), "./sandbox/syntax-creator/outputs/grip-numbercomp/wide-variable-names.txt", sep=" ")



















