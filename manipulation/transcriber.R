# The function of this report is to print the input file to be used in estimation.


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
path_credential <- "./data/unshared/security/phi-free.credentials"
path_prototype          <- "./manipulation/translator-support/prototype-wide.inp"

survey_ids_to_retain <- c(5L)

desired_fields <- c("record_id","path_inp", "mplus_syntax") #Get other stuff like path_syntax

#Factors from REDCap
# investigations_to_run <- c("ELSA")
# investigation_labels  <- c("EAS", "ELSA", "HRS", "ILSE", "LASA", "MAP", "NUAGE", "OCTO", "SATSA")

# ---- load-data ---------------------------------------------------------------

# Read the credentials
credential_catalog <- REDCapR::retrieve_credential_local(path_credential, project_id=447) #For the catalog

# Retrieve from the catalog.
ds_catalog <- REDCapR::redcap_read(
  redcap_uri=credential_catalog$redcap_uri,
  token=credential_catalog$token,
  fields = desired_fields
  )$data


rm(path_credential)

# ---- tweak-data --------------------------------------------------------------
# OuhscMunge::column_rename_headstart(ds_pcs) #Spit out columns to help write call ato `dplyr::rename()`.
ds <- ds_catalog %>%
  dplyr::rename_(
  ) %>%
  dplyr::mutate(
    # investigation                                            = factor(investigation, levels=investigation_levels, labels=investigation_labels)
  ) %>%
  dplyr::filter(
    # survey_id      %in%  survey_ids_to_retain
  )



# ---- save-syntax-to-file -----------------------------------------------------------
# for( i in seq_len(nrow(ds)) ) { #i <- 1
for( i in 1:10) { #i <- 1
  message("Creating syntax for ", ds$model_tag[i])
  writeLines(ds$mplus_syntax[i], ds$path_inp[i])
  }

# ---- verify-values -----------------------------------------------------------

testit::assert("All model syntax should be at least 500 characters.", all(nchar(ds$mplus_syntax) >= 500L))


# ---- specify-columns-to-upload -----------------------------------------------
# Nothing to upload

# ---- upload-to-db ------------------------------------------------------------
# Nothing to upload
