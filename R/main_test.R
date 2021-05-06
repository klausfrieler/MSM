


get_header <- function(item_number, num_items_in_test, training = FALSE) {
  #onload_handler <-sprintf("setTimeout(function(){document.getElementById('prompt').style.visibility = 'inherit';document.getElementById('pos_seq').value = '';document.getElementById('pos_seq').style.backgroundColor ='#ffffff'}, %s)", timeout)
  if(training){
    header <- psychTestR::i18n("EXAMPLE_HEADER", sub = list("example_no" = item_number,
                                                            "num_example" = num_items_in_test))
  }
  else{
    header <- psychTestR::i18n("PAGE_COUNTER",
                                      sub =list(page_no = item_number,
                                                num_pages = num_items_in_test))
  }
  shiny::h4(header)
}


get_next_item <- function(item_no, offset){
  item_pool <- tibble(id = rep(1:10, 3),
                      variant = rep(letters[1:3],10))
  n <- nrow(item_pool)
  idz <- ((offset + 7*seq(0, n-1)) %% n)  + 1
  #print(offset)
  #print(idz)
  item_pool[idz[item_no],]
}

get_item_sequence <- function(seed = NULL, type ){
  #browser()
  if(!is.null(seed)){
    set.seed(seed)
  }
  if(type == "PART2"){
    return(tibble(id = 1, variant = NA, filename = "part2_02.wav", credits = psychTestR::i18n("CREDITS")))
  }
  offset <- sample(0:29, 1)
  purrr::map_dfr(1:30, ~{get_next_item(.x, offset)})  %>%
    mutate(filename = sprintf("part1_%02d%s.wav", id, variant), credits = "")
}

create_test_pages <- function(num_items_in_test = 10L,
                              audio_dir = "https://s3-eu-west-1.amazonaws.com/media.dots.org/stimuli/MSM",
                              type) {
  #browser()
  ret <- c()
  ret <- psychTestR::code_block(function(state, ...){
    #browser()
    seed <-  psychTestR::get_session_info(state, complete = F)$p_id %>%
      digest::sha1() %>%
      charToRaw() %>%
      as.integer() %>%
      sum()
    messagef("Code block, seed %d", seed)
    item_sequence = get_item_sequence(seed, type = type)
    psychTestR::set_local(key = "item_sequence", value = item_sequence[1:num_items_in_test,], state = state)
    psychTestR::set_local(key = "item_number", value = 1L, state = state)

  })
  if(type == "PART2"){
    num_items_in_test <- 1
  }
  for(item_number in 1:num_items_in_test){

    #printf("Created item with %s, %d", correct_answer, nchar(correct_answer))
    #browser()
    item <- psychTestR::reactive_page(function(state, ...) {
      #browser()
      item_sequence <- psychTestR::get_local("item_sequence", state)
      item_number <- psychTestR::get_local("item_number", state)
      stimulus <- item_sequence[item_number,]$filename
      credits <- item_sequence[item_number,]$credits
      header <- get_header(item_number, num_items_in_test)
      label <- paste0("q", item_number)
      messagef("Called reactive page, item_number %d", item_number)

      MSM_page(label = label,
               stimulus = stimulus,
               header = header,
               audio_dir = audio_dir,
               credits = credits,
               save_answer = TRUE)
    })
    ret <- c(ret,
             item,
             inbetween_page(item_number = item_number, prompt = "DIFFICULTY_PROMPT", label = "difficult"),
             inbetween_page(item_number = item_number, prompt = "LIKING_PROMPT", label = "liking"))
  }
  ret
}

main_test <- function(num_items_in_test = 10L,
                      audio_dir = "https://s3-eu-west-1.amazonaws.com/media.dots.org/stimuli/MSM", type) {
  elts <- create_test_pages(num_items_in_test, audio_dir = audio_dir, type = type)
  return(elts)
}


MSM_welcome_page <- function(dict = MSM::MSM_dict){
  psychTestR::new_timeline(
    psychTestR::one_button_page(
    body = shiny::div(
      shiny::h4(psychTestR::i18n("WELCOME")),
      shiny::div(psychTestR::i18n("INTRO_TEXT"),
                 style = "margin-left:0%;width:50%;min-width:400px;text-align:justify;margin-bottom:30px")
    ),
    button_text = psychTestR::i18n("CONTINUE")
  ), dict = dict)
}


MSM_finished_page <- function(dict = MSM::MSM_dict, text_id = "FINISHED"){
  script <- 'window.removeEventListener("keydown", register_key, true);console.log("Removed keydown listener")'
  psychTestR::new_timeline(
    psychTestR::one_button_page(
      body = shiny::div(
        shiny::div(psychTestR::i18n(text_id),
                   shiny::tags$script(shiny::HTML(script)),
                   style = "margin-left:0%;display:block;margin-bottom:30px"),
        button_text = psychTestR::i18n("CONTINUE")
      )
    ), dict = dict)
}

MSM_final_page <- function(dict = MSM::MSM_dict){
  script <- 'window.removeEventListener("keydown", register_key, true);console.log("Removed keydown listener")'
  psychTestR::new_timeline(
    psychTestR::final_page(
      body = shiny::div(
        shiny::h4(psychTestR::i18n("THANK_YOU")),
        shiny::tags$script(shiny::HTML(script)),
        shiny::div(psychTestR::i18n("CLOSE_BROWSER"),
                   style = "margin-left:0%;display:block")
      )
    ), dict = dict)
}
