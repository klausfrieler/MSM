#library(tidyverse)
#library(psychTestR)
#source("R/options.R")
#source("R/main_test.R")
#source("R/item_page.R")
#source("R/utils.R")


#' MSM
#'
#' This function defines a MSM  module for incorporation into a
#' psychTestR timeline.
#' Use this function if you want to include the MSM in a
#' battery of other tests, or if you want to add custom psychTestR
#' pages to your test timeline.
#' For demoing the MSM, consider using \code{\link{MSM_demo}()}.
#' For a standalone implementation of the MSM,
#' consider using \code{\link{MSM_standalone}()}.
#' @param num_items (Integer scalar) Number of items in the test.
#' @param with_training (Logical scalar) Whether to include the training phase.
#' @param with_welcome (Logical scalar) Whether to show a welcome page.
#' @param with_finish (Logical scalar) Whether to show a finished page.
#' @param finish_type (string scalar) Which finish page to show (Either FINISHED or FINISHED_CONT)
#' @param label (Character scalar) Label to give the MSM results in the output file.
#' @param type (character scalar) Which version to show (either PART1 or PART2-01/PART2-02)
#' @param dict The psychTestR dictionary used for internationalisation.
#' @param audio_dir (URL) The top level URL for audio stimuli
#' @param ... Further arguments to be passed to \code{main_test()}.
#' @export
MSM <- function(num_items = 10L,
                with_welcome = TRUE,
                with_training = TRUE,
                with_finish = TRUE,
                finish_type = "FINISHED_CONT",
                label = "MSM",
                type =  "PART1",
                audio_dir = "https://s3-eu-west-1.amazonaws.com/media.dots.org/stimuli/MSM",
                dict = MSM::MSM_dict,
                ...) {
  ptype <- parse_type(type)
  if(!(ptype[1] %in% c("PART1", "PART2"))){
    stop(sprintf("Found unknown test type %s", type))
  }
  if(ptype[1] == "PART2"){
    num_items <- 1
  }
  if(num_items > 10L){
    num_items <- 10L
  }

  stopifnot(purrr::is_scalar_character(label))
  if(!(finish_type %in% c("FINISHED", "FINISHED_CONT"))){
    stop(sprintf("Found unknown finish type %s", finish_type))

  }
  #browser()
  psychTestR::join(
    psychTestR::begin_module(label),
    if (with_welcome) MSM_welcome_page(),
    if (with_training) psychTestR::new_timeline(practice(audio_dir, type, num_items), dict = dict),
    psychTestR::new_timeline(
      main_test(num_items_in_test = num_items, audio_dir = audio_dir, type = type, ...),
      dict = dict),
    psychTestR::elt_save_results_to_disk(complete = TRUE),
    # psychTestR::code_block(function(state, ...){
    #   results <- psychTestR::get_results(state, complete = F)
    #   browser()
    # }),
    if(with_finish) MSM_finished_page(text_id = finish_type),
    psychTestR::end_module())
}
