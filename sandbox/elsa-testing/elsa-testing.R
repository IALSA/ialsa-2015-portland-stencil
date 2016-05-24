
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
  dplyr::select(id,wave,age_bl, years_since_bl) %>%
  dplyr::slice(1:10)


# compute pulmonary variables (max of the three)
for(i in 1:nrow(ds0)){
  ds0[i,"fev"] <- max( ds0[i,"fev_1"], ds0[i, "fev_2"], ds0[i, "fev_3"])
  ds0[i,"fvc"] <- max( ds0[i,"fvc_1"], ds0[i, "fvc_2"], ds0[i, "fvc_3"])
  ds0[i,"pef"] <- max( ds0[i,"pef_1"], ds0[i, "pef_2"], ds0[i, "pef_3"])
}

# assemple data for analysis
ds <- ds0 %>%
  dplyr::mutate(
    # design
    year_bl        = 2002, # year of the first wave
    year          = as.numeric(year_bl + years_since_bl),
    age_bl         = as.numeric(age_bl),
    age           = as.numeric(age_bl + years_since_bl),
    year_born     = as.numeric(year_born),
    # covariates
    male          = as.logical(ifelse(!is.na(sex), sex=="MALE", NA_integer_)),
    diabetes      = as.logical(diabetes),
    cardio        = as.logical(ifelse(!is.na(cardio), cardio==1, NA_integer_)),
    smoke         = as.logical(ifelse(!is.na(smoke), smoke==1, NA_integer_)),
    # outcomes
    fvc           = as.numeric(fev),
    fev           = as.numeric(fvc),
    pef           = as.numeric(pef/100), # change the scale to make more comparable
    grip          = as.numeric(grip),
    gait          = as.numeric(gait)
  ) %>%
  dplyr::select(id, wave, male, year_bl, year, age_bl, year_born,
                age, edu, height_cm, diabetes, cardio, smoke,
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
# ds %>%  view_temporal_pattern("male", 2)

# examine the descriptives over waves
over_waves <- function(ds, measure_name, exclude_values="") {
  ds <- as.data.frame(ds)
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
# ds %>% over_waves("year_bl")
# ---- examine-temporal-patterns ----------------------------------

ds %>% view_temporal_pattern("year_bl", 2) # year at baseline
ds %>% view_temporal_pattern("year", 2) # year of measurement
ds %>% view_temporal_pattern("year_born", 2) # year at baseline

ds %>% view_temporal_pattern("age_bl", 2) # age at baseline
ds %>% view_temporal_pattern("age", 2) # age at measurement


# ---- force-to-static-sex ---------------------------
ds %>% view_temporal_pattern("male", 2) # sex
ds %>% over_waves("male") # 1, 2, 3, 4, 5, 6
# check that values are the same across waves
ds %>%
  dplyr::group_by(id) %>%
  dplyr::summarize(unique = length(unique(male))) %>%
  dplyr::arrange(desc(unique)) # unique > 1 indicates change over wave
# grab the value for the first wave and forces it to all waves
ds <- ds %>%
  dplyr::group_by(id) %>%
  dplyr::mutate(
    male_bl   = dplyr::first(male) # grabs the value for the first wave and forces it to all waves
  ) %>%
  dplyr::ungroup()
# examine the difference
ds %>% over_waves("male_bl")
ds %>% view_temporal_pattern("male_bl", 2) # sex

# ds_long <- ds
# (ids <- 117781)
# d <- ds_long %>%
#   dplyr::filter(id %in% ids ) %>%
#   dplyr::select_("id","wave", "male", "male_bl")
# d



# ---- force-to-static-education ---------------------------
ds %>% view_temporal_pattern("edu", 2) # sex
ds %>% over_waves("edu") # 1, 2, 3, 4, 5, 6
# check that values are the same across waves
ds %>%
  dplyr::group_by(id) %>%
  dplyr::summarize(unique = length(unique(edu))) %>%
  dplyr::arrange(desc(unique)) # unique > 1 indicates change over wave
# edu is truely time-invariant
ds <- ds %>% dplyr::mutate( edu_bl = edu)
ds %>% over_waves("edu_bl")

# ---- force-to-static-height ---------------------------
ds %>% view_temporal_pattern("height_cm", 2)
ds %>% over_waves("height_cm"); # 2, 4, 6
# check that values are the same across waves
ds %>%
  dplyr::group_by(id) %>%
  dplyr::summarize(unique = length(unique(height_cm))) %>%
  dplyr::arrange(desc(unique)) # unique > 1 indicates change over wave
# grab the value for the first wave and forces it to all waves
ds <- ds %>%
  dplyr::group_by(id) %>%
  # height is not available at wave 1, take value from wave 2
  dplyr::mutate(
    height_cm_bl   = median(height_cm, na.rm =T) # grabs the value for the first wave and forces it to all waves
  ) %>%
  dplyr::ungroup()
# examine the difference
# ds %>% over_waves("height_cm_bl")
ds %>% view_temporal_pattern("height_cm_bl", 2)


# ---- force-to-static-diabetes ---------------------------
ds %>% view_temporal_pattern("diabetes", 2)
ds %>% over_waves("diabetes") # 1, 2
# check that values are the same across waves
ds %>%
  dplyr::group_by(id) %>%
  dplyr::summarize(unique = length(unique(diabetes))) %>%
  dplyr::arrange(desc(unique)) # unique > 1 indicates change over wave
# grab the value for the first wave and forces it to all waves
ds <- ds %>%
  dplyr::group_by(id) %>%
  dplyr::mutate(
    diabetes_bl   = dplyr::first(diabetes) # grabs the value for the first wave and forces it to all waves
  ) %>%
  dplyr::ungroup()
# examine the difference
ds %>% over_waves("diabetes_bl")


# ---- force-to-static-cardio ---------------------------
ds %>% view_temporal_pattern("cardio", 2)
ds %>% over_waves("cardio") # 1, 2
# check that values are the same across waves
ds %>%
  dplyr::group_by(id) %>%
  dplyr::summarize(unique = length(unique(cardio))) %>%
  dplyr::arrange(desc(unique)) # unique > 1 indicates change over wave
# grab the value for the first wave and forces it to all waves
ds <- ds %>%
  dplyr::group_by(id) %>%
  dplyr::mutate(
    cardio_bl   = dplyr::first(cardio) # grabs the value for the first wave and forces it to all waves
  ) %>%
  dplyr::ungroup()
# examine the difference
ds %>% over_waves("cardio_bl")
ds %>% view_temporal_pattern("cardio_bl", 2)

# ---- force-to-static-smoke ---------------------------
ds %>% view_temporal_pattern("smoke", 2)
ds %>% over_waves("smoke") # 1, 2, 3, 4, 5, 6
# check that values are the same across waves
ds %>%
  dplyr::group_by(id) %>%
  dplyr::summarize(unique = length(unique(smoke))) %>%
  dplyr::arrange(desc(unique)) # unique > 1 indicates change over wave
# grab the value for the first wave and forces it to all waves
ds <- ds %>%
  dplyr::group_by(id) %>%
  dplyr::mutate(
    smoke_bl   = dplyr::first(smoke) # grabs the value for the first wave and forces it to all waves
  ) %>%
  dplyr::ungroup()
# examine the difference
ds %>% over_waves("smoke_bl")
ds %>% view_temporal_pattern("smoke_bl", 2)

# ---- prepare-for-mplus -------------------------------
names(ds)
ds2 <- ds %>%
  dplyr::mutate(
    id             = as.numeric(id),
    male_bl        = as.numeric(male_bl),
    height_cm_bl   = as.numeric(height_cm_bl),
    diabetes_bl    = as.numeric(diabetes_bl),
    cardio_bl      = as.numeric(cardio_bl),
    smoke_bl       = as.numeric(smoke_bl),

    edu_bl         = as.numeric(edu_bl),
    word_recall_im = as.numeric(word_recall_im),
    word_recall_de = as.numeric(word_recall_de),
    animals        = as.numeric(animals)
  ) %>%
  dplyr::select(id, wave, year_bl, year, age_bl,  age, year_born,
                male_bl, edu_bl, height_cm_bl, diabetes_bl, cardio_bl, smoke_bl,
                fev, fvc, pef,
                word_recall_im, word_recall_de, animals)





# ---- force-time-invariant-values -------------------
# ds_long <- ds2
# (ids <- 117781)
# d <- ds_long %>%
#   dplyr::filter(id %in% ids ) %>%
#   dplyr::select_("id","wave", "male")
# d


variables_static <- c("id", "year_bl", "age_bl","year_born", "male_bl", "edu_bl",
                      "height_cm_bl", "diabetes_bl", "cardio_bl", "smoke_bl")
variables_longitudinal <- setdiff(colnames(ds2),variables_static)
(variables_longitudinal <- variables_longitudinal[!variables_longitudinal=="wave"])


ds_wide <- ds2 %>%
  # dplyr::select(id, wave, animals, word_recall_de ) %>%
  # gather(variable, value, -(id:wave)) %>%
  dplyr::select_(.dots=c(variables_static, "wave", variables_longitudinal)) %>%
  tidyr::gather_(key="variable", value="value", variables_longitudinal) %>%
  dplyr::mutate(wave = paste0("t", wave)) %>%
  tidyr::unite(temp, variable, wave) %>%
  tidyr::spread(temp, value)


# prepare data for use in MPlus

# replace NA with a numerical code
ds_wide[is.na(ds_wide)] <- -9999
table(ds_wide$age_t2, useNA = "always")

# save to disk
write.table(ds_wide,"./data/unshared/derived/elsa/esla-mplus-data.dat", row.names=F, col.names=F)
write(names(ds_wide), "./data/unshared/derived/elsa/esla-mplus-varnames.txt", sep=" ")

