#' Demo BDS
#'
#' This function launches a demo for the BDS.
#'
#' @param num_items (Integer scalar) Number of items in the test.
#' @param feedback (Function) Defines the feedback to give the participant
#' at the end of the test. Defaults to a graph-based feedback page.
#' @param admin_password (Scalar character) Password for accessing the admin panel.
#' Defaults to \code{"demo"}.
#' @param researcher_email (Scalar character)
#' If not \code{NULL}, this researcher's email address is displayed
#' at the bottom of the screen so that online participants can ask for help.
#' Defaults to \email{longgold@gold.uc.ak},
#' the email address of this package's developer.
#' @param dict The psychTestR dictionary used for internationalisation.
#' @param language The language you want to run your demo in.
#' Possible languages include English (\code{"EN"}) and German (\code{"DE"}).
#' The first language is selected by default
#' @param ... Further arguments to be passed to \code{\link{BDS}()}.
#' @export
#'
BDS_demo <- function(num_items = 3L,
                     feedback = BDS::BDS_feedback_with_score(),
                     admin_password = "demo",
                     researcher_email = "longgold@gold.uc.ak",
                     dict = BDS::BDS_dict,
                     language = "EN",
                     ...) {
  elts <- psychTestR::join(
    BDS_welcome_page(dict = dict),
    BDS::BDS(num_items = num_items,
             with_welcome = FALSE,
             with_training = TRUE,
             feedback = feedback,
             dict = dict,
             ...),
      BDS_final_page(dict = dict)
  )

  psychTestR::make_test(
    elts,
    opt = psychTestR::test_options(title = dict$translate("TESTNAME", language),
                                   admin_password = admin_password,
                                   researcher_email = researcher_email,
                                   demo = TRUE,
                                   languages = language[1]))
}
