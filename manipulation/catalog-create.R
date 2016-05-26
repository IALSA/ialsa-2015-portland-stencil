# knitr::stitch_rmd(script="./manipulation/te-ellis.R", output="./manipulation/stitched-output/te-ellis.md")
# For a brief description of this file see the presentation at
#   - slides: https://rawgit.com/wibeasley/RAnalysisSkeleton/master/documentation/time-and-effort-synthesis.html#/
#   - code: https://github.com/wibeasley/RAnalysisSkeleton/blob/master/documentation/time-and-effort-synthesis.Rpres
rm(list=ls(all=TRUE))  #Clear the variables from previous runs.

# ---- load-sources ------------------------------------------------------------
# Call `base::source()` on any repo file that defines functions needed below.  Ideally, no real operations are performed.

# ---- load-packages -----------------------------------------------------------
# Attach these packages so their functions don't need to be qualified: http://r-pkgs.had.co.nz/namespace.html#search-path
library(RODBC, quietly=TRUE)
library(magrittr, quietly=TRUE)

# Verify these packages are available on the machine, but their functions need to be qualified: http://r-pkgs.had.co.nz/namespace.html#search-path
requireNamespace("REDCapR") #devtools::install_github(repo="OuhscBbmc/REDCapR")
requireNamespace("OuhscMunge") #devtools::install_github(repo="OuhscBbmc/OuhscMunge")

requireNamespace("readr")
requireNamespace("tidyr")
requireNamespace("dplyr") #Avoid attaching dplyr, b/c its function names conflict with a lot of packages (esp base, stats, and plyr).
requireNamespace("testit") #For asserting conditions meet expected patterns.
# requireNamespace("car") #For it's `recode()` function.

# ---- declare-globals ---------------------------------------------------------
path_credential_pcs     <- "./data/unshared/security/user.credentials"
# figure_path <- 'manipulation/stitched-output/te/'

survey_ids_to_retain <- c(5L)

# redcap_flag_complete <- 2L #A value of 2 indicates to the REDCap admin that the record is 'complete'
#Factors from REDCap
investigations_to_run <- c("ELSA")
investigation_labels  <- c("EAS", "ELSA", "HRS", "ILSE", "LASA", "MAP", "NUAGE", "OCTO", "SATSA")
investigation_levels  <- seq_along(investigation_labels)

# ---- load-data ---------------------------------------------------------------

# Read the credentials
credential_pcs     <- REDCapR::retrieve_credential_local(path_credential_pcs, project_id=262) #For the pre-conference survey
credential_catalog <- REDCapR::retrieve_credential_local(path_credential_pcs, project_id=447) #For the catalog

# Retrieve from the PCS (pre-conference survey)
ds_pcs <- REDCapR::redcap_read(redcap_uri=credential_pcs$redcap_uri, token=credential_pcs$token)$data


rm(path_credential_pcs, credential_pcs)

