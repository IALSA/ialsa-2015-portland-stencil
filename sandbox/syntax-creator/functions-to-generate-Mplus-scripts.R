# ## This script declares the functions that generate Mplus .inp file used in model fitting.
# options(width=160)
# rm(list=ls())
# cat("\f")
#
# ## @knitr load_packages
# library(dplyr)
# library(ggplot2)
# library(tidyr)
# library(IalsaSynthesis)
#
# processP = "grip"
# processC = "digit_symbols"
# covariates = "a"

make_script_waves <- function(
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
                              ,run_models = FALSE
                              ){


## Define paths to files and folders
  pathFile <- paste0(pathRoot,"/",prototype) # the proto input dummy
  outFolder <- paste0(pathRoot,"/",place_in) # all generated scripts will go here
  # point to the file containing the names of the variables in wide_dataset.dat;
  pathVarnames <- paste0(pathRoot,"/",place_in,"/wide-variable-names.txt")
# browser()
  proto_input <- scan(pathFile, what='character', sep='\n')
  #This makes it all one (big) element, if you need it in the future.
  # proto_input <- paste(proto_input, collapse="\n")
  # declare global values
  wave_modeled_max <- max(wave_set_modeled)


  # after modification .inp files will be saved as:
  newFile <- paste0(outFolder,"/", subgroup_sex ,"_", wave_modeled_max,".inp")


  # browser()

  # TITLE:
  # DATA:
  # File = wide_dataset.dat; # automatic object, created by `look-at-data.R`
  # VARIABLE:
  # Names are # define the variabels used in the analysis
  names_are <- read.csv(pathVarnames,header = F, stringsAsFactors = F)[ ,1]
  names_are <- paste(names_are, collapse="\n") #Collapse all the variable names to one element (seperated by line breaks).
  names_are <- stringr::str_wrap(str = names_are, width  = 80, exdent = 4)
  proto_input <- gsub(pattern = "%names_are%", replacement = names_are, x = proto_input)
  # Usevar are # what variables are used in estimation

  estimated_timepoints <- paste0("time",wave_set_modeled)
  estimated_timepoints <- paste(estimated_timepoints, collapse="\n")
  proto_input <- gsub(pattern ="%estimated_timepoints%", replacement = estimated_timepoints, x = proto_input)

  process_a_timepoints <- paste0("a",wave_set_modeled)
  process_a_timepoints <- paste(process_a_timepoints, collapse="\n")
  proto_input <- gsub(pattern ="%process_a_timepoints%", replacement = process_a_timepoints, x = proto_input)

  process_b_timepoints <- paste0("b",wave_set_modeled)
  process_b_timepoints <- paste(process_b_timepoints, collapse="\n")
  proto_input <- gsub(pattern ="%process_b_timepoints%", replacement = process_b_timepoints, x = proto_input)
  # Tscores are # define the time points
  proto_input <- gsub(pattern ="%process_b_timepoints%", replacement = process_b_timepoints, x = proto_input)

  # Useobservations are # select a subset of observation
  if(subgroup_sex=="male"){
    print_sex_value <- paste0("msex EQ 1")}else{
      print_sex_value <- paste0("msex EQ 0")
    }
  proto_input <- gsub("msex EQ %subgroup_sex%", paste0("msex EQ ",print_sex_value), proto_input)
  # DEFINE:

  (match_timepoints_process_a <- paste0("a",wave_set_modeled,"=",process_a_mplus,"_",wave_set_modeled,";"))
  match_timepoints_process_a <- paste(match_timepoints_process_a, collapse="\n")
  proto_input <- gsub(pattern ="%match_timepoints_process_a%", replacement = match_timepoints_process_a, x = proto_input)

  (match_timepoints_process_b <- paste0("b",wave_set_modeled,"=",process_b_mplus,"_",wave_set_modeled,";"))
  match_timepoints_process_b <- paste(match_timepoints_process_b, collapse="\n")
  proto_input <- gsub(pattern ="%match_timepoints_process_b%", replacement = match_timepoints_process_b, x = proto_input)

  (match_time_since_bl <- paste0("time",wave_set_modeled,"=", "time_since_bl","_",wave_set_modeled,";"))
  match_time_since_bl <- paste(match_time_since_bl, collapse="\n")
  proto_input <- gsub(pattern ="%match_timepoints%", replacement = match_time_since_bl, x = proto_input)




  # ANALYSIS:
  # MODEL:
  proto_input <- gsub(pattern ="%waves_max%", replacement = wave_modeled_max, x = proto_input)

  # MODEL CONSTRAINT:
  # OUTPUT:
  # PLOT:
  #
  #       wave_set_possible <- c(1,2,3)
  #       wave_set <- paste0("time",wave_set_possible)
  #
  # proto_input <- gsub("%waves_max%",    waves_max, proto_input)
  proto_input <- gsub("%covariates%", covariates, proto_input)







#
#       line_found <- (grep("!assign variables to the process p", proto_input))
#       for(i in 1:21){
#         proto_input[line_found+i] <- gsub("processP", processP, proto_input[line_found+i])
#       }
#
#
#       line_found <- (grep("!assign variables to the process c", proto_input))
#       for(i in 1:21){
#         proto_input[line_found+i] <- gsub("processC", processC, proto_input[line_found+i])
#       }




      writeLines(proto_input,newFile)



    # } #close wave loop
  # } #close sex loop
  # run_models <- TRUE
  if(run_models){
  # run all models in the folder
  MplusAutomation::runModels(directory=outFolder )#, Mplus_command = Mplus_install_path)
  }
} # close function



