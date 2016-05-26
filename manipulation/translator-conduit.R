# knitr::stitch_rmd(script="./manipulation/te-ellis.R", output="./manipulation/stitched-output/te-ellis.md")
# For a brief description of this file see the presentation at
#   - slides: https://rawgit.com/wibeasley/RAnalysisSkeleton/master/documentation/time-and-effort-synthesis.html#/
#   - code: https://github.com/wibeasley/RAnalysisSkeleton/blob/master/documentation/time-and-effort-synthesis.Rpres
rm(list=ls(all=TRUE))  #Clear the variables from previous runs.

# ---- load-sources ------------------------------------------------------------
# Call `base::source()` on any repo file that defines functions needed below.  Ideally, no real operations are performed.
source("./manipulation/translator.R") #Loads `mplus_generator_bivariate()`

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
path_credential         <- "./data/unshared/security/phi-free.credentials"
path_prototype          <- "./manipulation/translator-support/prototype-wide.inp"

survey_ids_to_retain <- c(5L, 25L:26L)

# ---- load-data ---------------------------------------------------------------

# Read the credentials
credential_catalog <- REDCapR::retrieve_credential_local(path_credential, project_id=447) #For the catalog

# Retrieve from the catalog (pre-conference survey)
ds_catalog <- REDCapR::redcap_read(redcap_uri=credential_catalog$redcap_uri, token=credential_catalog$token)$data

rm(path_credential)

# ---- tweak-data --------------------------------------------------------------
# OuhscMunge::column_rename_headstart(ds_pcs) #Spit out columns to help write call ato `dplyr::rename()`.
ds_translate <- ds_catalog %>%
  dplyr::rename_(
  ) %>%
  dplyr::mutate(
    # investigation                                            = factor(investigation, levels=investigation_levels, labels=investigation_labels)
  ) %>%
  dplyr::filter(
    pcs_id      %in%  survey_ids_to_retain
  )

table(nchar(ds_translate$header_names), useNA = "always")
table(!is.na(ds_translate$header_names),  (nchar(ds_translate$header_names)>0) )

# ---- create-syntax -----------------------------------------------------------

testit::assert("The syntax template file should be found.", file.exists(path_prototype))

syntaxes <- rep(NA_character_, nrow(ds_translate))
for( i in seq_len(nrow(ds_translate)) ) { # i <- 193
  message("Creating syntax for ", ds_translate$model_tag[i], " in row ", i, ".")

  # testit::assert("The `header_names` field should be nonmissing.",  all(!is.na(ds_translate$header_names)))
  header_names_vector <- strsplit(ds_translate$header_names, split="\\s")

  syntax <- mplus_generator_bivariate(
    prototype                    = path_prototype                          # point to the template
    , saved_location             = dirname(ds_translate$path_inp[i])                 # where to store all the .inp/.out scripts
    , process_a_mplus            = ds_translate$process_a_stem[i]                    # item name of process (A)
    , process_b_mplus            = ds_translate$process_b_stem[i]                    # item name of process (B)
    , subgroup_sex               = ds_translate$subgroup[i]                          # subset data to members of this group
    , subset_condition_1         = ds_translate$mplus_filter_1[i]                    # subset data to member of this group
    , covariate_set              = ds_translate$covariate_set[i]       # list of covariates ("_c" stands for "centercd)
    , wave_set_modeled           = ds_translate$waves_intersect[i]                             # Integer vector of waves considered by the model, ie c(1,2,3,5,8).
    , header_names_vector        = header_names_vector[i]
  ) # execute to generate script

  syntaxes[i] <- syntax
}
ds_translate$mplus_syntax  <- syntaxes

# as.data.frame(ds_translate[193, ])

# ---- verify-values -----------------------------------------------------------

testit::assert("All model syntax should be at least 500 characters.", all(nchar(ds_translate$mplus_syntax) >= 500L))


# ---- specify-columns-to-upload -----------------------------------------------
# dput(colnames(ds_translate))
columns_to_write <-c(
  "record_id","path_inp", "mplus_syntax"
)
ds_slim <- ds_translate[, columns_to_write]

rm(columns_to_write)

# ---- upload-to-db ------------------------------------------------------------
# readr::write_csv(ds_slim, "./data-unshared/derived/3t.csv")
# ds_pull <- REDCapR::redcap_read(
#   redcap_uri                 = credential$redcap_url,
#   token                      = credential$token
# )$data

# setdiff(colnames(ds_pull), colnames(ds_slim)) #Columns missing from local dataset ds_slim (that are in REDCap)
# setdiff(colnames(ds_slim), colnames(ds_pull)) #Columns missing from REDCap (that are in ds_slim)

cat(ds_translate$mplus_syntax[1]) # check

result_write <- REDCapR::redcap_write(
  ds_to_write                = ds_slim,
  redcap_uri                 = credential_catalog$redcap_uri,
  token                      = credential_catalog$token,
  batch_size                 = 500 # Descrease if it helps debugging write errors
)
# result_write