# ---- tweak-data --------------------------------------------------------------
# OuhscMunge::column_rename_headstart(ds_pcs) #Spit out columns to help write call ato `dplyr::rename()`.
ds_pcs <- ds_pcs %>%
  dplyr::select_( #`select()` implicitly drops the other columns not mentioned.
    "survey_id"                                              = "`survey_id`"
    , "investigation"                                        = "`investigation`"
    # , "institution"                                          = "`institution`"
    # , "email_address"                                        = "`email_address`"
    # , "r_studio_feel"                                        = "`r_studio_feel`"
    # , "mplus_feel"                                           = "`mplus_feel`"
    # , "i_certify"                                            = "`i_certify`"
    , "baseline"                                             = "`baseline`"
    , "wave_sample_size"                                     = "`wave_sample_size`"
    , "baseline_measure_calendar_year"                       = "`baseline_measure_calendar_year`"
    , "name_variable_year_of_birth"                          = "`name_variable_year_of_birth`"
    , "name_variable_year_of_death"                          = "`name_variable_year_of_death`"
    , "name_variable_baseline_age"                           = "`name_variable_baseline_age`"
    , "name_variable_age_at_wave"                            = "`name_variable_age_at_wave`"
    , "waves_at_for_all_ages"                                = "`waves_at_for_all_ages`"
    , "name_variable_unique_identifier"                      = "`name_variable_unique_identifier`"
    , "name_variable_twin_identifier"                        = "`name_variable_twin_identifier`"
    , "name_variable_sex_baseline"                           = "`name_variable_sex_baseline`"
    , "name_variable_education_baseline"                     = "`name_variable_education_baseline`"
    , "name_variable_ses_baseline"                           = "`name_variable_ses_baseline`"
    , "name_variable_marital_status_baseline"                = "`name_variable_marital_status_baseline`"
    , "physical_name_pef"                                    = "`physical_name_pef`"
    , "physical_waves_pef"                                   = "`physical_waves_pef`"
    , "physical_name_fev"                                    = "`physical_name_fev`"
    , "physical_waves_fev"                                   = "`physical_waves_fev`"
    , "physical_name_gait"                                   = "`physical_name_gait`"
    , "physical_waves_gait"                                  = "`physical_waves_gait`"
    , "physical_name_grip"                                   = "`physical_name_grip`"
    , "physical_waves_grip"                                  = "`physical_waves_grip`"
    , "physical_construct_other"                             = "`physical_construct_other`"
    , "cog_name_analogies"                                   = "`cog_name_analogies`"
    , "cog_waves_analogies"                                  = "`cog_waves_analogies`"
    , "cog_name_auditory"                                    = "`cog_name_auditory`"
    , "cog_waves_auditory"                                   = "`cog_waves_auditory`"
    , "cog_name_block"                                       = "`cog_name_block`"
    , "cog_waves_block"                                      = "`cog_waves_block`"
    , "cog_name_boston"                                      = "`cog_name_boston`"
    , "cog_waves_boston"                                     = "`cog_waves_boston`"
    , "cog_name_categories"                                  = "`cog_name_categories`"
    , "cog_waves_categories"                                 = "`cog_waves_categories`"
    , "cog_name_digit"                                       = "`cog_name_digit`"
    , "cog_waves_digit"                                      = "`cog_waves_digit`"
    , "cog_name_digit_sf"                                    = "`cog_name_digit_sf`"
    , "cog_waves_digit_sf"                                   = "`cog_waves_digit_sf`"
    , "cog_name_digit_sb"                                    = "`cog_name_digit_sb`"
    , "cog_waves_digit_sb"                                   = "`cog_waves_digit_sb`"
    , "cog_name_digit_st"                                    = "`cog_name_digit_st`"
    , "cog_waves_digit_st"                                   = "`cog_waves_digit_st`"
    , "cog_name_fas"                                         = "`cog_name_fas`"
    , "cog_waves_fas"                                        = "`cog_waves_fas`"
    , "cog_name_figure"                                      = "`cog_name_figure`"
    , "cog_waves_figure"                                     = "`cog_waves_figure`"
    , "cog_name_figure_logic"                                = "`cog_name_figure_logic`"
    , "cog_waves_figure_logic"                               = "`cog_waves_figure_logic`"
    , "cog_name_figure_memory"                               = "`cog_name_figure_memory`"
    , "cog_waves_figure_memory"                              = "`cog_waves_figure_memory`"
    , "cog_fluency"                                          = "`cog_fluency`"
    , "cog_waves_fluency"                                    = "`cog_waves_fluency`"
    , "cog_name_information"                                 = "`cog_name_information`"
    , "cog_waves_information"                                = "`cog_waves_information`"
    , "cog_name_ipss"                                        = "`cog_name_ipss`"
    , "cog_waves_ipss"                                       = "`cog_waves_ipss`"
    , "cog_name_line"                                        = "`cog_name_line`"
    , "cog_waves_line"                                       = "`cog_waves_line`"
    , "cog_name_logical_mi"                                  = "`cog_name_logical_mi`"
    , "cog_waves_logical_mi"                                 = "`cog_waves_logical_mi`"
    , "cog_name_logical_md"                                  = "`cog_name_logical_md`"
    , "cog_waves_logical_md"                                 = "`cog_waves_logical_md`"
    , "cog_name_matrices"                                    = "`cog_name_matrices`"
    , "cog_waves_matrices"                                   = "`cog_waves_matrices`"
    , "cog_name_memory_ir"                                   = "`cog_name_memory_ir`"
    , "cog_waves_memory_ir"                                  = "`cog_waves_memory_ir`"
    , "cog_name_mmse"                                        = "`cog_name_mmse`"
    , "cog_waves_mmse"                                       = "`cog_waves_mmse`"
    , "cog_name_number"                                      = "`cog_name_number`"
    , "cog_waves_number"                                     = "`cog_waves_number`"
    , "cog_name_speed"                                       = "`cog_name_speed`"
    , "cog_waves_speed"                                      = "`cog_waves_speed`"
    , "cog_name_picture"                                     = "`cog_name_picture`"
    , "cog_waves_picture"                                    = "`cog_waves_picture`"
    , "cog_name_pros_recall_imme"                            = "`cog_name_pros_recall_imme`"
    , "cog_waves_pros_recall_imme"                           = "`cog_waves_pros_recall_imme`"
    , "cog_name_pros_recall_delay"                           = "`cog_name_pros_recall_delay`"
    , "cog_waves_pros_recall_delay"                          = "`cog_waves_pros_recall_delay`"
    , "cog_name_pros_recall_total"                           = "`cog_name_pros_recall_total`"
    , "cog_waves_pros_recall_total"                          = "`cog_waves_pros_recall_total`"
    , "cog_name_reading"                                     = "`cog_name_reading`"
    , "cog_waves_reading"                                    = "`cog_waves_reading`"
    , "cog_name_rotation"                                    = "`cog_name_rotation`"
    , "cog_waves_rotation"                                   = "`cog_waves_rotation`"
    , "cog_name_serial7"                                     = "`cog_name_serial7`"
    , "cog_waves_serial7"                                    = "`cog_waves_serial7`"
    , "cog_name_substitution"                                = "`cog_name_substitution`"
    , "cog_waves_substitution"                               = "`cog_waves_substitution`"
    , "cog_name_switching"                                   = "`cog_name_switching`"
    , "cog_waves_switching"                                  = "`cog_waves_switching`"
    , "cog_name_synonyms"                                    = "`cog_name_synonyms`"
    , "cog_waves_synonyms"                                   = "`cog_waves_synonyms`"
    , "cog_name_tics"                                        = "`cog_name_tics`"
    , "cog_waves_tics"                                       = "`cog_waves_tics`"
    , "cog_name_vocabulary"                                  = "`cog_name_vocabulary`"
    , "cog_waves_vocabulary"                                 = "`cog_waves_vocabulary`"
    , "cog_name_word_list_im"                                = "`cog_name_word_list_im`"
    , "cog_waves_word_list_im"                               = "`cog_waves_word_list_im`"
    , "cog_name_word_list_delay"                             = "`cog_name_word_list_delay`"
    , "cog_waves_word_list_delay"                            = "`cog_waves_word_list_delay`"
    , "cog_name_word_list_recog"                             = "`cog_name_word_list_recog`"
    , "cog_waves_word_list_recog"                            = "`cog_waves_word_list_recog`"
    , "name_variable_height_baseline"                        = "`name_variable_height_baseline`"
    , "name_variable_weight_baseline"                        = "`name_variable_weight_baseline`"
    , "name_variable_bmi_baseline"                           = "`name_variable_bmi_baseline`"
    , "name_variable_dementia_diagnosis_baseline"            = "`name_variable_dementia_diagnosis_baseline`"
    , "name_variable_smoking_history_baseline"               = "`name_variable_smoking_history_baseline`"
    , "name_variable_cvd_history_baseline"                   = "`name_variable_cvd_history_baseline`"
    , "name_variable_diabetes_baseline"                      = "`name_variable_diabetes_baseline`"
    , "name_variable_alcohol_use_baseline"                   = "`name_variable_alcohol_use_baseline`"
    , "mplus_filter_1"                                       = "`mplus_filter_1`"
    # , "preconference_survey_complete"                        = "`preconference_survey_complete`"
  ) %>%
  dplyr::mutate(
    investigation                                            = factor(investigation, levels=investigation_levels, labels=investigation_labels)
  ) %>%
  dplyr::filter(
    survey_id      %in%  survey_ids_to_retain
  )

