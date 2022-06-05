install.packages("haven")
library(haven)
library(help=haven)

# set the working directory
dat <- read_sas("./raw-nces/pu_ssocs18.sas7bdat")
summary(dat)
head(dat)

table(dat$FR_URBAN, dat$FR_SIZE)
