#Rename file to 'Prometheus'

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
path_credential_admin           <- "./data/unshared/security/user.credentials"
path_credential_low             <- "./data/unshared/security/phi-free.credentials"
path_out_archive_directory      <- "./data/unshared/archive/"
path_out_results                <- "./data/shared/model-results.csv"

# ---- load-data ---------------------------------------------------------------

is_admin <- file.exists(path_credential_admin)

# Read the credentials
if( is_admin ) {
  message(
    "Current user is recognized as admin.
    Prometheus will save the catalog as a live file
    and archive the catalog and PCS."
  )
  credential_pcs     <- REDCapR::retrieve_credential_local(path_credential_admin, project_id=262) #For the pre-conference survey
  # Retrieve from the PCS (pre-conference survey)
  ds_pcs <- REDCapR::redcap_read(redcap_uri=credential_pcs$redcap_uri, token=credential_pcs$token)$data
  rm(path_credential_admin, credential_pcs)
} else {
  message(
    "Current user is recognized as non-admin.
    Prometheus will save the catalog as a live file,
    but will not archive the catalog and PCS."
  )
}

credential_catalog <- REDCapR::retrieve_credential_local(path_credential_low  , project_id=447) #For the catalog
# Retrieve from the catalog.
ds_catalog <- REDCapR::redcap_read(
  redcap_uri    = credential_catalog$redcap_uri,
  token         = credential_catalog$token,
  # Get all fields
  batch_size    = 200
  )$data

rm(path_credential_low, credential_catalog)

# ---- tweak-data --------------------------------------------------------------
# OuhscMunge::column_rename_headstart(ds_pcs) #Spit out columns to help write call ato `dplyr::rename()`.

# ---- verify-values -----------------------------------------------------------
# testit::assert("All model syntax should be at least 500 characters.", all(nchar(ds$mplus_syntax) >= 500L))

# ---- save-to-disk ------------------------------------------------------------
timestamp <- strftime(Sys.time(), format="%Y-%m%-%d--%H-%M-%S")
if( is_admin ) {
  readr::write_csv(ds_pcs    , path=paste0(path_out_archive_directory, "pcs-"    , timestamp, ".csv"))
  readr::write_csv(ds_catalog, path=paste0(path_out_archive_directory, "catalog-", timestamp, ".csv"))
}
readr::write_csv(ds_catalog, path=path_out_results) #This is the live version
rm(timestamp, path_out_archive_directory, path_out_results)
