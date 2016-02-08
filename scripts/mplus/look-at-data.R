

options(width=160)
rm(list=ls())
cat("\f")

# ---- load_packages ---------------------------------------------------------
library(dplyr)
library(magrittr) #Pipes

# ---- @knitr load_data -------------------------------------------------------
rootPath <- getwd()
filePath <- paste0(rootPath,"/data/unshared/raw/ds0.rds")
ds0 <- readRDS(filePath)
ds <- ds0
str(ds)


ds %>% dplyr::count(study)
ds <- ds %>% dplyr::filter(study == "MAP ")# keep only MAP

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
# (nl <- names.labels(ds))

# ---- load_varnames ---------------------------------------------------------
(nl <- names.labels(ds))

write.csv(nl, file="./data/unshared/derived/nl_raw.csv")
write.csv(ds, file="./data/unshared/derived/ds.csv")
# augment the names with classifications. Edit the .csv into a new version
nl_augmentedPath <- paste0(rootPath,"/data/unshared/derived/nl_augmented.csv")

varnames <- read.csv(nl_augmentedPath, stringsAsFactors = F)
varnames$X <- NULL
varnames

dplyr::arrange(varnames, type)

# ----- select_subset ------------------------------------
# select variables you will need for modeling
selected_items <- c(
  "id", # personal identifier
  "fu_year", # Follow-up year
  "age_at_visit", #Age at cycle - fractional

  "age_bl", #Age at baseline
  "htm", # Height(meters)
  "msex", # Gender
  "race", # Participant's race
  "educ", # Years of education

  "cts_bname", # Boston naming - 2014
  "cts_catflu", # Category fluency - 2014
  "cts_nccrtd", #  Number comparison - 2014

  "fev", # forced expiratory volume
  "gait_speed", # Gait Speed - MAP
  "gripavg" # Extremity strength
)

d <- ds[ , selected_items]
table(d$fu_year)

# ---- export_data -------------------------------------
# At this point we would like to export the data in .dat format
# to be fed to Mplus for any subsequent modeling


str(ds$agreeableness)
sum(ds$conscientiousness)
