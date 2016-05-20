
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
#names(dto[["metaData"]])
dplyr::glimpse(dto[["metaData"]])


# ---- inspect-data -------------------------------------------------------------

meta <- dto$metaData
colnames(dto$unitData)
unitdata<-dto$unitData

ds0 <- dto$unitData %>%
  dplyr::select_(.dots = dto$metaData$name[!is.na(dto$metaData$retain)])


colnames(ds0) <- plyr::mapvalues(
  x      = colnames(ds0),
  from   = dto$metaData$name[!is.na(dto$metaData$retain)],
  to     = dto$metaData$varname[!is.na(dto$metaData$retain)]
)

testit::assert("`sex` should be either 'MALE', 'FEMALE', or NA.", all(is.na(ds0$sex) | (ds0$sex %in% c("MALE", "FEMALE"))))
testit::assert("`height_cm`is numeric; it's missing or positive", all(is.numeric(ds0$height_cm) | is.na(ds0$height_cm) | (ds0$height_cm >= 0)))
testit::assert("`weight_kg'is numeric; it's missing or positive", all(is.numeric(ds0$weight_kg) | is.na(ds0$weight_kg) | (ds0$weight_kg >= 0)))

testit::assert("`diabetes` should be either 1, 0, or NA.", all(is.na(ds0$diabetes) | (ds0$diabetes %in% c(0, 1))))
testit::assert("`smoke` should be either 'YES', 'NO' or NA.", all(is.na(ds0$smoke)|(ds0$smoke %in% c("YES", "NO"))))
testit::assert("`cardio` should be either 1, 0 or NA", all(is.na(ds0$cardio)|(ds0$cardio %in% c(0,1))))

ds0 %>%
  dplyr::select(id,wave,age_0, years_since_0) %>%
  dplyr::slice(1:10)

# assemple data for analysis

ds <- ds0 %>%
  dplyr::mutate(
    # design
    year_0        = 2002,
    year          = as.numeric(year_0 + years_since_0),
    age_0         = as.numeric(age_0),
    age           = as.numeric(age_0 + years_since_0),
    # covariates
    male          = as.logical(ifelse(!is.na(sex), sex=="MALE", NA_integer_)),
    diabetes      = as.logical(diabetes),
    cardio        = as.logical(ifelse(!is.na(cardio), cardio==1, NA_integer_)),
    smoke         = as.logical(ifelse(!is.na(smoke), smoke==1, NA_integer_)),
    # outcomes
    fvc           = (max(fvc_1, fvc_2, fvc_3, na.rm = T)),
    fev           = (max(fev_1, fev_2, fev_3, na.rm = T)),
    pef           = (max(pef_1, pef_2, pef_3, na.rm = T)),
    grip          = as.numeric(grip),
    gait          = as.numeric(gait)
  ) %>%
  dplyr::select(id, wave, year_0, year, age_0, age, male,
                fev, fvc, pef,
                word_recall_im, word_recall_de, animals)
head(ds)
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
# ds %>%  view_temporal_pattern("male", 1)


