## Project title: Automate Mplus out read-in
##    Created at: Feb 17 2015
##        Author: Philippe Rast
##          Data: Mplus output files
##       Summary: Collects output from Mplus files according to DTO and
##                generates a csv file for further use.
## ---------------------------------------------------------------------- ##

options(width=160)
rm(list=ls())

library(MplusAutomation)
# library(xlsx)
pathDir <- getwd() # establish home directory
# pathStudy <- file.path(pathDir,"studies/octo") # establish Study directory
pathStudy <- file.path(pathDir,"studies/octo/unshared/koval") # temp
pathDto <- file.path(pathDir,"synthesis/bivariate/dto_bivariate.csv")
## obtain variable list from DTO - Relative path
dto.vars <- names(read.csv(pathDto,skip=1))
dto.vars
list.files(pathStudy)

## Uncomment in case output files need to be generated and
## change "never" to "always" to overwrite existing out files
#runModels(replaceOutfile="never")

## Read in Model Summaries
msum <- MplusAutomation::extractModelSummaries(target=pathStudy)
names(msum)

## Extract Estimates
mpar <- MplusAutomation::extractModelParameters(target=pathStudy, recursive=F) #Adapt so it's relative to the root of the repository.
#names(mpar)
#mpar[[3]]

# count number of models
nmodels <- length(mpar)
nmodels

## Generate empty data frame to be populated by Mplus values
results=data.frame(matrix(NA, ncol=length(dto.vars), nrow=nmodels))
names(results) <-  dto.vars

