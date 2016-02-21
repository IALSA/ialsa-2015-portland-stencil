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
                              prototype, # = "sandbox/syntax-creator/prototype_map_wide.inp",
                              place_in, # = "sandbox/syntax-creator/outputs/grip_numbercomp",
                              processP_name = "grip", # goes into the name of the file
                              processP = "gripavg", # goes into the mplus script
                              processC_name = 'digitsymbols',
                              covariates = "a",
                              processC = 'cts_catflu',
                              subgroup_sex,
                              wave_set_possible,# = c(1,2,3,4,5,6,7),  #Integer vector of the possible waves of the study, ie 1:16,
                              wave_set_modeled,# = c(1,2,3,4,5),   #Integer vector of waves considered by the model, ie c(1,2,3,5,8).
                              waves_min = "5",
                              waves_max = "5",
                              run_models = FALSE){


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

  waves <- as.character(c(waves_min:waves_max))
  for(wave in waves){


    # after modification .inp files will be saved as:
    newFile <- paste0(outFolder,"/", subgroup_sex ,"_", wave,".inp")


    # browser()

    # TITLE:
    # DATA:
    # File = wide_dataset.dat; # automatic object, created by `look-at-data.R`
    # VARIABLE:
    # Names are # define the variabels used in the analysis
    names_are <- read.csv(pathVarnames,header = F, stringsAsFactors = F)[ ,1]
    names_are <- paste(names_are, collapse="\n") #Collapse all the variable names to one element (seperated by line breaks).
    proto_input <- gsub(pattern = "%names_are%", replacement = names_are, x = proto_input)
    # Usevar are # what variables are used in estimation

    estimated_timepoints <- paste0("time",1:wave_modeled_max)
    estimated_timepoints <- paste(estimated_timepoints, collapse="\n")
    proto_input <- gsub(pattern ="%estimated_timepoints%", replacement = estimated_timepoints, x = proto_input)

#
#     process_a_timepoints <- paste0("a", 1:wave_modeled_max)
#     process_b_timepoints <- paste0("b", 1:wave_modeled_max)
#     usevar_are <- rbind(estimated_timepoints, process_a_timepoints, process_b_timepoints)
#     usevar_are <- paste(usevar_are, collapse="\n")
#     proto_input <- gsub(pattern ="%estimated_timepoints%", replacement = usevar_are, x = proto_input)
#     # Tscores are # define the time points
    # Useobservations are # select a subset of observation
    proto_input <- gsub("msex EQ %subgroup_sex%", paste0("msex EQ ",subgroup_sex), proto_input)
    # DEFINE:
    # ANALYSIS:
    # MODEL:
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



    } #close wave loop
  # } #close sex loop
  # run_models <- TRUE
  if(run_models){
  # run all models in the folder
  MplusAutomation::runModels(directory=outFolder )#, Mplus_command = Mplus_install_path)
  }
} # close function



