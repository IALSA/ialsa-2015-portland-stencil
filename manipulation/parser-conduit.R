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

    ds_results_list[[i]] <- parse(path_temp_out)

  },
  finally={
    unlink(path_temp_out) #Delete the temp file, regardless if the parse operation succeedes
  })
}

# ---- unify-dataset -----------------------------------------------------------
ds_results <- ds_results_list %>%
  dplyr::bind_rows() %>%
  dplyr::mutate(
    date    = as.Date(date, "%M/%d/%Y")
  )

# ---- verify-values -----------------------------------------------------------
# testit::assert("All model output should be at least 500 characters.", all(nchar(ds_confer$mplus_output) >= 500L))


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