for(i in seq_along(mpar)){
    mplus_output <- scan(file=file.path(pathStudy, msum$Filename[i]), what='character', sep='\n')

    ## Populate with header info
    results[i,c("model_number", 'subgroup',  'model_type')] <- strsplit(msum$Filename[i], '_')[[1]][1:3]
    results[i,"version"] <- "0.1" #msum[i,"Mplus.version"]
    results[i,"active"] <- NA
#     results[i,"best_in_gender"] <- "??"
    results[i, c('date', 'time')] <- strsplit(mplus_output[3], '  ')[[1]]
    results[i,"study_name"] <- 'octo'
    # results[i,"data_file"] <-
    #     strsplit(
    #       scan(file=file.path(pathStudy,msum$Filename[i]),
    #                   what='character',sep='\n')
    #       [grep("File =", scan(file=file.path(pathStudy,msum$Filename[i]), what='character', sep='\n'))], "=|;")[[1]][2]

    # output_line_of_path <- grep("File =", mplus_output)
    # results[i, "data_file"] <- strsplit(mplus_output[output_line_of_path], "=|;")[[1]][2]

    # Extract the file path, which exists after 'File = ', but before the semicolon.
    results[i, "data_file"] <- gsub(pattern="DATA:  File = (.+);", replacement="\\1", mplus_output[output_line_of_path], perl=T)

#     ## Figure out if perdictor is cognitive or physical
#     cop <- mpar[[i]]$unstandardized
#     cop
# ## i <- 1
#     predC <- length(grep('^C', cop[cop$paramHeader=='Residual.Variances', 'param']))
#     predP <- length(grep('^P', cop[cop$paramHeader=='Residual.Variances', 'param']))
#     ##
#     if(predC>0 & predP == 0) {results[i,c('cognitive_outcome')] <- strsplit(msum$Filename[i], '_|.out')[[1]][5]}
#     if(predP>0 & predC == 0) {results[i,c('physical_outcome')] <- strsplit(msum$Filename[i], '_|.out')[[1]][4]}
#     if(predP>0 & predC > 0) {results[i,c('physical_outcome','cognitive_outcome')] <- strsplit(msum$Filename[i], '_|.out')[[1]][4:5]}
#     ##

    results[i, c("physical_outcome","cognitive_outcome")] <- strsplit(msum$Filename[i], '_|.out')[[1]][4:5]


    ## Check for model conversion
    conv <- length(grep("THE MODEL ESTIMATION TERMINATED NORMALLY",
                        scan(file=file.path(pathStudy,msum$Filename[i]), what='character', sep='\n')))


    #has_converged <- length(grep("THE MODEL ESTIMATION TERMINATED NORMALLY", mplus_output))
    has_converged <- (grep("THE MODEL ESTIMATION TERMINATED NORMALLY", mplus_output) >= 1)

    results[i, 'converged'] <- has_converged

    if(has_converged) {
        ## obtain model for current loop
        model <- mpar[[i]]$unstandardized
        model
        ## Variances
        #################
        ## Covariances ##
        #################
        ## Look for at least 4 WITH statements - otherwise fall back to 'Means' and 'Variances' (Baseline Models)
        #modtype <- ifelse(length(grep("WITH", model$paramHeader))>=4, 1, 0)
        # modtype <- ifelse(length(grep("WITH", model$paramHeader))>=4, TRUE, FALSE)
        modtype <- (length(grep("WITH", model$paramHeader))>=4) #Will's suggestion
        modtype
        if(modtype) { # if modtype==1 we have WITH statements
            x <- model[grep("WITH", model$paramHeader),]
            ## find factor coavariances IP wiht IC and SP with SC
            ## CovSS: Loook for S in paramHeader and S in param # only works as long as there is no S2 etc.
            ## CovII: Loook for I in paramHeader and I in param
            x$param
            x
            ## Focus on factor covariances
            fc <- x[grep("I|S", x$param),]
            fc
            ## ###############################
            ## Covariance among intercepts  ##
            ## ###############################
            ## reduce to I in paramHeader. Note. Use "^" to avoid the I in  WITHIN
            IpH <- fc[grep("^I", fc$paramHeader),]
            ## get I in param
            results[i, c("cov_int", "p_cov_int")] <-  IpH[grep("^I", IpH$param),c('est', 'pval')]
            ## ###############################
            ## Covariance among slopes      ##
            ## ###############################
            ## reduce to S in paramHeader. Play it save, use ^
            SpH <- fc[grep("^S", fc$paramHeader),]
            ## get S in param
            results[i, c("cov_slope", "p_cov_slope")] <- SpH[grep("^(SP|SH)$", SpH$param),c('est', 'pval')]
            ## ###############################
            ## Covariance among residuals   ##
            ## ###############################
            ## Obtain resid cov
            rc <- x[-grep("I|S", x$param),]
            ## Check whether only one cov has been estimated
            if(length(unique(rc$est))==1) {
                results[i, c("cov_residual", "p_cov_res")] <- rc[1,c('est', 'pval')]
            } else {
              results[i, 'notes'] <- paste(results[i, 'notes'], "Heterogeneous Res Covs", sep='_')
            }
        }
        ##
        ## ################
        ##  Variances   ##
        ## ################
        ## Subset model
        vrs <- model[grep("Variances", model$paramHeader),]
        ## test whether we actually have values that are returned
        test <- vrs[vrs$param=='IP',c('est', 'se')]
        if(dim(test)[1]!=0) {results[i, c("var_int_physical", "se_int_physical")] <- test}
        ##
        test <- vrs[vrs$param=='SP',c('est', 'se')]
        if(dim(test)[1]!=0) {results[i, c("var_slope_physical", "se_slope_physical")] <- test}
        ##
        test <- vrs[vrs$param=='IC',c('est', 'se')]
        if(dim(test)[1]!=0) {results[i, c("var_int_cog", "se_int_cog")] <- test}
        ##
        test <- vrs[vrs$param=='SC',c('est', 'se')]
        if(dim(test)[1]!=0) {results[i, c("var_slope_cog", "se_slope_cog")] <- test}
        ## Residuals
        ## match only first letter with "^"
        resP <- unique(vrs[grep("^P", vrs$param), c('est', 'se')] )
        ## Write residual covariance and add warning if ResCov unconstrained
        if(length(resP[,1])==1) {results[i, c("var_residual_physical", "se_residual_physical")] <- resP}
        ## Test of unconstrained variances: needs development
        #else {
         #    results[i,'notes'] <- paste(results[i,'notes'], 'Phys ResCov unconstrained', sep='_')}
         resC <- unique(vrs[grep("^C", vrs$param), c('est', 'se')] )
         ## Write residual covariance and add warning if ResCov unconstrained
         if(length(resC[, 1])==1) {results[i, c("var_residual_cog", "se_residual_cog")] <- resC}
        ## Test of unconstrained variances: needs development
        #else {
         #    results[i,'notes'] <- paste(results[i,'notes'], 'Cog ResCov unconstrained', sep='_')}
    }

    ## ####################
    ##  Additional info ##
    ## ####################
    results[i, 'subject_count'] <- msum[i, 'Observations']
    results[i, 'wave_count'] <- 'to_do'
    results[i, 'parameter_count'] <- msum[i, 'Parameters']
    results[i, 'output_file'] <- msum[i, 'Filename']
    results[i, 'software'] <- mplus_output[1]
    results[i, 'model_description'] <- '??'
    results[i, c('LL')] <-  msum[i,c('LL')]
    results[i, c('aic')] <-  msum[i,c('AIC')]
    results[i, c('bic')] <-  msum[i,c('BIC')]
    results[i, c('adj_bic')] <-  msum[i,c('aBIC')]
    results[i, c('aaic')] <-  msum[i,c('AICC')]
}

results <- dplyr::arrange(results, physical_outcome,  )

View(results)
## Write populated dto for further use
write.csv(results, file='automation_result.csv', row.names = F)


