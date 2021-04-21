practice <- function(audio_dir = "https://s3-eu-west-1.amazonaws.com/media.dots.org/stimuli/MSM")  {
  #browser()
  message("Added practice pages")
  ret <- psychTestR::one_button_page(body = shiny::div(
    psychTestR::i18n("INSTRUCTIONS"),
    style = "margin-left:15%; margin-right:15%;margin-bottom:20px;text-align:justify"),
    button_text = psychTestR::i18n("CONTINUE"))

  sample_stimuli <- c("100test_changerule.wav", "101test_proximityrule.wav", "102test_control.wav")

  for(i in 1:length(sample_stimuli)){
    #browser()
    stimulus <- sample_stimuli[i]
    header <- get_header(i, length(sample_stimuli), training = T)

    label <- paste0("s", i)
    item <- MSM_page(label = label,
                     stimulus = stimulus,
                     header = header,
                     audio_dir = audio_dir,
                     save_answer = TRUE)
    ret <- c(ret, item)
  }
  ret <- c(ret, psychTestR::one_button_page( body = psychTestR::i18n("CONTINUE_MAIN_TEST"),
                                             button_text = psychTestR::i18n("CONTINUE")))
  ret
}
