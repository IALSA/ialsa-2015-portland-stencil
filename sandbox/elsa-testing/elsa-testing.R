
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
requireNamespace("tidyr") # data manipulation
requireNamespace("dplyr") # Avoid attaching dplyr, b/c its function names conflict with a lot of packages (esp base, stats, and plyr).
requireNamespace("testit")# For asserting conditions meet expected patterns.
# requireNamespace("car") # For it's `recode()` function.

# ---- declare-globals ---------------------------------------------------------
filePath <- "./data/unshared/raw/elsa/dto-esla.rds"

# ---- load-data ---------------------------------------------------------------
# load the product of 0-ellis-island.R,  a list object containing data and metadata
# ds <- read.table(filePath, col.names = variable_names)
dto <- readRDS("./data/unshared/raw/elsa/dto-elsa.rds")
names(dto)
names(dto[["unitData"]])
dplyr::glimpse(dto[["metaData"]])


# ---- inspect-data -------------------------------------------------------------

meta <- dto$metaData

meta %>%
  dplyr::filter(retain == TRUE) %>%
  dplyr::select(name, varname,label_short)


keep_variables <- meta %>%
  dplyr::filter(retain == TRUE) %>%
  dplyr::select(name) %>%
  dplyr::distinct()
(keep_variables <- as.character(keep_variables$name))


new_names <- meta %>%
  dplyr::filter(retain == TRUE) %>%
  dplyr::select(varname) %>%
  dplyr::distinct()
(new_names <- as.character(new_names$varname))


ds <- dto$unitData %>%
  dplyr::select_(.dots = keep_variables)
names(ds) <- new_names

names(ds)
# table(ds$smoke)

# ---- functions-to-examime-temporal-patterns -------------------

view_temporal_pattern <- function(ds, measure, seed_value = 42){
  set.seed(seed_value)
  ds_long <- ds
  (ids <- sample(unique(ds_long$id),1))
  d <-ds_long %>%
    dplyr::filter(id %in% ids ) %>%
    dplyr::select_("id","wave", measure)
  print(d)
}
# ds %>%  view_temporal_pattern("sex", 1)


# examine the descriptives over waves
over_waves <- function(ds, measure_name, exclude_values=""){
  testit::assert("No such measure in the dataset", measure_name %in% unique(names(ds)))
  # measure_name = "htval"; wave_name = "wave"; exclude_values = c(-99999, -1)
  cat("Measure : ", measure_name,"\n", sep="")
  t <- table( ds[,measure_name], ds[,"wave"], useNA = "always"); t[t==0] <- ".";t
  print(t)
  cat("\n")
  ds[,measure_name] <- as.numeric(ds[,measure_name])

  d <- ds[!(ds[,measure_name] %in% exclude_values), ]
  a <- lazyeval::interp(~ round(mean(var),2) , var = as.name(measure_name))
  b <- lazyeval::interp(~ round(sd(var),3),   var = as.name(measure_name))
  c <- lazyeval::interp(~ n())
  dots <- list(a,b,c)
  t <- d %>%
    dplyr::select_("id","wave", measure_name) %>%
    na.omit() %>%
    # dplyr::mutate_(measure_name = as.numeric(measure_name)) %>%
    dplyr::group_by_("wave") %>%
    dplyr::summarize_(.dots = setNames(dots, c("mean","sd","count")))
  return(as.data.frame(t))

}
# ds %>% over_waves("years")

# ---- print-temporal-patterns ----------------------------------
ds %>% view_temporal_pattern("year_born", 2)
ds %>% view_temporal_pattern("age_bl", 2)
ds %>% view_temporal_pattern("years_since_bl", 2)


# supposed to be time-invariant
ds %>% over_waves("sex") # 1, 2, 3, 4, 5, 6
ds %>% over_waves("year_born") # 1, 2, 3, 4, 5, 6
ds %>% over_waves("edu") # 1, 2, 3, 4, 5, 6
ds %>% over_waves("marital") # 1, 2, 3, 4, 5, 6