# examine the descriptives over waves
over_waves <- function(ds, measure_name, exclude_values="") {
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
ds %>% over_waves("year_0")

# ---- print-temporal-patterns ----------------------------------
# ds %>% view_temporal_pattern("year_born", 2)
# ds %>% view_temporal_pattern("age_bl", 2)
# ds %>% view_temporal_pattern("years_since_bl", 2)
#
#
# # supposed to be time-invariant
# ds %>% over_waves("sex") # 1, 2, 3, 4, 5, 6
# ds %>% over_waves("year_born") # 1, 2, 3, 4, 5, 6
# ds %>% over_waves("edu") # 1, 2, 3, 4, 5, 6
# ds %>% over_waves("marital") # 1, 2, 3, 4, 5, 6
#
#
# ds %>% over_waves("diabetes") # 1, 2
# ds %>% over_waves("cardio") # 1, 2
# ds %>% over_waves("smoke") # 1, 2, 3, 4, 5, 6
# ds %>% over_waves("alcohol") # 1
# ds %>% over_waves("height_cm"); # 2, 4, 6
# ds %>% over_waves("weight_kg") # 2, 4, 6
#
#
# # supposed to be time-variant
#
# ds %>% over_waves("yborn") # 1, 2, 3, 4, 5, 6
# ds %>% view_temporal_pattern("years_since_bl", 5)
#
# ds %>% over_waves("word_recall_im") # 1, 2, 3, 4, 5, 6
# ds %>% over_waves("word_recall_de") # 1, 2, 3, 4, 5, 6
# ds %>% over_waves("animals") # 1, 2, 3, 4, 5
#
# ds %>% over_waves("fvc_1") # 2, 4
# ds %>% over_waves("fvc_2") # 2, 4
# ds %>% over_waves("fvc_3") # 2, 4
#
# ds %>% over_waves("fev_1") # 2, 4
# ds %>% over_waves("fev_2") # 2, 4
# ds %>% over_waves("fev_3") # 2, 4
#
#
# ds %>% over_waves("pef_1") # 2, 4
# ds %>% over_waves("pef_2") # 2, 4
# ds %>% over_waves("pef_3") # 2, 4
#
# ds %>% over_waves("gait") # 1, 2, 3, 4, 5, 6
# ds %>% over_waves("grip") # 2, 4, 6
#
# ds %>% over_waves("speed") # 3



# ---- make-new-variables -----------------------


ds$age_at_visit <- year_of_baseline - ds$year_born + ds$years_since_bl

# ---- force-time-invariant-values -------------------

# bl_value <- as.character(ds[ds$id == id, "sex"][1])

ds <- ds %>%
  dplyr::group_by(id) %>%
  dplyr::mutate(
    diabetes_bl   = dplyr::first(diabetes) # grabs the value for the first wave and forces it to all waves
  ) %>%
  dplyr::ungroup() %>%
  dplyr::select(
    -diabetes
  )

#TODO: create baseline variables for these measures.  Follow the 'diabetes' template above.
#* sex
#* edu
#* marital
#* cardio
#* smoke
#* alcohol
#* height_cm


ds_long <- ds
(ids <- 117781)
d <- ds_long %>%
  dplyr::filter(id %in% ids ) %>%
  dplyr::select_("id","wave", "diabetes_bl")
d


names(ds)

ds2 <- ds %>%
  dplyr::select(id, wave,
                sex, edu, marital, diabetes_bl,
                fvc, fev, pef,
                word_recall_im, word_recall_de, animals)

head(ds2)

#Long to wide
ds %>%
  dplyr::select(id, wave, animals, word_recall_de ) %>%  #
  tidyr::spread_(key="wave", value=c("animals", "word_recall_de"))

# variables_static <- c("id", "sex", "edu", "marital", "diabetes_bl")
variables_static <- c("id", "diabetes_bl")
variables_longitudinal <- c(
  "smoke", "alcohol", "word_recall_im", "animals", "word_recall_de",
  "year_born", "speed", "height_cm", "weight_kg", "fvc_1", "fev_1",
  "pef_1", "fvc_2", "fev_2", "pef_2", "fvc_3", "fev_3", "pef_3",
  "age_bl", "years_since_bl", "cardio", "gait", "grip", "male",
  "fvc", "fev", "pef", "age_at_visit"
)

ds_wide <- ds %>%
  # dplyr::select(id, wave, animals, word_recall_de ) %>%
  # gather(variable, value, -(id:wave)) %>%
  dplyr::select_(.dots=c(variables_static, "wave", variables_longitudinal)) %>%
  tidyr::gather_(key="variable", value="value", variables_longitudinal) %>%
  dplyr::mutate(wave = paste0("t", wave)) %>%
  tidyr::unite(temp, variable, wave) %>%
  tidyr::spread(temp, value)

# readr::write_csv(ds_wide, path="zzzz")

# ---- tweak-data --------------------------------------------------------------
ds %>% view_temporal_pattern("height_cm", 2)
ds %>% view_temporal_pattern("diabetes", 2)
ds %>% view_temporal_pattern("smoke", 7)

# ---- basic-table --------------------------------------------------------------
ds %>%
  dplyr::group_by(wave) %>%
  dplyr::summarize(count = n())


# ---- basic-graph --------------------------------------------------------------

