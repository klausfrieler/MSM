options(shiny.error = browser)
debug_locally <- !grepl("shiny-server", getwd())


#' Standalone MSM
#'
#' This function launches a standalone testing session for the MSM
#' This can be used for data collection, either in the laboratory or online.
#' @param title (Scalar character) Title to display during testing.
#' @param num_items (Scalar integer) Number of items to be adminstered.
#' @param with_id (Logical scalar) Whether to show a ID page.
#' @param feedback (Function) Defines the feedback to give the participant
#' at the end of the test.
#' @param with_welcome (Logical scalar) Whether to show a welcome page.
#' @param admin_password (Scalar character) Password for accessing the admin panel.
#' @param researcher_email (Scalar character)
#' If not \code{NULL}, this researcher's email address is displayed
#' at the bottom of the screen so that online participants can ask for help.
#' @param languages (Character vector)
#' Determines the languages available to participants.
#' Possible languages include English (\code{"EN"}),
#' and German (\code{"DE"}).
#' The first language is selected by default
#' @param dict The psychTestR dictionary used for internationalisation.
#' @param validate_id (Character scalar or closure) Function for validating IDs or string "auto" for default validation
#' which means ID should consist only of  alphanumeric characters.
#' @param ... Further arguments to be passed to \code{\link{MSM}()}.
#' @export
MSM_standalone  <- function(title = NULL,
                            with_id = FALSE,
                            with_welcome = TRUE,
                            with_training = FALSE,
                            with_finish = TRUE,
                            admin_password = "conifer",
                            researcher_email = "klaus.frieler@ae.mpg.de",
                            languages = c("en", "de"),
                            dict = MSM::MSM_dict,
                            audio_dir = "https://s3-eu-west-1.amazonaws.com/media.dots.org/stimuli/MSM",
                            validate_id = "auto",
                           ...) {

  elts <- psychTestR::join(
    if(with_id)
      psychTestR::new_timeline(
        psychTestR::get_p_id(prompt = psychTestR::i18n("ENTER_ID"),
                             button_text = psychTestR::i18n("CONTINUE"),
                             validate = validate_id),
        dict = dict),
    MSM::MSM(
      with_welcome =  with_welcome,
      with_training = with_training,
      with_finish = FALSE,
      audio_dir = audio_dir,
      dict = dict,
      ...),
    psychTestR::elt_save_results_to_disk(complete = TRUE),
    MSM_final_page(dict = dict)
  )
  if(is.null(title)){
    #extract title as named vector from dictionary
    title <- dict$translate("TESTNAME", tolower(languages[1]))

  }
  psychTestR::make_test(
    elts,
    opt = psychTestR::test_options(title = title,
                                   admin_password = admin_password,
                                   researcher_email = researcher_email,
                                   demo = FALSE,
                                   languages = tolower(languages)))
}
