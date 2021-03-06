#' Demo MSM
#'
#' This function launches a demo for the MSM.
#'
#' @param num_items (Integer scalar) Number of items in the test.
#' @param admin_password (Scalar character) Password for accessing the admin panel.
#' Defaults to \code{"demo"}.
#' @param researcher_email (Scalar character)
#' If not \code{NULL}, this researcher's email address is displayed
#' at the bottom of the screen so that online participants can ask for help.
#' Defaults to \email{longgold@gold.uc.ak},
#' the email address of this package's developer.
#' @param dict The psychTestR dictionary used for internationalisation.
#' @param language The language you want to run your demo in.
#' Possible languages include English (\code{"en"}) and German (\code{"de"}).
#' The first language is selected by default
#' @param ... Further arguments to be passed to \code{\link{MSM}()}.
#' @export
#'
MSM_demo <- function(num_items = 3L,
                     admin_password = "demo",
                     researcher_email = "longgold@gold.uc.ak",
                     dict = MSM::MSM_dict,
                     language = c("en", "de"),
                     ...) {
  elts <- psychTestR::join(
    MSM_welcome_page(dict = dict),
    MSM::MSM(num_items = num_items,
             with_welcome = FALSE,
             with_training = TRUE,
             dict = dict,
             ...),
      MSM_final_page(dict = dict)
  )

  psychTestR::make_test(
    elts,
    opt = psychTestR::test_options(title = dict$translate("TESTNAME", language[1]),
                                   admin_password = admin_password,
                                   researcher_email = researcher_email,
                                   demo = TRUE,
                                   languages = tolower(language[1])))
}
