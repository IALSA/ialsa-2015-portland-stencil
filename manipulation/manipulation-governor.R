# This script executes all manipulation scripts and walks you through data provisioniing chain.

source("./manipulation/0-ellis-island.R")

# rmarkdown::render(input = "./sandbox/inspect-extracted-results/inspect-extracted-raw.Rmd" ,
#                   output_format="html_document", clean=TRUE)

source("./manipulation/1-rename-classify.R")

source("./manipulation/2-transformations-compute-ci.R")
rmarkdown::render(input = "./sandbox/inspect-extracted-results/inspect-extracted-raw.Rmd" ,
                  output_format="html_document", clean=TRUE)
#
#
rmarkdown::render(input = "./reports/outcome-space/outcome-space.Rmd" ,
                  output_format="html_document", clean=TRUE)
