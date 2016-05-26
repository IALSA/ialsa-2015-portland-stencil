# knitr::stitch_rmd(script="./manipulation/te-ellis.R", output="./manipulation/stitched-output/te-ellis.md")
# For a brief description of this file see the presentation at
#   - slides: https://rawgit.com/wibeasley/RAnalysisSkeleton/master/documentation/time-and-effort-synthesis.html#/
#   - code: https://github.com/wibeasley/RAnalysisSkeleton/blob/master/documentation/time-and-effort-synthesis.Rpres
rm(list=ls(all=TRUE))  #Clear the variables from previous runs.

# ---- load-sources ------------------------------------------------------------
# Call `base::source()` on any repo file that defines functions needed below.  Ideally, no real operations are performed.
source("./manipulation/parser.R") # Defines the `parse()` function.

# ---- load-packages -----------------------------------------------------------
# Attach these packages so their functions don't need to be qualified: http://r-pkgs.had.co.nz/namespace.html#search-path
library(RODBC, quietly=TRUE)
library(magrittr, quietly=TRUE)

# Verify these packages are available on the machine, but their functions need to be qualified: http://r-pkgs.had.co.nz/namespace.html#search-path
requireNamespace("REDCapR") #devtools::install_github(repo="OuhscBbmc/REDCapR")
requireNamespace("IalsaSynthesis") # devtools::install_github(repo="IALSA/IalsaSynthesis")

requireNamespace("readr")
requireNamespace("dplyr") #Avoid attaching dplyr, b/c its function names conflict with a lot of packages (esp base, stats, and plyr).
requireNamespace("testit") #For asserting conditions meet expected patterns.

# ---- declare-globals ---------------------------------------------------------
path_credential <- "./data/unshared/security/phi-free.credentials"
desired_columns <- c("record_id", "model_tag", "mplus_output", "parse_complete")

ids_to_exclude <- c(9)

# ---- load-data ---------------------------------------------------------------

# Read the credentials
credential_catalog <- REDCapR::retrieve_credential_local(path_credential, project_id=447) #For the catalog

# Retrieve from the catalog.
ds_catalog <- REDCapR::redcap_read(
  redcap_uri  = credential_catalog$redcap_uri,
  token       = credential_catalog$token,
  fields      = desired_columns
)$data

rm(path_credential, desired_columns)

# ---- tweak-data --------------------------------------------------------------
# OuhscMunge::column_rename_headstart(ds_pcs) #Spit out columns to help write call ato `dplyr::rename()`.
ds_parse <- ds_catalog %>%
  dplyr::rename_(
  ) %>%
  dplyr::filter(
    ( !is.na(mplus_output) & nchar(mplus_output) >= 500)
    & (is.na(parse_complete) | !parse_complete)
    & !(record_id %in% ids_to_exclude)
  ) %>%
  dplyr::mutate(

  )

# ---- parse-output -----------------------------------------------------------

# outputs <- rep(NA_character_, nrow(ds_confer))
ds_results_list <- list()
for( i in seq_len(nrow(ds_parse)) ) { # i <- 1
  message("Parsing model ", ds_parse$model_tag[i])
  tryCatch(expr={
    path_temp_out <- paste0(tempfile(pattern="temp-out", tmpdir=tempdir()), ".out")
    base::write(ds_parse$mplus_output[i], path_temp_out)

    ds_results_list[[i]] <- parse(ds_parse$record_id[i],  path_temp_out)

  },
  finally={
    unlink(path_temp_out) #Delete the temp file, regardless if the parse operation succeedes
  })
}
table(nchar(ds_results_list)>0, useNA="always")

# ---- unify-dataset -----------------------------------------------------------
# OuhscMunge::column_rename_headstart(ds_results) #Spit out columns to help write call ato `dplyr::rename()`.