# ---- verify-values-pcs -----------------------------------------------------------


# ---- expand-to-catalog ------------------------------------------------------

colnames(ds_pcs)

# dput(grep("^physical_name_\\w+$", colnames(ds_pcs), perl=T, value=T))
# dput(grep("^cog_name_\\w+$", colnames(ds_pcs), perl=T, value=T))

variables_physical  <- c(
  "physical_name_pef", "physical_name_fev", "physical_name_gait", "physical_name_grip"
)
variables_cog  <- c(
  "cog_name_analogies", "cog_name_auditory", "cog_name_block",
  "cog_name_boston", "cog_name_categories", "cog_name_digit", "cog_name_digit_sf",
  "cog_name_digit_sb", "cog_name_digit_st", "cog_name_fas", "cog_name_figure",
  "cog_name_figure_logic", "cog_name_figure_memory", "cog_name_information",
  "cog_name_ipss", "cog_name_line", "cog_name_logical_mi", "cog_name_logical_md",
  "cog_name_matrices", "cog_name_memory_ir", "cog_name_mmse", "cog_name_number",
  "cog_name_speed", "cog_name_picture", "cog_name_pros_recall_imme",
  "cog_name_pros_recall_delay", "cog_name_pros_recall_total", "cog_name_reading",
  "cog_name_rotation", "cog_name_serial7", "cog_name_substitution",
  "cog_name_switching", "cog_name_synonyms", "cog_name_tics", "cog_name_vocabulary",
  "cog_name_word_list_im", "cog_name_word_list_delay", "cog_name_word_list_recog"
)
model_types <- c("zero", "a", "ae", "aeh", "aehplus", "full")
subgroups <- c("female", "male")

