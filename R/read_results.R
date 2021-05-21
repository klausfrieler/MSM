dummy_MSM <- tibble(stimulus = NA, marker = NA, count = NA, difficulty = NA, liking = NA)

parse_MSM_entry <- function(MSM_entry, expand_markers = F){
  names <- names(MSM_entry)
  if(length(names) == 0){
    return(dummy_MSM)
  }
  if(any(stringr::str_detect(names, "q1.difficult"))){
    #return(dummy_MSM)
  }
  #browser()
  difficulties <- MSM_entry[names[stringr::str_detect(names, "difficult")]] %>% unlist() %>% as.integer()
  likings <- MSM_entry[names[stringr::str_detect(names, "difficult")]] %>% unlist() %>% as.integer()
  stopifnot(length(difficulties) == length(likings))
  #browser()
  base <- purrr::map_dfr(MSM_entry[names[stringr::str_detect(names, "^q[0-9]+$")]], function(.x){
    .x
    })

  ret <- dplyr::bind_cols(base, tibble(difficulty = difficulties, liking = likings))
  if(expand_markers){
    ret <- ret %>%
      mutate(marker = stringr::str_split(marker, ",")) %>%
      tidyr::unnest(marker) %>%
      mutate(marker = as.numeric(marker)/1000)
  }
  ret
}
dummy_GMS <- tibble(GMS.active_engagement = NA,
                    GMS.general = NA,
                    GMS.musical_training = NA,
                    GMS.emotions = NA,
                    GMS.perceptual_abilities = NA,
                    GMS.singing_abilities = NA,
                    GMS.instrument = NA,
                    GMS.start_age = NA,
                    GMS.absolute_pitch = NA)

parse_GMS_entry <- function(GMS_entry){

  if(is.null(GMS_entry)){
    return(dummy_GMS)
  }
  names <- names(GMS_entry)
  if(length(names) == 0){
    return(dummy_GMS)
  }
  sum_data <- names[!stringr::str_detect(names, "q[0-9]+")]
  ret <- GMS_entry[sum_data]
  names(ret) <- sprintf("GMS.%s", names(ret) %>% stringr::str_to_lower() %>% stringr::str_replace(" ", "_"))
  ret %>% tibble::as_tibble()
}

dummy_DEG <- tibble(age = NA, gender = NA)
parse_DEG_entry <- function(DEG_entry){
  if(is.null(DEG_entry)){
    return(dummy_DEG)
  }
  names <- names(DEG_entry)
  if(length(names) == 0){
    return(dummy_DEG)
  }
  tibble(gender = c("female", "male", "other", "rather not say")[DEG_entry$Gender],
         age = DEG_entry$Age/12)
}

#' read_MSM_data
#'
#' reads a directory with RDS MSM results files and parses it into a single data frame
#' @param results_dir (string) Path to result files
#' @param expand_marker (lgl) Boolean flag whether time marker shall be expanded or not
#' @export

read_MSM_data <- function(result_dir = "e:/projects/science/LongGold/development/tests/MSM.material/results/", expand_markers = F){
  results <- purrr::map(list.files(result_dir, pattern = "*.rds", full.names = T), ~{readRDS(.x) %>% as.list()})
  purrr::map_dfr(results, function(x){
    #browser()
    names <- names(x)
    if("MSM" %in% names){
      ret <- parse_MSM_entry(x$MSM, expand_markers = expand_markers)
    }
    else{
      ret <- dummy_MSM
    }
    if("GMS" %in% names){
      ret <- dplyr::bind_cols(ret, parse_GMS_entry(x$GMS))
    }
    else{
      ret <- dplyr::bind_cols(ret, dummy_GMS)
    }
    if("DEG" %in% names){
      ret <- dplyr::bind_cols(ret, parse_DEG_entry(x$DEG))
    }
    else{
      ret <- dplyr::bind_cols(ret, dummy_DEG)
    }
    #print(ret)
    ret %>% dplyr::bind_cols(x$session %>% tibble::as_tibble()) %>% dplyr::select(p_id, -pilot, -num_restarts, time_ended = current_time, everything())

  }) %>% dplyr::arrange(time_started)
}
