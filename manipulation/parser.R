# this script contains the definitions of the functions that extract the results of model estimation
# folder = "./sandbox/syntax-creator/outputs/grip-numbercomp/"
parse <- function( record_id, path_temp_out ){

  if( !file.exists(path_temp_out) ) stop("The temp output file does not exist: `", path_temp_out, "`.")
  # collect a vector with .out file paths

  mplus_output <- readr::read_file(path_temp_out)
  # the script `group-variables.R` creates objects with names of standard variables for easier handling
  #e.g ab_TAU_00 <- c("ab_TAU_00_est", "ab_TAU_00_se", "ab_TAU_00_wald","ab_TAU_00_pval")
  source("./sandbox/syntax-creator/group-variables.R")

  # I. EXTRACTION
  #
  # I.A. Extract Model Summaries
  # create a dataset with model summaries
  get_msum <- function(){
    ## Declare the model descriptors we wish to record:
    msum_names <- c("Mplus.version",
                    "Title",
                    "AnalysisType",
                    "Estimator",
                    "Observations",
                    "Parameters",
                    "LL","AIC","BIC","aBIC","AICC",
                    "Filename", "filePath")
    # Create data frame to populated from model output files
    msum <- data.frame(matrix(ncol=length(msum_names)))
    names(msum) <- msum_names # columns is what we want to extract from MplusAutomation::extractModelSummaries()
    msum

    # get a single model summary
    ith_msum <- MplusAutomation::extractModelSummaries(target=path_temp_out, recursive=T)
    # LOGICAL: is this descriptor present in the current model?
    (descriptor_exists <- names(ith_msum) %in% msum_names)
    # names of descriptors that exist in ith model
    (existing_descriptors <- names(ith_msum)[descriptor_exists])
    # populate existing fields
    msum[1, existing_descriptors] <- ith_msum[names(ith_msum) %in% msum_names]
    msum$filePath <- path_temp_out # attach the file path directly from the observed list

    #       # add the filename for identification
    #       (a <- strsplit(msum$filePath[1], split="/")) # each subfolder into a char value
    #       selector <- a[[1]] %in% c("studies") # find which one says "studies"
    #       element_number <- c(1:length(selector))[selector] # get its number
    #       msum$study_name[1] <- a[[1]][element_number+1] # move one step to the right

    # add the file path to locate for debugging
    # (a <- strsplit(msum$filePath[1], split="/studies/")) # common folder
    #       msum$file_path[1] <- a # move one step to the right

    return(msum)
  } # close function
  msum <- get_msum()

  # I.B. Extract Model Parameters
  # create a list which elements are datasets containing estimated coefficients
  get_mpar <- function(){
    mpar <- list()  # Create list object to populated from model output files


    out_file <-  tail(strsplit(path_temp_out,"/")[[1]], n=1)  # grab an output file to work with
    message("Getting model ", path_temp_out) # view the file name
    mplus_output <- scan(path_temp_out, what='character', sep='\n') # each line of output as a char value
    # testing for specific errors
    no_observations <- length(grep("One or more variables in the data set have no non-missing values", mplus_output))
    variance_zero <- length(grep("One or more variables have a variance of zero", mplus_output))
    # If there are no specific error, then go get the parameter solution
    if(no_observations){
      mpar  <- "No observations"
    }else if(variance_zero){
      mpar  <- "Zero variance"
    }else{
      mpar <- MplusAutomation::extractModelParameters(target=path_temp_out, recursive=T, dropDimensions=T)
    }

    return(mpar)
  }
  mpar <- get_mpar()

  # II.ASSEMBLY
  # using (msum, mpar)  and custom parsing, populate the result mold (catalog-4)
  #
  # create empty dataset "results" that will be later populated with extracted values
  # selected_results is declared in group-variables.R script
  results <- data.frame(matrix(NA, ncol=length(selected_results), nrow=1L)) # length(mpar) = number of output files
  names(results) <-  selected_results
  results$record_id  <- record_id

  # browser()

  # II.A. Basic Results
  # extract the basic indicators about the model
  get_results_basic <- function( ) {
    (out_file <-  tail(strsplit(path_temp_out,"/")[[1]], n=1)) # grab an output file to work with
    message("Getting model ", 1, ", ",out_file)# view the file name
    mplus_output <- scan(path_temp_out, what='character', sep='\n') # each line of output as a char value
    (model <- mpar[[1]])# load the extract of this model's estimates
    # testing for specific errors
    (no_observations <- length(grep("One or more variables in the data set have no non-missing values", mplus_output)))
    (variance_zero <- length(grep("One or more variables have a variance of zero", mplus_output)))
    # If there are no specific error, then go get the parameter solution
    if(no_observations){
      results[1, "Error"]  <- "No observations"
    }else if(variance_zero){
      results[1,"Error"]  <- "Zero variance"
    } else {

      ## Populate admin variables
      results[1, 'software'] <- mplus_output[1]
      results[1,"version"] <- "0.1"
      results[1, c('date', 'time')] <- strsplit(mplus_output[3], '  ')[[1]]
      results[1,"data_file"] <- strsplit(mplus_output[grep("File", mplus_output, ignore.case=TRUE)], 'IS| is |=|;')[[1]][2]
      results[1, 'output_file'] <- msum[1, 'Filename']
      results[1, "file_path"] <- msum[1,"filePath"]

      ## Populate model_id variables
      # results[1,"study_name"] <- msum$study_name[1]
      # results[1,c("model_number", 'subgroup',  'model_type')] <- strsplit(msum$Filename[1], '_')[[1]][1:3]

      process_a_name = 'grip'
      process_b_name = 'numbercomp'
      subgroup_sex = "male"
      model_type = "aeh" # = must be defined programmatically, by the scan of covariates

      results[1, "process_a"] <- process_a_name # ARGUMENTS DEFINED IN mplus_generator_bivariate()
      results[1, "process_b"] <- process_b_name # ARGUMENTS DEFINED IN mplus_generator_bivariate()
      results[1, "subgroup_sex"] <- subgroup_sex # ARGUMENTS DEFINED IN mplus_generator_bivariate()
      results[1, "model_type"] <- model_type

      ## Populate model_info variables
      results[1, 'subject_count'] <- msum[1, 'Observations'] # verify this, maybe datapoints, not subjects
      results[1, 'parameter_count'] <- msum[1, 'Parameters']

      (subject <- model[model$paramHeader=='Intercepts', 'param'])
      (results[1, 'wave_count'] <- max(as.numeric(gsub("[^0-9]", '', subject)), na.rm=T)) # MUST CHANGE. COUNTS THE HIGHEST NUMBER, BUT RATHER MUST COUNT THE COUNT OF WAVES
      (results[1, c('LL')] <-  msum[1,c('LL')])
      (results[1, c('aic')] <-  msum[1,c('AIC')])
      (results[1, c('bic')] <-  msum[1,c('BIC')])
      (results[1, c('adj_bic')] <-  msum[1,c('aBIC')])
      (results[1, c('aaic')] <-  msum[1,c('AICC')])
      ## Computed values

    } # close else
    return(results)
  } # close get_results_basic
  results <- get_results_basic()


  # II.B. Catching Errors
  # records all relevant errors and warnings about model estimation produced by Mplus
  get_results_errors <- function(){

    (out_file <-  tail(strsplit(path_temp_out,"/")[[1]], n=1)) # grab an output file to work with
    message("Getting model ", 1, ", ",out_file)# view the file name
    mplus_output <- scan(path_temp_out, what='character', sep='\n') # each line of output as a char value
    # testing for specific errors
    (no_observations <- length(grep("One or more variables in the data set have no non-missing values", mplus_output)))
    (variance_zero <- length(grep("One or more variables have a variance of zero", mplus_output)))
    # If there are no specific error, then go get the parameter solution
    if(no_observations){
      results[1, "Error"]  <- "No observations"
    } else if(variance_zero){
        results[1,"Error"]  <- "Zero variance"
    } else{

      ## Check for model convergence
      line_found <-  length(grep("THE MODEL ESTIMATION TERMINATED NORMALLY", mplus_output))
      results[1, 'has_converged'] <- line_found

      line_found <- length(grep("THE COVARIANCE COVERAGE FALLS BELOW THE SPECIFIED LIMIT", mplus_output))
      results[1,"covar_covered"] <- line_found

      line_found <- grep("TRUSTWORTHY FOR SOME PARAMETERS DUE TO A NON-POSITIVE DEFINITE", mplus_output)
      results[1,"trust_all"] <- !length(line_found)==1L

      line_found <- grep("PROBLEM INVOLVING THE FOLLOWING PARAMETER:", mplus_output)
      snippet <- mplus_output[line_found+1]
      if(length(snippet)>0){
        results[1,"mistrust"] <- snippet
      }
    } # close else

    return(results)
  } # close get_results_errors
  results <- get_results_errors()

  # III.A. Random Effects
  # record the extracted values of the estimated random effects
  get_results_random <- function(){
    model <- mpar[[1]] # load the extract of this model's estimates

    ## covariante btw intercept of process (A) and intercept of process (B) - ab_TAU_00
    # browser()
    (test <- model[grep(".WITH", model$paramHeader),]) # paramHeader containing .WITH
    (test <- test[grep("^I|S", test$param),]) # param starting with I or S
    (test <- test[grep("^I", test$paramHeader),]) # paramHeader starting with I
    (test <- test[grep("^I", test$param),]) # pram starting with I

    (test <- test[ ,c("est", "se","est_se", "pval")])
    if(dim(test)[1]!=0){results[1, ab_TAU_00] <- test}

    ## covariance btw slope of process (A) and slope of process (B) - ab_TAU_11
    (test <- model[grep(".WITH", model$paramHeader),]) # paramHeader containing .WITH
    (test <- test[grep("^I|S", test$param),]) # param starting with I or S
    (test <- test[grep("^S", test$paramHeader),]) # paramHeader starting with S
    (test <- test[grep("^S", test$param),]) # pram starting with S
    (test <- test[ ,c("est", "se","est_se", "pval")])
    if(dim(test)[1]!=0) {results[1, ab_TAU_11] <- test}

    ## covariance btw intercept of process (A) and slope of process (A) - aa_TAU_01
    (test <- model[grep(".WITH", model$paramHeader),]) # paramHeader containing .WITH
    (test <- test[grep("^IA|^SA", test$param),]) # param starting NOT with I or S
    (test <- test[grep("^IA|^SA", test$paramHeader),])
    (test <- test[ ,c("est", "se","est_se", "pval")])
    if(dim(test)[1]!=0){results[1, aa_TAU_01] <- test}

    ## covariance btw intercept of process (A) and slope of process (B) - ab_TAU_01
    (test <- model[grep(".WITH", model$paramHeader),]) # paramHeader containing .WITH
    (test <- test[grep("^IA|^SB", test$param),]) # param starting NOT with I or S
    (test <- test[grep("^IA|^SB", test$paramHeader),])
    (test <- test[ ,c("est", "se","est_se", "pval")])
    if(dim(test)[1]!=0){results[1, ab_TAU_01] <- test}

    ## covariance btw intercept of process (A) and slope of process (B) - ab_TAU_10
    (test <- model[grep(".WITH", model$paramHeader),]) # paramHeader containing .WITH
    (test <- test[grep("^IB|^SA", test$param),]) # param starting NOT with I or S
    (test <- test[grep("^IB|^SA", test$paramHeader),])
    (test <- test[ ,c("est", "se","est_se", "pval")])
    if(dim(test)[1]!=0){results[1, ab_TAU_10] <- test}

    ## covariance btw slope of process (B) and intercept of process (B) - bb_TAU_10
    (test <- model[grep(".WITH", model$paramHeader),]) # paramHeader containing .WITH
    (test <- test[grep("^IB|^SB", test$param),]) # param starting NOT with I or S
    (test <- test[grep("^IB|^SB", test$paramHeader),])
    (test <- test[ ,c("est", "se","est_se", "pval")])
    if(dim(test)[1]!=0){results[1, bb_TAU_10] <- test}

    ## Variance of random intercept of process (A) - aa_TAU_00
    (test <- model[grep("Residual.Variances", model$paramHeader),])
    (test <- test[test$param=='IA', ])
    (test <- test[ ,c("est", "se","est_se", "pval")])
    if(dim(test)[1]!=0) {results[1, aa_TAU_00] <- test}

    ## Variance of random slope of process (A) - aa_TAU_11
    (test <- model[grep("Residual.Variances", model$paramHeader),])
    (test <- test[test$param=='SA', ])
    (test <- test[ ,c("est", "se","est_se", "pval")])
    if(dim(test)[1]!=0) {results[1, aa_TAU_11] <- test}

    ## Variance of random intercept of process (B) - bb_TAU_00
    (test <- model[grep("Residual.Variances", model$paramHeader),])
    (test <- test[test$param=='IB', ])
    (test <- test[ ,c("est", "se","est_se", "pval")])
    if(dim(test)[1]!=0) {results[1,bb_TAU_00] <- test}

    ## Variance of random slope of process (B) - bb_TAU_11
    (test <- model[grep("Residual.Variances", model$paramHeader),])
    (test <- test[test$param=='SB', ])
    (test <- test[ ,c("est", "se","est_se", "pval")])
    if(dim(test)[1]!=0) {results[1, bb_TAU_11] <- test}

    return(results)
  }# close get_results_random
  results <- get_results_random()

  # III.B. Residuals
  # record the extracted values of the estimated random effects
  get_results_residual <- function(){

    model <- mpar[[1]] # load the extract of this model's estimates

    ## variance of residual of process (A)- a_SIGMA
    (test <- model[grep("^A", model$param), ])
    (test <- test[grep("^Residual.Variances", test$paramHeader), ])
    (test <- test[ ,c("est", "se","est_se", "pval")][1,]) # only the first line, they should be same
    if(dim(test)[1]!=0) {results[1, a_SIGMA] <- test}

    ## variance of residual of process (B) - b_SIGMA
    (test <- model[grep("^B", model$param), ])
    (test <- test[grep("^Residual.Variances", test$paramHeader), ])
    (test <- test[ ,c("est", "se","est_se", "pval")][1,]) # only the first line, they should be same
    if(dim(test)[1]!=0) {results[1, b_SIGMA] <- test}

    ## covariance btw residuals of process (A) and process (B) - ab_SIGMA
    (test <- model[grep(".WITH", model$paramHeader),]) # paramHeader containing .WITH
    (test <- test[-grep("^I|S", test$param),]) # param starting NOT with I or S
    (test <- test[ ,c("est", "se","est_se", "pval")][1,]) # only the first line, they should be same
    if(dim(test)[1]!=0){results[1, ab_SIGMA] <- test}

    ## Correlations b/w INTERCEPT of process (A)  and INTERCEPT of process (B)
    results[1,R_IAIB] <- IalsaSynthesis::extract_named_wald("R_IAIB", mplus_output)
    ## Correlations b/w SLOPE of process (A)  and SLOPE of process (B)
    results[1, R_SASB] <- IalsaSynthesis::extract_named_wald("R_SASB", mplus_output)

    ## Correlations b/w RESIDUAL of process (A)  and RESIDUAL of process (B)
    results[1,R_RES_AB] <- IalsaSynthesis::extract_named_wald("R_RES_AB",mplus_output)

    return(results)
  }# close get_results_residual
  results <- get_results_residual()

# browser()

  # III.C. Fixed Effects
  # record the extracted values of the estimated random effects
  get_results_fixed <- function(){
    selected_models <- seq_along(mpar)
    model <- mpar[[1]] # load the extract of this model's estimates
    ## intercept
    (int <- model[grep("Intercepts", model$paramHeader),])

    ## average initial status of process (A) - a_GAMMA_00
    (test <- int[int$param=='IA',c('est', 'se', "est_se", 'pval')])
    if(dim(test)[1]!=0) {results[1, a_GAMMA_00] <- test}

    ## average rate of change of process (A) - a_GAMMA_10
    (test <- int[int$param=='SA',c('est', 'se', "est_se", 'pval')])
    if(dim(test)[1]!=0) {results[1, a_GAMMA_10] <- test}

    ## average initial status of process (B) - b_GAMMA_00
    (test <- int[int$param=='IB',c('est', 'se', "est_se", 'pval')])
    if(dim(test)[1]!=0) {results[1, b_GAMMA_00] <- test}

    ## average rate of change of process (B) - b_GAMMA_10
    (test <- int[int$param=='SB',c('est', 'se', "est_se", 'pval')])
    if(dim(test)[1]!=0) {results[1, b_GAMMA_10] <- test}

    ## intercept of process (A) regressed on (age at baseline) centered at 70 years - a_GAMMA_01
    (test <- model[grep("IA.ON", model$paramHeader),])
    (test <- test[test$param=="AGE_C70",])
    (test <- test[c('est', 'se', "est_se", 'pval')])
    if(dim(test)[1]!=0) {results[1, a_GAMMA_01] <- test}

    ## slope of process (A) regressed on (age at baseline) centered at 70 years - a_GAMMA_11
    (test <- model[grep("SA.ON", model$paramHeader),])
    (test <- test[test$param=="AGE_C70",])
    (test <- test[c('est', 'se', "est_se", 'pval')])
    if(dim(test)[1]!=0) {results[1, a_GAMMA_11] <- test}

    ## intercept of process (A) regressed on (education) centered at 7 grades - a_GAMMA_01
    (test <- model[grep("IA.ON", model$paramHeader),])
    (test <- test[test$param=="EDU_C7",])
    (test <- test[c('est', 'se', "est_se", 'pval')])
    if(dim(test)[1]!=0) {results[1, a_GAMMA_01] <- test}

    ## slope of process (A) regressed on (education) centered at 7 graded
    (test <- model[grep("SA.ON", model$paramHeader),])
    (test <- test[test$param=="EDU_C7",])
    (test <- test[c('est', 'se', "est_se", 'pval')])
    if(dim(test)[1]!=0) {results[1, a_GAMMA_11] <- test}

    ## intercept of process (A) regressed on (height)  centered at 160 cm - a_GAMMA_01
    (test <- model[grep("IA.ON", model$paramHeader),])
    (test <- test[test$param=="HTM_C160",])
    (test <- test[c('est', 'se', "est_se", 'pval')])
    if(dim(test)[1]!=0) {results[1, a_GAMMA_01] <- test}

    ## slope of process (A) regressed on (height) centered at 160 cm  - a_GAMMA_11
    (test <- model[grep("SA.ON", model$paramHeader),])
    (test <- test[test$param=="HTM_C160",])
    (test <- test[c('est', 'se', "est_se", 'pval')])
    if(dim(test)[1]!=0) {results[1, a_GAMMA_11] <- test}



    #       ## intercept of process (B)  regressed on Age at baseline
    #       (test <- model[grep("IB.ON", model$paramHeader),])
    #       (test <- test[test$param=="AGE_C70",])
    #       (test <- test[c('est', 'se', "est_se", 'pval')])
    #       if(dim(test)[1]!=0) {results[1, b_GAMMA_01] <- test}
    #
    #       ## slope of process (B) regressed on Age at baseline
    #       (test <- model[grep("SB.ON", model$paramHeader),])
    #       (test <- test[test$param=="BAGE",])
    #       (test <- test[c('est', 'se', "est_se", 'pval')])
    #       if(dim(test)[1]!=0) {results[1, b_GAMMA_11] <- test}


  }# close get_results_fixed
  # results <- get_results_fixed()

  # IV.A. Export results
  # (a <- (strsplit(folder, "/")[[1]]))
  # (a_max <- max(length(a)))
  # (b <- a[a_max])
  # write.csv(results, paste0(folder,"/",b,".csv") , row.names=F)
  # saveRDS(results, paste0(destination,".rds") )
  return( results )
}


