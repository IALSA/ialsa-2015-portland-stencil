# knitr::stitch_rmd(script="./___/___.R", output="./___/___/___.md")
#These first few lines run only when the file is run in RStudio, !!NOT when an Rmd/Rnw file calls it!!
rm(list=ls(all=TRUE))  #Clear the variables from previous runs.
cat("\f") # clear console

# ---- load-packages -----------------------------------------------------------
# Attach these packages so their functions don't need to be qualified: http://r-pkgs.had.co.nz/namespace.html#search-path
library(magrittr) # enables piping : %>%

# ---- load-sources ------------------------------------------------------------
# Call `base::source()` on any repo file that defines functions needed below.  Ideally, no real operations are performed.
source("./scripts/common-functions.R") # used in multiple reports
source("./scripts/graph-presets.R") # fonts, colors, themes

# Verify these packages are available on the machine, but their functions need to be qualified: http://r-pkgs.had.co.nz/namespace.html#search-path
requireNamespace("ggplot2") # graphing
# requireNamespace("readr") # data input
requireNamespace("tidyr") # data manipulation
requireNamespace("dplyr") # Avoid attaching dplyr, b/c its function names conflict with a lot of packages (esp base, stats, and plyr).
requireNamespace("testit")# For asserting conditions meet expected patterns.
# requireNamespace("car") # For it's `recode()` function.

# ---- declare-globals ---------------------------------------------------------
filePath <- "./data/unshared/raw/ELSA_Portland_New_nomiss_years_variablenames.dat"
keep_vars <- c(
  "id",
  "wave",
  "htval", # height
  "sex", # sex
  "sysval", "diaval", # blood pressure?
  "mmgsd1", "mmgsd2", "mmgsd3", "mmgsn1","mmgsn2","mmgsn3", # grip
  "hesmk", # (ever smoked (1 YES, 2 - NO)
  ""
  )
# ---- load-data ---------------------------------------------------------------
# load the product of 0-ellis-island.R,  a list object containing data and metadata
# ds <- read.table(filePath, col.names = variable_names)
ds <- read.delim(filePath, header=TRUE, stringsAsFactors = FALSE)
# something is wrong with character reading, brute force
ds$id <- ds[,1]
ds[,1] <- NULL
names(ds)

# dto <- list()
# dto[["unitData"]] <- ds
# ---- collect-meta-data -----------------------------------------
# For example of using meta-data objects see :
# https://github.com/IALSA/ialsa-2016-amsterdam/blob/master/manipulation/0-ellis-island.R
# https://github.com/IALSA/ialsa-2016-amsterdam/blob/master/manipulation/map/0-ellis-island-map.R

# prepare metadata to be added to the dto
# we begin by extracting the names and (hopefuly their) labels of variables from each dataset
# and combine them in a single rectanguar object, long/stacked with respect to study names
save_csv <- names_labels(ds)
write.csv(save_csv,"./data/meta/names-labels-live.csv",row.names = T)

# ---- inspect-data -------------------------------------------------------------
names(ds)
# table(ds$smoke)

library(lazyeval)
# todo - develop into a function with NSE
over_waves <- function(ds, measure_name, exclude_values=""){
  # measure_name = "htval"; wave_name = "wave"; exclude_values = c(-99999, -1)
  cat("Measure : ", measure_name,"\n", sep="")
  d <- ds[!(ds[,measure_name] %in% exclude_values), ]
  a <- interp(~ mean(var), var = as.name(measure_name))
  b <- interp(~ sd(var),   var = as.name(measure_name))
  c <- interp(~ n())
  dots <- list(a,b,c)
  t <- d %>%
    dplyr::group_by_("wave") %>%
    dplyr::summarize_(.dots = setNames(dots, c("mean","sd","count")))
  return(as.data.frame(t))
}
# ds %>% measure_over_waves("htval", c(-99999, -1))
#
# ds %>%
#   over_waves(
#     measure_name="htval"
#     ,exclude_values = c(-99999, -1)
#   )


table(ds$hesmk)
ds %>% over_waves("hesmk",c(-9,-8,-4, -3, -2, -1))

ds %>% over_waves("sex")
ds %>% over_waves("sysval", c(-99999))
ds %>% over_waves("diaval", c(-99999))


#### get temporal pattern of repsonse for a single subject for a particular variable
set.seed(7)
ds_long <- ds
(ids <- sample(unique(ds_long$id),1))
d <-ds_long %>%
  dplyr::filter(id %in% ids ) %>%
  dplyr::select_("id","wave", "dimar")
d



# ---- tweak-data --------------------------------------------------------------

# ---- basic-table --------------------------------------------------------------

# ---- basic-graph --------------------------------------------------------------


# ---- wide-to-long-for-time -------------------------------
(time_invariant <- c("idauniq", "gender")) #make sure values in csv are correct!
(time_variant <- setdiff(names(ds), time_invariant))

#  melt with respect to the index type
ds_long <- data.table::melt(data =ds, id.vars = time_invariant,  measure.vars = time_variant)
table(ds_long$variable)





# ---- reproduce ---------------------------------------
rmarkdown::render(input = "./sandbox/report-a.Rmd" ,
                  output_format="html_document", clean=TRUE)
