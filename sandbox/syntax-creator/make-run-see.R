options(width=160)
rm(list=ls())
cat("\f")

library(dplyr)
library(tidyr)
library(ggplot2)


pathRoot <- getwd()
pathFolder <- file.path(pathRoot,"sandbox/syntax-creator/outputs")



#e.g pc_TAU_00 <- c("pc_TAU_00_est", "pc_TAU_00_se", "pc_TAU_00_wald", "pc_TAU_00_pval")
source("./sandbox/syntax-creator/group-variables.R") # selected_results
# load functions that generate scripts
source("./sandbox/syntax-creator/functions-to-generate-Mplus-scripts.R")
# load functions that process the output files and create a summary dataset
source("./sandbox/syntax-creator/extraction-functions.R")



# create a object with main_theme definition
source("./scripts/graphs/main-theme.R")
# load graphical function
source("./scripts/graphs/kb-profiles-functions.R")


# point to  the folder with datasets containing model results

run_models_on <- FALSE # TRUE - run models, FALSE - only create script





## Run the lines above to load the needed functions
## Execute script snippets for each pair individually below this


############################################################ GRIP #####
## @knitr dummy_1
# Use the first example as the template for further pairs
# from "./sandbox/syntax-creator/functions_to_generate_Mplus_scripts.R"
make_script_waves(
  prototype = "sandbox/syntax-creator/prototype-map-wide.inp"
  ,place_in = "sandbox/syntax-creator/outputs/grip-numbercomp"
  ,process_a_name = "grip" # measure name
  ,process_a_mplus = "gripavg" # Mplus variable
  ,process_b_name = 'numbercomp'# measure name
  ,process_b_mplus = 'cts_nccrtd'# Mplus variable
  ,subgroup_sex = "male" #
  ,covariates = "Bage Educ Height"
  ,wave_set_possible = c(1,2,3,4,5,6,7)  #Integer vector of the possible waves of the study, ie 1:16,
  ,wave_set_modeled =  c(1,2,3,4,5)   #Integer vector of waves considered by the model, ie c(1,2,3,5,8).
  ,waves_min = 5
  ,waves_max = 5
  ,run_models = TRUE
) # generate mplus scripts from a prototype, estimate (run_models=TRUE)


# from "./sandbox/syntax-creator/extraction_functions.R  script
# collect_model_results(folder = "./sandbox/syntax-creator/outputs/grip_digitsymbols") # collect and save into the same folder
# ds <- readRDS(paste0(pathFolder,".rds")) # load the data for outcome pair
# from "./scripts/graphs/koval_brown_profiles.R"
# kb_profiles(ds,  vertical="wave_count",  border=5) # produces the kb_profile graph




#### Grip - Boston Naming Task ####

# from "./sandbox/syntax-creator/extraction_functions.R  script
collect_model_results(folder = "outputs/pairs/grip_bnt") # collect and save into the same folder
ds <- readRDS(file.path(pathFolder,"grip_bnt.rds")) # load the data for outcome pair
# from "./scripts/graphs/koval_brown_profiles.R"
kb_profiles(ds,  vertical="wave_count",  border=5) # produces the kb_profile graph