ds %>% over_waves("diabetes") # 1, 2
ds %>% over_waves("cardio") # 1, 2
ds %>% over_waves("smoke") # 1, 2, 3, 4, 5, 6
ds %>% over_waves("alcohol") # 1
ds %>% over_waves("height_cm"); # 2, 4, 6
ds %>% over_waves("weight_kg") # 2, 4, 6


# supposed to be time-variant

ds %>% over_waves("yborn") # 1, 2, 3, 4, 5, 6
ds %>% view_temporal_pattern("years_since_bl", 5)

ds %>% over_waves("word_recall_im") # 1, 2, 3, 4, 5, 6
ds %>% over_waves("word_recall_de") # 1, 2, 3, 4, 5, 6
ds %>% over_waves("animals") # 1, 2, 3, 4, 5

ds %>% over_waves("fvc_1") # 2, 4
ds %>% over_waves("fvc_2") # 2, 4
ds %>% over_waves("fvc_3") # 2, 4

ds %>% over_waves("fev_1") # 2, 4
ds %>% over_waves("fev_2") # 2, 4
ds %>% over_waves("fev_3") # 2, 4


ds %>% over_waves("pef_1") # 2, 4
ds %>% over_waves("pef_2") # 2, 4
ds %>% over_waves("pef_3") # 2, 4

ds %>% over_waves("gait") # 1, 2, 3, 4, 5, 6
ds %>% over_waves("grip") # 2, 4, 6

ds %>% over_waves("speed") # 3



# ---- make-new-variables -----------------------
year_of_baseline <- 2002

ds$fvc <- max(ds$fvc_1, ds$fvc_2, ds$fvc_3)
ds$fev <- max(ds$fev_1, ds$fev_2, ds$fev_3)
ds$pef <- max(ds$pef_1, ds$pef_2, ds$pef_3)

ds$age_at_visit <- year_of_baseline - ds$year_born + ds$years_since_bl

# ---- force-time-invariant-values -------------------

# bl_value <- as.character(ds[ds$id == id, "sex"][1])

recode_baseline <- function(ds,measure)
  for(i in unique(ds$id)){
    # i = 117781; ids = i; measure = "sex"
        d <- ds[ds$id == i, c("id","wave",measure)]
    bl_value <- as.character(d[d$wave == 1 , measure])
    measure_bl <- paste0(measure,"_bl")
    ds[,measure_bl] <- "."

    # d[d$id == i, bl_varname] <- bl_value
    ds[ds$id == i, measure_bl] <- bl_value
    # (ids <- sample(unique(ds$id),1))
    # d <- ds %>%
    #   dplyr::filter(id %in% ids ) %>%
    #   dplyr::select_("id","wave",measure, measure_bl)
    # print(d)
    # return(ds)
}
ds <- as.data.frame(ds)

ds <- recode_baseline(ds,"sex")
ds <- recode_baseline(ds,"edu")
ds <- recode_baseline(ds,"marital")
ds <- recode_baseline(ds,"diabetes")
ds <- recode_baseline(ds,"cardio")
ds <- recode_baseline(ds,"smoke")
ds <- recode_baseline(ds,"alcohol")
ds <- recode_baseline(ds,"height_cm")


ds_long <- ds
(ids <- 117781)
d <- ds_long %>%
  dplyr::filter(id %in% ids ) %>%
  dplyr::select_("id","wave","marital")
d


names(ds)

ds <- ds %>%
  dplyr::select(id, wave,
                sex, edu, marital,
                fvc, fev, pef,
                word_recall_im, word_recall_de, animals)


# ---- tweak-data --------------------------------------------------------------
ds %>% view_temporal_pattern("height_cm", 2)
ds %>% view_temporal_pattern("diabetes", 2)
ds %>% view_temporal_pattern("smoke", 7)
# ---- basic-table --------------------------------------------------------------
ds %>%
  dplyr::group_by(wave) %>%
  dplyr::summarize(count = n())


# ---- basic-graph --------------------------------------------------------------

