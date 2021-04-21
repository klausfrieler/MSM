library(tidyverse)
library(psychTestR)
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
#' @param label (Character scalar) Label to give the MSM results in the output file.
#' @param dict The psychTestR dictionary used for internationalisation.
#' @export
MSM <- function(with_welcome = TRUE,
                with_training = TRUE,
                with_finish = TRUE,
                label = "MSM",
                audio_dir = "https://s3-eu-west-1.amazonaws.com/media.dots.org/stimuli/MSM",
                dict = MSM::MSM_dict,
                ...) {
  stopifnot(purrr::is_scalar_character(label))
  #browser()
  psychTestR::join(
    psychTestR::begin_module(label),
    if (with_welcome) MSM_welcome_page(),
    if (with_training) psychTestR::new_timeline(practice(audio_dir), dict = dict),
    psychTestR::new_timeline(
      main_test(audio_dir = audio_dir, ...),
      dict = dict),
    psychTestR::elt_save_results_to_disk(complete = TRUE),
    #psychTestR::code_block(function(state, ...){
    #  restults <- psychTestR::get_results(state, complete = F)
    #  browser()
    #}),
    if(with_finish) MSM_finished_page(),
    psychTestR::end_module())
}
