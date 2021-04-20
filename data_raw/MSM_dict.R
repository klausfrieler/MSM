library(tidyverse)

usethis::use_build_ignore(c("material", "data_raw"))

MSM_dict_raw <- readxl::read_xlsx("data_raw/MSM_dict.xlsx", trim_ws = T)
MSM_dict <- MSM_dict_raw %>% psychTestR::i18n_dict$new()
usethis::use_data(MSM_dict, overwrite = TRUE)
