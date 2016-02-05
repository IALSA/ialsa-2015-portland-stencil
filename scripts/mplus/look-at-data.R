

options(width=160)
rm(list=ls())
cat("\f")

# ---- load_packages ---------------------------------------------------------
library(dplyr)
library(magrittr) #Pipes

# ---- @knitr load_data -------------------------------------------------------
rootPath <- getwd()
filePath <- paste0(rootPath,"/data/unshared/raw/ds0.rds")
ds0 <- readRDS(filePath)
ds <- ds0
str(ds)


ds %>% dplyr::count(study)
ds <- ds %>% dplyr::filter(study == "MAP ")# keep only MAP

# ---- nl_function -----------------------------------------------------------
# Create function that inspects names and labels
names.labels <- function(ds){
  # ds <- dsDemo
  nl <- data.frame(matrix(NA, nrow=ncol(ds), ncol=2))
  names(nl) <- c("name","label")
  for (i in seq_along(names(ds))){
    nl[i,"name"] <- names(ds[i])
    if(is.null(attr(ds[[i]], "label")) ){
      nl[i,"label"] <- NA}else{
        nl[i,"label"] <- attr(ds[[i]], "label")
      }
  }
  return(nl)
}
(nl <- names.labels(ds))

write.csv(nl, file="./data/unshared/derived/nl_raw.csv")
write.csv(ds, file="./data/unshared/derived/ds.csv")

str(ds$agreeableness)
sum(ds$conscientiousness)
