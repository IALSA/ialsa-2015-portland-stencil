################################################3
# below is the unadjusted  code from ELSA

# source("./sandbox/elsa-testing/elsa-testing.R")
# view structure of the working datasets
view_temporal_pattern <- function(ds_long, measure_name, ids){
  # set.seed(seed_value)
  # (ids <- sample(unique(ds_long$id),1))
  d <- ds_long %>%
    dplyr::filter(id %in% ids ) %>%
    dplyr::select_("id","wave", measure_name)
  print(d)
}

descriptives_over_waves <- function(ds_long, measure_name, exclude_values="") {
  d <- as.data.frame(ds_long)
  # ds <- as.data.frame(ds)
  testit::assert("No such measure in the dataset", measure_name %in% unique(names(ds_long)))
  cat("Measure : ", measure_name,"\n", sep="")
  # t <- table( ds[,measure_name], ds[,"wave"], useNA = "always"); t[t==0] <- ".";t
  # print(t)
  # cat("\n")
  d[,measure_name] <- as.numeric(d[,measure_name])

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



str(ds_long)
str(ds_wide)
# select
set.seed = 2
ids <- sample(unique(ds_wide$id),2)
ids <- c(103727, 103729)
# (ids <- 117781)

# ---- pcs-7-8 ----------------------------
# 7)	How many waves does [your study] contain? (include the baseline, enter as an integer)
# 8)	What is the sample size at each wave? Enter as integers (starting with baseline) separated by spaces.
ds_long %>%
  dplyr::group_by(wave) %>%
  dplyr::summarize(count = n())

# ---- pcs-9-13 ---------------------------
#9) Enter the [calendar year] of the baseline measure.
#10)	In your dataset, what is the exact name (case sensitive) of the variable measuring the respondents' [year of birth]?
#11)	In your dataset, what is the exact name (case sensitive) of the variable measuring the respondents' [age at death]?
#12)	In your dataset, what is the exact name (case sensitive) of the variable measuring the [age] of respondents at baseline?
#13)	In your dataset, what is the exact name (case sensitive) of the variable measuring respondents' [age at wave]?

ds_long %>%
  dplyr::filter(id %in% ids) %>%
  dplyr::select(id, wave, year_born, year_bl, year, age_bl, age)

# ---- pcs-14 ---------------------------
# for one individual
ds_long %>% view_temporal_pattern(measure_name = "age", ids = ids)
# across waves
ds_long %>% descriptives_over_waves(measure_name = "age")


# ---- pcs-15-20 ---------------------------
str(ds_long)
ds_long %>%
  dplyr::filter(id %in% ids) %>%
  dplyr::select(id, wave, male_bl, edu_bl)


# ---- pcs-pef ---------------------------
str(ds_long)
# for one individual
ds_long %>% view_temporal_pattern(measure = "pef", ids = ids)
ds_wide %>%
  dplyr::select(id, contains("pef")) %>%
  dplyr::glimpse()
# across waves
ds_long %>% descriptives_over_waves(measure_name = "pef")

# ---- pcs-fev ---------------------------
# for one individual
ds_long %>% view_temporal_pattern(measure = "fev", ids = ids)
ds_wide %>%
  dplyr::select(id, contains("fev")) %>%
  dplyr::glimpse()
# across waves
ds_long %>% descriptives_over_waves(measure_name = "fev")


# ---- pcs-gait ---------------------------
# for one individual
ds_long %>% view_temporal_pattern(measure_name = "gait", ids = ids)
ds_wide %>%
  dplyr::select(id, contains("gait")) %>%
  dplyr::glimpse()
# across waves
ds_long %>% descriptives_over_waves(measure_name = "gait")


# ---- pcs-grip ---------------------------
# for one individual
ds_long %>% view_temporal_pattern(measure_name = "grip", ids = ids)
ds_wide %>%
  dplyr::select(id, contains("grip")) %>%
  dplyr::glimpse()
# across waves
ds_long %>% descriptives_over_waves(measure_name = "grip")



# ---- pcs-animals ---------------------------
str(ds_long)
# for one individual
ds_long %>% view_temporal_pattern(measure_name = "animals", ids = ids)
ds_wide %>%
  dplyr::select(id, contains("animals")) %>%
  dplyr::glimpse()
# across waves
ds_long %>% descriptives_over_waves(measure_name = "animals")

# ---- pcs-word_recall_im ---------------------------
str(ds_long)
# for one individual
set.seed = 2
ids <- sample(unique(ds_wide$id),2)
ids <- c(103727, 103729, 117781)

ds_long %>% view_temporal_pattern(measure_name = "word_recall_im", ids = ids)
ds_wide %>%
  dplyr::select(id, contains("word_recall_im")) %>%
  dplyr::glimpse()
# across waves
ds_long %>% descriptives_over_waves(measure_name = "word_recall_im")


# ---- pcs-word_recall_de ---------------------------
ds_long %>% view_temporal_pattern(measure_name = "word_recall_de", ids = ids)
ds_wide %>%
  dplyr::select(id, contains("word_recall_de")) %>%
  dplyr::glimpse()
# across waves
ds_long %>% descriptives_over_waves(measure_name = "word_recall_de")


# ---- pcs-height_cm_bl ---------------------------
str(ds_long)
ds_long %>% view_temporal_pattern(measure_name = "height_cm_bl", ids = ids)
ds_wide %>%
  dplyr::select(id, contains("height_cm_bl")) %>%
  dplyr::glimpse()
# across waves
ds_long %>% descriptives_over_waves(measure_name = "height_cm_bl")










