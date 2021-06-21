practice <- function(audio_dir = "https://s3-eu-west-1.amazonaws.com/media.dots.org/stimuli/MSM",
                     type,
                     num_items_test = 10L)  {
  #browser()
  type <- parse_type(type)
  messagef("Added practice pages for type '%s'", type[1])
  if(type[1] == "PART1"){
    stim_desc <-  psychTestR::i18n(sprintf("%s_STIMULUS_DESCRIPTION", type[1]), sub = list(num_items = num_items_test +1 ))
  }
  else{
    stim_desc <-  psychTestR::i18n(sprintf("%s_STIMULUS_DESCRIPTION-%s", type[1], type[2]))
  }
  ret <- psychTestR::one_button_page(body = shiny::div(
    psychTestR::i18n("INSTRUCTIONS", sub = list(stimulus_description = stim_desc)),
    style = "margin-left:15%; margin-right:15%;margin-bottom:20px;text-align:justify"),
    button_text = psychTestR::i18n("CONTINUE"))

  #sample_stimuli <- c("100test_changerule.wav", "101test_proximityrule.wav", "102test_control.wav")
  sample_stimuli <- c("part1_test.wav")
  if(type[1] == "PART1"){
    for(i in 1:length(sample_stimuli)){
      #browser()
      stimulus <- sample_stimuli[i]
      header <- get_header(i, length(sample_stimuli), training = T)

      label <- paste0("s", i)
      item <- MSM_page(label = label,
                       stimulus = stimulus,
                       header = header,
                       audio_dir = audio_dir,
                       save_answer = FALSE)
      ret <- c(ret, item)
    }
    ret <- c(ret, psychTestR::one_button_page( body = psychTestR::i18n("CONTINUE_MAIN_TEST"),
                                               button_text = psychTestR::i18n("CONTINUE")))

  }
  ret
}