ds_crossed <- tidyr::crossing(
  investigation       = investigations_to_run,
  process_a           = variables_physical,
  process_b           = variables_cog,
  model_type          = model_types,
  subgroup            = subgroups
) %>%
dplyr::mutate(
  investigation       = factor(investigation, levels=investigation_labels, labels=investigation_labels), #intentionally user 'labels' twice.
  model_type          = factor(model_type   , levels=model_types ), #Setting the factor levels will help sorting.
  subgroup            = factor(subgroup     , levels=subgroups   ),
  process_a_wave_name = gsub("^physical_name_(\\w+)$", "physical_waves_\\1", process_a),
  process_b_wave_name = gsub("^cog_name_(\\w+)$", "cog_waves_\\1", process_b)
) %>%
dplyr::arrange(investigation, process_a, process_b, model_type, subgroup)

ds_crossed2 <- ds_crossed %>%
  dplyr::left_join(ds_pcs, by="investigation")

testit::assert("All process_a variables should be found.", all(ds_crossed2$process_a %in% colnames(ds_crossed2)))
testit::assert("All process_a variables should be found.", all(ds_crossed2$process_b %in% colnames(ds_crossed2)))
testit::assert("All process_a wave variables should be found.", all(ds_crossed2$process_a_wave_name %in% colnames(ds_crossed2)))
testit::assert("All process_b wave variables should be found.", all(ds_crossed2$process_b_wave_name %in% colnames(ds_crossed2)))

# setdiff(ds_crossed2$process_a_wave_name, colnames(ds_crossed2))
# setdiff(ds_crossed2$process_b_wave_name, colnames(ds_crossed2))


ds_crossed2$process_a_stem  <- as.character(as.data.frame(ds_crossed2)[1, ds_crossed2$process_a])
ds_crossed2$process_b_stem  <- as.character(as.data.frame(ds_crossed2)[1, ds_crossed2$process_b])
ds_crossed2$process_a_waves <- as.character(as.data.frame(ds_crossed2)[1, ds_crossed2$process_a_wave_name])
ds_crossed2$process_b_waves <- as.character(as.data.frame(ds_crossed2)[1, ds_crossed2$process_b_wave_name])

# table(ds_crossed2$process_a)
# table(ds_crossed2$process_a_stem)
# table(ds_crossed2$process_a, ds_crossed2$process_a_stem)
# table(ds_crossed2$process_b)
# table(ds_crossed2$process_b_stem)
# table(ds_crossed2$process_b, ds_crossed2$process_b_stem)

ds_crossed3 <- ds_crossed2 %>%
  dplyr::mutate(
    process_a_stem    = ifelse(process_a_stem=="NA", NA, process_a_stem),
    process_b_stem    = ifelse(process_b_stem=="NA", NA, process_b_stem),
    process_a         = gsub("^(physical|cog)_name_(\\w+)$", "\\2", process_a, perl=T) ,
    process_b         = gsub("^(physical|cog)_name_(\\w+)$", "\\2", process_b, perl=T)
  ) %>%
  dplyr::select(
    survey_id,
    investigation,
    process_a,
    process_b,
    model_type,
    subgroup,
    process_a_stem,
    process_b_stem,
    process_a_waves,
    process_b_waves,
    mplus_filter_1
  ) %>%
  dplyr::filter(!is.na(process_a_stem) & !is.na(process_b_stem))

