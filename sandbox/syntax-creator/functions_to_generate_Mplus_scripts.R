# ## This script
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
                              # gender,
                              # wave_set_possible,  #Integer vector of the possible waves of the study, ie 1:16,
                              # wave_set_modeled,   #Integer vector of waves considered by the model, ie c(1,2,3,5,8).
                              waves_min = "4",
                              waves_max = "18",
                              waves_all = "21",
                              run_models = FALSE){

  # get a the prototypical model script
  # pathFile <- "./scripts/mplus/prototype/prototype_b1_RADC.inp"
  pathFile <- paste0(pathRoot,"/",prototype)
  # point to the folder where new files should go to
  outFolder <- paste0(pathRoot,"/",place_in)
  pathVarnames <- paste0(pathRoot,"/",place_in,"/variable_names.txt")

# browser()




   gender <- c("male",'female')
  for(sex in gender){  #This loop will be replaced by parameter value (and the function called for each gender).

    waves <- as.character(c(waves_min:waves_max))
    for(wave in waves){  #This loop will be replaced by parameter value (and the function called for each wave *set*.).

      # newFile <-  "./scripts/mplus/prototype/new_b1_male_a_grip_categories_18.inp"
      newFile <- paste0(outFolder,"/","b1","_", sex ,"_",covariates,"_",processP_name,"_",processC_name,"_",wave,".inp")

      proto_input <- scan(pathFile, what='character', sep='\n')

      #This makes it all one (big) element, if you need it in the future.
      # proto_input <- paste(proto_input, collapse="\n")

# browser()

      names_are <- read.csv(pathVarnames,header = F, stringsAsFactors = F)[ ,1]
      names_are <- paste(names_are, collapse="\n") #Collapse all the variable names to one element (seperated by line breaks).
      proto_input <- gsub(pattern = "%names_are%", replacement = names_are, x = proto_input)


      line_found <- (grep("!define the variables used in the analysis", proto_input))
      proto_input[line_found+1] <- gsub("time%wave_max%", paste0("time",wave), proto_input[line_found+1])
      proto_input[line_found+2] <- gsub("p%wave_max%",    paste0("p",wave), proto_input[line_found+2])
      proto_input[line_found+3] <- gsub("c%wave_max%",    paste0("c",wave), proto_input[line_found+3])


      line_found <- (grep("!define the time points", proto_input))
      proto_input[line_found+1] <- gsub("time%wave_max%", paste0("time",wave),  proto_input[line_found+1])


      line_found <- (grep("!select a subset of observations", proto_input))
      if(sex=="male"){
            print_sex_value <- paste0("msex EQ 1")}else{
            print_sex_value <- paste0("msex EQ 0")
            }
      proto_input[line_found+1] <- gsub("msex EQ %subgroup_sex%", print_sex_value, proto_input[line_found+1])


      line_found <- (grep("!assign variables to the process p", proto_input))
      for(i in 1:21){
        proto_input[line_found+i] <- gsub("processP", processP, proto_input[line_found+i])
      }


      line_found <- (grep("!assign variables to the process c", proto_input))
      for(i in 1:21){
        proto_input[line_found+i] <- gsub("processC", processC, proto_input[line_found+i])
      }


      line_found <- (grep("! define the second-level terms", proto_input))


      #After the `proto_input` is one big element, this should replace all the lines below it.
      # proto_input <- gsub("%wave_max%",    wave_max, proto_input)

      line_found <- (grep("!first-level equation", proto_input))
      proto_input[line_found+1] <- gsub("p%wave_max%",    paste0("p",wave), proto_input[line_found+1])
      proto_input[line_found+1] <- gsub("time%wave_max%", paste0("time",wave), proto_input[line_found+1])
      proto_input[line_found+2] <- gsub("c%wave_max%",    paste0("c",wave), proto_input[line_found+2])
      proto_input[line_found+2] <- gsub("time%wave_max%", paste0("time",wave), proto_input[line_found+2])


      line_found <- (grep("!define the second-level terms", proto_input))


      line_found <- (grep("!residual means", proto_input))
      proto_input[line_found+1] <- gsub("p%wave_max%", paste0("p",wave), proto_input[line_found+1])
      proto_input[line_found+2] <- gsub("c%wave_max%", paste0("c",wave), proto_input[line_found+2])


      line_found <- (grep("!Paired covariances constrained to be equal across t", proto_input))
      proto_input[line_found+1] <- gsub("p%wave_max%", paste0("p",wave), proto_input[line_found+1])
      proto_input[line_found+1] <- gsub("c%wave_max%", paste0("c",wave), proto_input[line_found+1])

      proto_input <- gsub("%covariates%", covariates, proto_input)

      writeLines(proto_input,newFile)



    } #close wave loop
  } #close sex loop
  # run_models <- TRUE
  if(run_models){
  # run all models in the folder
  MplusAutomation::runModels(directory=outFolder )#, Mplus_command = Mplus_install_path)
  }
} # close function



