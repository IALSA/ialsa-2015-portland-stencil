# source("./sandbox/elsa-testing/elsa-testing.R")



ids <- sample(unique(ds_wide$id))
# (ids <- 117781)
d <- ds_long %>%
  dplyr::filter(id %in% ids ) %>%
  dplyr::select_("id", "wave","male_bl")
d

# for one individual
ds %>% view_temporal_pattern(measure = "male_bl", seed_value =  42)
# across waves
ds %>% over_waves(measure_name = "male_bl")
