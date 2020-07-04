
scoring <- function(){
  psychTestR::code_block(function(state,...){
    #browser()
    results <- psychTestR::get_results(state = state,
                                       complete = FALSE,
                                       add_session_info = FALSE) %>% as.list()

    sum_score <- sum(purrr::map_lgl(results$BDS, function(x) x$correct))
    num_question <- length(results$BDS)
    perc_correct <- sum_score/num_question
    psychTestR::save_result(place = state,
                 label = "score",
                 value = perc_correct)
    psychTestR::save_result(place = state,
                             label = "num_questions",
                             value = num_question)

  })

}

get_stimulus <- function(item, item_number, num_items_in_test, training = FALSE) {
  timeout <- nchar(item$answer[1]) * 1500 + 500
  #test_items = "http://media.gold-msi.org/test_materials/BDS/tasks"
  shiny::addResourcePath("www_BDS", base::system.file("www", package = "BDS"))
  test_items_path <- "www_BDS/img"
  onload_handler <-sprintf("setTimeout(function(){document.getElementById('prompt').style.visibility = 'inherit';document.getElementById('pos_seq').value = '';document.getElementById('pos_seq').style.backgroundColor ='#ffffff'}, %s)", timeout)
  if(training){
    progress_text <- psychTestR::i18n("SAMPLE_HEADER", sub = list("num_example" = item_number))
    gif <- shiny::img(src = file.path(test_items_path, item$img_name), onload = onload_handler)
  }
  else{
    progress_text <- psychTestR::i18n("PROGRESS_TEXT",
                                      sub =
                                        list(num_question = item_number,
                                             test_length = num_items_in_test))
    gif <- shiny::img(src = file.path(test_items_path, item$img_name), onload = onload_handler)
  }
  shiny::div(
    shiny::h4(progress_text),
    shiny::div(gif)
  )
}


get_answer <- function(correct_answer){
  gaf <-
    function(input, ...) {
      #messagef("Calling get_answer function with correct answer '%s'", correct_answer)
      #messagef("Calling get_answer function with correct answer '%s' (0x%s)", correct_answer, data.table::address(correct_answer))

      tibble(raw = input$pos_seq,
            correct_answer = correct_answer,
            correct =  input$pos_seq == correct_answer)
    }
  #messagef("Generated get_answer function with correct answer '%s' (0x%s, ca = 0x%s)", correct_answer, data.table::address(gaf), data.table::address(correct_answer))
  #weird behaviour: if correct_answer is not used in the body of the function,
  #the returned functions will have reference to last called correct_answer
  #Maybe some optimization?
  #anyway: dummy call correct_answer, andit works
  correct_answer
  return(gaf)
}

create_test_pages <- function(num_items_in_test) {
  ret <- c()
  item_sequence <- 1:num_items_in_test
  BDS_items <- BDS::BDS_item_bank %>% filter(training == 0)
  num_items_in_test <- max(min(num_items_in_test, nrow(BDS_items)), 1)
  #browser()
  for(item_number in 1:num_items_in_test){
    item <- BDS_items[item_sequence[item_number],]
    stimulus <- get_stimulus(item, item_number, num_items_in_test)
    label <- paste0("q", item_number)
    correct_answer <- item$answer

    #printf("Created item with %s, %d", correct_answer, nchar(correct_answer))
    #browser()
    item <- BDS_page(label = label,
                     stimulus = stimulus,
                     seq_len = nchar(correct_answer),
                     save_answer = TRUE,
                     get_answer = get_answer(correct_answer))
    ret <- c(ret, item)
  }
  #browser()
  ret
}

main_test <- function(label, num_items_in_test) {
  elts <- create_test_pages(num_items_in_test)
  return(elts)
  #psychTestR::join(psychTestR::begin_module(label = label),
  #                 elts,
  #                 #scoring(label, items, subscales, short_version),
  #                 psychTestR::elt_save_results_to_disk(complete = TRUE),
  #                 psychTestR::end_module())
}


BDS_welcome_page <- function(dict = BDS::BDS_dict){
  psychTestR::new_timeline(
    psychTestR::one_button_page(
    body = shiny::div(
      shiny::h4(psychTestR::i18n("WELCOME")),
      #shiny::div(psychTestR::i18n("INSTRUCTIONS"),
      #         style = "margin-left:0%;display:block")
    ),
    button_text = psychTestR::i18n("CONTINUE")
  ), dict = dict)
}

BDS_finished_page <- function(dict = BDS::BDS_dict){
  psychTestR::new_timeline(
    psychTestR::one_button_page(
      body = shiny::div(
        shiny::div(psychTestR::i18n("THANK_YOU"),
                   style = "margin-left:0%;display:block"),
        button_text = psychTestR::i18n("CONTINUE")
      )
    ), dict = dict)
}
BDS_final_page <- function(dict = BDS::BDS_dict){
  psychTestR::new_timeline(
    psychTestR::final_page(
      body = shiny::div(
        shiny::h4(psychTestR::i18n("THANK_YOU")),
        shiny::div(psychTestR::i18n("CLOSE_BROWSER"),
                   style = "margin-left:0%;display:block")
      )
    ), dict = dict)
}
