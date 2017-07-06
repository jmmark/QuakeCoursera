# Load and clean up the NOAA data, and put .rdata into the data directory

# need devtools, dplyr, readr

library(devtools)
library(dplyr)
library(lubridate)
library(readr)
library(stringr)

# read in the raw data
raw_NOAA <- readr::read_delim('./data-raw/signif.txt',delim = '\t')
