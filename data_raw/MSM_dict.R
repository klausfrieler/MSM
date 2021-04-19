MSM_dict_raw <- readRDS("data_raw/MSM_dict.RDS")
#names(MSM_dict_raw) <- c("key", "DE", "EN")
MSM_dict_raw <- MSM_dict_raw[,c("key", "EN", "DE")]
MSM_dict <- psychTestR::i18n_dict$new(MSM_dict_raw)
usethis::use_data(MSM_dict, overwrite = TRUE)
