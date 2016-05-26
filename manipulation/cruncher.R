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
requireNamespace("MplusAutomation") #devtools::install_github(repo="michaelhallquist/MplusAutomation")
requireNamespace("REDCapR") #devtools::install_github(repo="OuhscBbmc/REDCapR")

requireNamespace("scales")
requireNamespace("dplyr") #Avoid attaching dplyr, b/c its function names conflict with a lot of packages (esp base, stats, and plyr).
requireNamespace("testit") #For asserting conditions meet expected patterns.

# ---- declare-globals ---------------------------------------------------------
path_credential           <- "./data/unshared/security/phi-free.credentials"
# path_prototype          <- "./manipulation/translator-support/prototype-wide.inp"

desired_columns <- c("record_id", "model_tag", "path_inp", "mplus_syntax", "mplus_output") #"path_out",

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
ds_catalog <- ds_catalog %>%
  dplyr::rename_(
  ) %>%
  dplyr::filter(
    !is.na(mplus_syntax) & is.na(mplus_output)
  ) %>%
  dplyr::mutate(
    file_inp_exists     = file.exists(path_inp),
    directory           = dirname(path_inp),
    file_name_regex     = gsub("\\.", "\\\\\\\\.", basename(path_inp)) #Escape all dots, for the sake of the regex.
  )

# ---- identify-missing-inputs -----------------------------------------------------------
if( any(!ds_catalog$file_inp_exists) ) {
  missing_files <- paste(ds_catalog$path_inp[!ds_catalog$file_inp_exists], collapse="\n")
  cat(missing_files)
  warning("The previous ", scales::comma(sum(!ds_catalog$file_inp_exists)), " input files are missing and will not be run.")
}

ds_crunch <- ds_catalog %>%
  dplyr::filter(file_inp_exists)

# ---- crunch ------------------------------------------------------------------
for( i in seq_len(nrow(ds_crunch)) ) { #i <- 1
  message("Crunching model ", ds_crunch$model_tag[i])

  MplusAutomation::runModels(
    directory     = ds_crunch$directory[i],
    filefilter    = ds_crunch$file_name_regex[i]
  )
}

# ---- verify-values -----------------------------------------------------------


# ---- specify-columns-to-upload -----------------------------------------------
# nothing to upload

# ---- upload-to-db ------------------------------------------------------------
# nothing to upload