# ---- convert-to-catalog ------------------------------------------------------

path_study_stem <- "./data/unshared/mplus/"

determine_path_data <- function( investigation ) {
  investigation <- tolower(investigation)
  return( paste0(path_study_stem, investigation, "/", investigation, ".dat") )
} # determine_path_data("elSa")

determine_path_mplus <-  function( investigation, model_tag, extension) {
  investigation <- tolower(investigation)
  # record_id_padded    = sprintf("%07d", record_id)
  return( paste0(path_study_stem, investigation, "/", model_tag, ".", extension) )
} # determine_path_inp("elSa")

ds_catalog <- ds_crossed3 %>%
  dplyr::rename_(
    "pcs_id"                  = "survey_id"
  ) %>%
  dplyr::mutate(
    record_id           = seq_len(n()),
    model_tag           = tolower(paste(sprintf("%07d", record_id), "b1", investigation, process_a, process_b, subgroup, model_type, sep="-")),
    path_data           = determine_path_data(investigation),
    path_inp            = determine_path_mplus(investigation, model_tag, "inp"),
    path_out            = determine_path_mplus(investigation, model_tag, "out"),
    process_a_names     = "tbd",
    process_b_names     = "tbd"
  )
# ds_catalog$path_inp





# ---- verify-values-catalog -----------------------------------------------------------
# Sniff out problems
#TODO: look at this more closely and think what could go wrong later.

# #Hard asserts where each cell must comply.
# testit::assert("At this point, all `site_key` values should be zero.", all(ds$site_key==0L))
# testit::assert("`encounter_count` must be nonmissing and nonnegative", all(!is.na(ds$encounter_count) & (ds$encounter_count>=0)))
# # testit::assert("The region_id value must be in [1, 20].", all(ds$region_id %in% seq_len(20L)))
#
# #Soft asserts where there's more forgiveness on the cell level, but that overall dataset can't be too junky.
# testit::assert("At least 70% of the `admit_date_first` should be nonmissing.", .70 < mean(!is.na(ds$admit_date_first)))
# testit::assert("At least 70% of the `admit_date_last` should be nonmissing." , .70 < mean(!is.na(ds$admit_date_last)))
#
# # testit::assert("The County-month combination should be unique.", all(!duplicated(paste(ds$county_id, ds$month))))
# # testit::assert("The Region-County-month combination should be unique.", all(!duplicated(paste(ds$region_id, ds$county_id, ds$month))))
# # table(paste(ds$county_id, ds$month))[table(paste(ds$county_id, ds$month))>1]


# ---- specify-columns-to-upload -----------------------------------------------
# dput(colnames(ds_catalog))
columns_to_write <-c(
  "record_id", "pcs_id", "investigation", "process_a", "process_b",
  "model_type", "subgroup",
  "process_a_waves", "process_b_waves", "process_a_stem", "process_b_stem", "process_a_names", "process_b_names",
  "model_tag", "path_data", "path_inp", "path_out",
  "mplus_filter_1"
)
ds_slim <- ds_catalog[, columns_to_write]

rm(columns_to_write)

# ---- upload-to-db ------------------------------------------------------------
# readr::write_csv(ds_slim, "./data-unshared/derived/3t.csv")
# ds_pull <- REDCapR::redcap_read(
#   redcap_uri                 = credential$redcap_url,
#   token                      = credential$token
# )$data

# setdiff(colnames(ds_pull), colnames(ds_slim)) #Columns missing from local dataset ds_slim (that are in REDCap)
# setdiff(colnames(ds_slim), colnames(ds_pull)) #Columns missing from REDCap (that are in ds_slim)


result_write <- REDCapR::redcap_write(
  ds_to_write                = ds_slim,
  redcap_uri                 = credential_catalog$redcap_uri,
  token                      = credential_catalog$token,
  batch_size                 = 500 # Descrease if it helps debugging write errors
)
# result_write