ds_results <- ds_results_list %>%
  dplyr::bind_rows() %>%
  dplyr::rename_(
    "software"                       = "`software`"
    , "mplus_version"                = "`version`"
    # , "date"                       = "`date`"
    # , "time"                       = "`time`"
    # , "output_file"                = "`output_file`"
    # , "data_file"                  = "`data_file`"
    # , "file_path"                  = "`file_path`"
    # , "subgroup_sex"               = "`subgroup_sex`"
    # , "process_a"                  = "`process_a`"
    , "subject_count"              = "`subject_count`"
    , "wave_count"                 = "`wave_count`"
    # , "datapoint_count"            = "`datapoint_count`"
    # , "parameter_count"            = "`parameter_count`"
    , "has_converged"              = "`has_converged`"
    , "trust_all"                  = "`trust_all`"
    , "mistrust"                   = "`mistrust`"
    , "covar_covered"              = "`covar_covered`"
    , "record_id"                  = "`record_id`"
    # , "ll"                         = "`LL`"
    , "aic"                        = "`aic`"
    , "bic"                        = "`bic`"
    # , "adj_bic"                    = "`adj_bic`"
    # , "aaic"                       = "`aaic`"
    # , "ab_tau_00_est"              = "`ab_TAU_00_est`"
    # , "ab_tau_00_se"               = "`ab_TAU_00_se`"
    # , "ab_tau_00_wald"             = "`ab_TAU_00_wald`"
    # , "ab_tau_00_pval"             = "`ab_TAU_00_pval`"
    # , "ab_tau_11_est"              = "`ab_TAU_11_est`"
    # , "ab_tau_11_se"               = "`ab_TAU_11_se`"
    # , "ab_tau_11_wald"             = "`ab_TAU_11_wald`"
    # , "ab_tau_11_pval"             = "`ab_TAU_11_pval`"
    # , "ab_tau_01_est"              = "`ab_TAU_01_est`"
    # , "ab_tau_01_se"               = "`ab_TAU_01_se`"
    # , "ab_tau_01_wald"             = "`ab_TAU_01_wald`"
    # , "ab_tau_01_pval"             = "`ab_TAU_01_pval`"
    # , "ab_tau_10_est"              = "`ab_TAU_10_est`"
    # , "ab_tau_10_se"               = "`ab_TAU_10_se`"
    # , "ab_tau_10_wald"             = "`ab_TAU_10_wald`"
    # , "ab_tau_10_pval"             = "`ab_TAU_10_pval`"
    # , "ab_sigma_est"               = "`ab_SIGMA_est`"
    # , "ab_sigma_se"                = "`ab_SIGMA_se`"
    # , "ab_sigma_wald"              = "`ab_SIGMA_wald`"
    # , "ab_sigma_pval"              = "`ab_SIGMA_pval`"
    # , "aa_tau_00_est"              = "`aa_TAU_00_est`"
    # , "aa_tau_00_se"               = "`aa_TAU_00_se`"
    # , "aa_tau_00_wald"             = "`aa_TAU_00_wald`"
    # , "aa_tau_00_pval"             = "`aa_TAU_00_pval`"
    # , "aa_tau_11_est"              = "`aa_TAU_11_est`"
    # , "aa_tau_11_se"               = "`aa_TAU_11_se`"
    # , "aa_tau_11_wald"             = "`aa_TAU_11_wald`"
    # , "aa_tau_11_pval"             = "`aa_TAU_11_pval`"
    # , "aa_tau_01_est"              = "`aa_TAU_01_est`"
    # , "aa_tau_01_se"               = "`aa_TAU_01_se`"
    # , "aa_tau_01_wald"             = "`aa_TAU_01_wald`"
    # , "aa_tau_01_pval"             = "`aa_TAU_01_pval`"
    # , "a_sigma_est"                = "`a_SIGMA_est`"
    # , "a_sigma_se"                 = "`a_SIGMA_se`"
    # , "a_sigma_wald"               = "`a_SIGMA_wald`"
    # , "a_sigma_pval"               = "`a_SIGMA_pval`"
    # , "bb_tau_00_est"              = "`bb_TAU_00_est`"
    # , "bb_tau_00_se"               = "`bb_TAU_00_se`"
    # , "bb_tau_00_wald"             = "`bb_TAU_00_wald`"
    # , "bb_tau_00_pval"             = "`bb_TAU_00_pval`"
    # , "bb_tau_11_est"              = "`bb_TAU_11_est`"
    # , "bb_tau_11_se"               = "`bb_TAU_11_se`"
    # , "bb_tau_11_wald"             = "`bb_TAU_11_wald`"
    # , "bb_tau_11_pval"             = "`bb_TAU_11_pval`"
    # , "bb_tau_10_est"              = "`bb_TAU_10_est`"
    # , "bb_tau_10_se"               = "`bb_TAU_10_se`"
    # , "bb_tau_10_wald"             = "`bb_TAU_10_wald`"
    # , "bb_tau_10_pval"             = "`bb_TAU_10_pval`"
    # , "b_sigma_est"                = "`b_SIGMA_est`"
    # , "b_sigma_se"                 = "`b_SIGMA_se`"
    # , "b_sigma_wald"               = "`b_SIGMA_wald`"
    # , "b_sigma_pval"               = "`b_SIGMA_pval`"
    # , "a_gamma_00_est"             = "`a_GAMMA_00_est`"
    # , "a_gamma_00_se"              = "`a_GAMMA_00_se`"
    # , "a_gamma_00_wald"            = "`a_GAMMA_00_wald`"
    # , "a_gamma_00_pval"            = "`a_GAMMA_00_pval`"
    # , "a_gamma_10_est"             = "`a_GAMMA_10_est`"
    # , "a_gamma_10_se"              = "`a_GAMMA_10_se`"
    # , "a_gamma_10_wald"            = "`a_GAMMA_10_wald`"
    # , "a_gamma_10_pval"            = "`a_GAMMA_10_pval`"
    # , "b_gamma_00_est"             = "`b_GAMMA_00_est`"
    # , "b_gamma_00_se"              = "`b_GAMMA_00_se`"
    # , "b_gamma_00_wald"            = "`b_GAMMA_00_wald`"
    # , "b_gamma_00_pval"            = "`b_GAMMA_00_pval`"
    # , "b_gamma_10_est"             = "`b_GAMMA_10_est`"
    # , "b_gamma_10_se"              = "`b_GAMMA_10_se`"
    # , "b_gamma_10_wald"            = "`b_GAMMA_10_wald`"
    # , "b_gamma_10_pval"            = "`b_GAMMA_10_pval`"
    , "r_iaib_est"                 = "`R_IAIB_est`"
    , "r_iaib_se"                  = "`R_IAIB_se`"
    , "r_iaib_wald"                = "`R_IAIB_wald`"
    , "r_iaib_pval"                = "`R_IAIB_pval`"
    , "r_sasb_est"                 = "`R_SASB_est`"
    , "r_sasb_se"                  = "`R_SASB_se`"
    , "r_sasb_wald"                = "`R_SASB_wald`"
    , "r_sasb_pval"                = "`R_SASB_pval`"
    , "r_res_ab_est"               = "`R_RES_AB_est`"
    , "r_res_ab_se"                = "`R_RES_AB_se`"
    , "r_res_ab_wald"              = "`R_RES_AB_wald`"
    , "r_res_ab_pval"              = "`R_RES_AB_pval`"
    # , "a_gamma_01_est"             = "`a_GAMMA_01_est`"
    # , "a_gamma_01_se"              = "`a_GAMMA_01_se`"
    # , "a_gamma_01_wald"            = "`a_GAMMA_01_wald`"
    # , "a_gamma_01_pval"            = "`a_GAMMA_01_pval`"
    # , "a_gamma_11_est"             = "`a_GAMMA_11_est`"
    # , "a_gamma_11_se"              = "`a_GAMMA_11_se`"
    # , "a_gamma_11_wald"            = "`a_GAMMA_11_wald`"
    # , "a_gamma_11_pval"            = "`a_GAMMA_11_pval`"
    # , "b_gamma_01_est"             = "`b_GAMMA_01_est`"
    # , "b_gamma_01_se"              = "`b_GAMMA_01_se`"
    # , "b_gamma_01_wald"            = "`b_GAMMA_01_wald`"
    # , "b_gamma_01_pval"            = "`b_GAMMA_01_pval`"
    # , "b_gamma_11_est"             = "`b_GAMMA_11_est`"
    # , "b_gamma_11_se"              = "`b_GAMMA_11_se`"
    # , "b_gamma_11_wald"            = "`b_GAMMA_11_wald`"
    # , "b_gamma_11_pval"            = "`b_GAMMA_11_pval`"
    # , "a_gamma_02_est"             = "`a_GAMMA_02_est`"
    # , "a_gamma_02_se"              = "`a_GAMMA_02_se`"
    # , "a_gamma_02_wald"            = "`a_GAMMA_02_wald`"
    # , "a_gamma_02_pval"            = "`a_GAMMA_02_pval`"
    # , "a_gamma_12_est"             = "`a_GAMMA_12_est`"
    # , "a_gamma_12_se"              = "`a_GAMMA_12_se`"
    # , "a_gamma_12_wald"            = "`a_GAMMA_12_wald`"
    # , "a_gamma_12_pval"            = "`a_GAMMA_12_pval`"
    # , "b_gamma_02_est"             = "`b_GAMMA_02_est`"
    # , "b_gamma_02_se"              = "`b_GAMMA_02_se`"
    # , "b_gamma_02_wald"            = "`b_GAMMA_02_wald`"
    # , "b_gamma_02_pval"            = "`b_GAMMA_02_pval`"
    # , "b_gamma_12_est"             = "`b_GAMMA_12_est`"
    # , "b_gamma_12_se"              = "`b_GAMMA_12_se`"
    # , "b_gamma_12_wald"            = "`b_GAMMA_12_wald`"
    # , "b_gamma_12_pval"            = "`b_GAMMA_12_pval`"
    # , "a_gamma_03_est"             = "`a_GAMMA_03_est`"
    # , "a_gamma_03_se"              = "`a_GAMMA_03_se`"
    # , "a_gamma_03_wald"            = "`a_GAMMA_03_wald`"
    # , "a_gamma_03_pval"            = "`a_GAMMA_03_pval`"
    # , "a_gamma_13_est"             = "`a_GAMMA_13_est`"
    # , "a_gamma_13_se"              = "`a_GAMMA_13_se`"
    # , "a_gamma_13_wald"            = "`a_GAMMA_13_wald`"
    # , "a_gamma_13_pval"            = "`a_GAMMA_13_pval`"
    # , "b_gamma_03_est"             = "`b_GAMMA_03_est`"
    # , "b_gamma_03_se"              = "`b_GAMMA_03_se`"
    # , "b_gamma_03_wald"            = "`b_GAMMA_03_wald`"
    # , "b_gamma_03_pval"            = "`b_GAMMA_03_pval`"
    # , "b_gamma_13_est"             = "`b_GAMMA_13_est`"
    # , "b_gamma_13_se"              = "`b_GAMMA_13_se`"
    # , "b_gamma_13_wald"            = "`b_GAMMA_13_wald`"
    # , "b_gamma_13_pval"            = "`b_GAMMA_13_pval`"
    # , "a_gamma_04_est"             = "`a_GAMMA_04_est`"
    # , "a_gamma_04_se"              = "`a_GAMMA_04_se`"
    # , "a_gamma_04_wald"            = "`a_GAMMA_04_wald`"
    # , "a_gamma_04_pval"            = "`a_GAMMA_04_pval`"
    # , "a_gamma_14_est"             = "`a_GAMMA_14_est`"
    # , "a_gamma_14_se"              = "`a_GAMMA_14_se`"
    # , "a_gamma_14_wald"            = "`a_GAMMA_14_wald`"
    # , "a_gamma_14_pval"            = "`a_GAMMA_14_pval`"
    # , "b_gamma_04_est"             = "`b_GAMMA_04_est`"
    # , "b_gamma_04_se"              = "`b_GAMMA_04_se`"
    # , "b_gamma_04_wald"            = "`b_GAMMA_04_wald`"
    # , "b_gamma_04_pval"            = "`b_GAMMA_04_pval`"
    # , "b_gamma_14_est"             = "`b_GAMMA_14_est`"
    # , "b_gamma_14_se"              = "`b_GAMMA_14_se`"
    # , "b_gamma_14_wald"            = "`b_GAMMA_14_wald`"
    # , "b_gamma_14_pval"            = "`b_GAMMA_14_pval`"
    # , "a_gamma_05_est"             = "`a_GAMMA_05_est`"
    # , "a_gamma_05_se"              = "`a_GAMMA_05_se`"
    # , "a_gamma_05_wald"            = "`a_GAMMA_05_wald`"
    # , "a_gamma_05_pval"            = "`a_GAMMA_05_pval`"
    # , "a_gamma_15_est"             = "`a_GAMMA_15_est`"
    # , "a_gamma_15_se"              = "`a_GAMMA_15_se`"
    # , "a_gamma_15_wald"            = "`a_GAMMA_15_wald`"
    # , "a_gamma_15_pval"            = "`a_GAMMA_15_pval`"
    # , "b_gamma_05_est"             = "`b_GAMMA_05_est`"
    # , "b_gamma_05_se"              = "`b_GAMMA_05_se`"
    # , "b_gamma_05_wald"            = "`b_GAMMA_05_wald`"
    # , "b_gamma_05_pval"            = "`b_GAMMA_05_pval`"
    # , "b_gamma_15_est"             = "`b_GAMMA_15_est`"
    # , "b_gamma_15_se"              = "`b_GAMMA_15_se`"
    # , "b_gamma_15_wald"            = "`b_GAMMA_15_wald`"
    # , "b_gamma_15_pval"            = "`b_GAMMA_15_pval`"
    # , "a_gamma_06_est"             = "`a_GAMMA_06_est`"
    # , "a_gamma_06_se"              = "`a_GAMMA_06_se`"
    # , "a_gamma_06_wald"            = "`a_GAMMA_06_wald`"
    # , "a_gamma_06_pval"            = "`a_GAMMA_06_pval`"
    # , "a_gamma_16_est"             = "`a_GAMMA_16_est`"
    # , "a_gamma_16_se"              = "`a_GAMMA_16_se`"
    # , "a_gamma_16_wald"            = "`a_GAMMA_16_wald`"
    # , "a_gamma_16_pval"            = "`a_GAMMA_16_pval`"
    # , "b_gamma_06_est"             = "`b_GAMMA_06_est`"
    # , "b_gamma_06_se"              = "`b_GAMMA_06_se`"
    # , "b_gamma_06_wald"            = "`b_GAMMA_06_wald`"
    # , "b_gamma_06_pval"            = "`b_GAMMA_06_pval`"
    # , "b_gamma_16_est"             = "`b_GAMMA_16_est`"
    # , "b_gamma_16_se"              = "`b_GAMMA_16_se`"
    # , "b_gamma_16_wald"            = "`b_GAMMA_16_wald`"
    # , "b_gamma_16_pval"            = "`b_GAMMA_16_pval`"
  ) %>%
  dplyr::mutate(
    date                 = as.Date(date, "%M/%d/%Y")
    # parse_complete       = TRUE
  ) %>%
  dplyr::left_join(ds_catalog, by="record_id") %>%
  dplyr::select_(.dots = c("record_id", setdiff(colnames(ds_results), "record_id")))



# ---- verify-values -----------------------------------------------------------
# testit::assert("All model output should be at least 500 characters.", all(nchar(ds_confer$mplus_output) >= 500L))


# ---- specify-columns-to-upload -----------------------------------------------
# dput(colnames(ds_results))
columns_to_write <-c(
  "record_id", "parse_complete",
  "has_converged", "trust_all", "mistrust", "covar_covered"
)
ds_slim <- ds_results[, columns_to_write]

rm(columns_to_write)

# ---- upload-to-db ------------------------------------------------------------

result_write <- REDCapR::redcap_write(
  ds_to_write                = ds_slim,
  redcap_uri                 = credential_catalog$redcap_uri,
  token                      = credential_catalog$token,
  batch_size                 = 500 # Decrease if it helps debugging write errors
)
# result_write
