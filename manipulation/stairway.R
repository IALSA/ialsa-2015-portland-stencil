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

requireNamespace("readr")
requireNamespace("dplyr") #Avoid attaching dplyr, b/c its function names conflict with a lot of packages (esp base, stats, and plyr).
requireNamespace("testit") #For asserting conditions meet expected patterns.

# ---- declare-globals ---------------------------------------------------------
path_credential <- "./data/unshared/security/phi-free.credentials"
desired_columns <- c("record_id", "model_tag", "path_out", "mplus_output", "ascension_datetime")

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
    !is.na(path_out)
    & (is.na(mplus_output) | nchar(mplus_output)==0L) #Comment out to upload everyone instead of just for the missing rows.
  ) %>%
  dplyr::mutate(
    file_out_exists     = file.exists(path_out)
  )

# ---- identify-missing-outputs -----------------------------------------------------------
if( any(!ds_catalog$file_out_exists) ) {
  missing_files <- paste(ds_catalog$path_out[!ds_catalog$file_out_exists], collapse="\n")
  cat(missing_files)
  warning("The previous ", scales::comma(sum(!ds_catalog$file_out_exists)), " output files are missing and will not ascend.")
}

#The files to raise up into REDCap
ds_confer <- ds_catalog %>%
  dplyr::filter(file_out_exists)

# ---- read-output -----------------------------------------------------------

outputs <- rep(NA_character_, nrow(ds_confer))
for( i in seq_len(nrow(ds_confer)) ) { #i <- 1
  message("Confering model ", ds_confer$model_tag[i])

  # output <-
  # outputs[i] <- gsub("\\r\\n", "\\\n", readr::read_file(ds_confer$path_out[i]))
  outputs[i] <- paste(readr::read_lines(ds_confer$path_out[i]), collapse="\n")
}

ds_confer <- ds_confer %>%
  dplyr::mutate(
    mplus_output                =  outputs,
    ascension_datetime          =  Sys.time()
  )

# readr::read_file(ds_confer$path_out[1])
# readr::read_file(ds_confer$path_out[2])
# paste(readr::read_lines(ds_confer$path_out[1]), collapse="\n")
# # readr::read_file(ds_confer$path_out[3])
#
#
# #The files to raise up into REDCap
# ds_confer <- ds_catalog %>%
#   dplyr::filter(file_out_exists) %>%
#   dplyr::mutate(
#     mplus_output = paste(readr::read_lines(path_out), collapse="\n")
#     # mplus_output = readr::read_file(file.path(R.home(), "COPYING"))#read_file(path_out)
#   )


# ---- verify-values -----------------------------------------------------------
testit::assert("All model output should be at least 500 characters.", all(nchar(ds_confer$mplus_output) >= 500L))


# ---- specify-columns-to-upload -----------------------------------------------
# dput(colnames(ds_catalog))
columns_to_write <-c(
  "record_id","mplus_output", "ascension_datetime"
)
ds_slim <- ds_confer[, columns_to_write]

rm(columns_to_write)

# ---- upload-to-db ------------------------------------------------------------

result_write <- REDCapR::redcap_write(
  ds_to_write                = ds_slim,
  redcap_uri                 = credential_catalog$redcap_uri,
  token                      = credential_catalog$token,
  batch_size                 = 500 # Decrease if it helps debugging write errors
)
# result_write
