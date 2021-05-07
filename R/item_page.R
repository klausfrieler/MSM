MSM_trigger_button <- function(inputId, label, icon = NULL, width = NULL, enable_after = 0, style = "", ...) {
  inputId <- htmltools::htmlEscape(inputId, attribute = TRUE)
  shiny::tagList(
    shiny::actionButton(
      inputId = inputId, label = label,
      icon = icon, width = width,
      onclick = sprintf("%s;trigger_button(this.id);", clean_up_script),
      disabled = TRUE,
      style = style,
      ...),
    shiny::tags$script(
      sprintf("setTimeout(function() {
                 document.getElementById('%s').disabled = false;
               }, %i);",
              inputId, round(enable_after * 1e3))
    ))
}
media_js <- list(
  media_not_played = "var media_played = false;",
  media_played = "media_played = true;",
  media_ended =  "media_played = 'over';document.getElementById('next').style.visibility = 'inherit';",
  play_media = "document.getElementById('media').play();window.startTime = new Date().getTime();",
  show_media   = paste0("if (!media_played) ",
                        "{document.getElementById('media')",
                        ".style.visibility='inherit'};"),
  hide_media   = paste0("if (media_played) ",
                        "{document.getElementById('media')",
                        ".style.visibility='hidden'};"),
  show_media_btn = paste0("if (!media_played) ",
                          "{document.getElementById('btn_play_media')",
                          ".style.visibility='inherit'};"),
  hide_media_btn = paste0("document.getElementById('btn_play_media')",
                          ".style.visibility='hidden';"),
  show_responses = "media_played = 'over'"
)

media_mobile_play_button <- shiny::tags$p(
  shiny::tags$button(shiny::tags$span("\u25B6"),
                     type = "button",
                     id = "btn_play_media",
                     style = "visibility: hidden",
                     onclick = media_js$play_media)
)

get_audio_ui <- function(url,
                         type = tools::file_ext(url),
                         autoplay = FALSE,
                         show_controls = TRUE,
                         width = 0,
                         wait = TRUE,
                         loop = FALSE) {
  #print(url)
  stopifnot(purrr::is_scalar_character(url),
            purrr::is_scalar_character(type),
            purrr::is_scalar_logical(wait),
            purrr::is_scalar_logical(loop))
  src    <- shiny::tags$source(src = url, type = paste0("audio/", type))
  script <- shiny::tags$script(shiny::HTML(media_js$media_not_played))
  audio  <- shiny::tags$audio(
    script,
    src,
    id = "media",
    preload = "auto",
    autoplay = if(autoplay) "autoplay",
    width = width,
    loop = if (loop) "loop",
    oncanplaythrough = media_js$show_media_btn,
    onplay = paste0(media_js$media_played, media_js$play_media, media_js$hide_media, media_js$hide_media_btn),
    controls = if (show_controls) "controls",
    controlslist = "nodownload noremoteplayback",
    onended = media_js$media_ended
  )
  if(show_controls){
    return(shiny::tags$div(audio))
  }
  ret <- shiny::tags$div(media_mobile_play_button, audio)
  print(ret)
  ret
}


get_key_input <- function(stimulus_url, credits = ""){
  #browser()
  prompt <- shiny::div(psychTestR::i18n("PROMPT"), style = "text-align:justify;")
  if(nchar(credits) > 0){
    prompt <- shiny::div(shiny::p(psychTestR::i18n("PROMPT")),
                         #shiny::p(credits, style = "font-size:x-small;font-style:normal"),
                         style = "text-align:justify;")

  }
  marker_seq <-   shiny::textInput("marker_seq", label="", value="", width = 100)
  marker_feedback <- shiny::div(id = "marker_feedback", "", style = "text-align:left;min-height:1em;")
  marker_input <- shiny::div(id = "marker_input", marker_seq )
  audio_ui <- shiny::div(get_audio_ui(stimulus_url), style = "text-align:center;margin-top:20px;")
  script <- shiny::tags$script(shiny::HTML(key_logger_script))
  #ui <- shiny::div(id = "segment_marker", script, prompt, marker_input, audio_ui)

  shiny::div(
    id = "prompt",
    script,
    prompt,
    audio_ui,
    marker_input,
    marker_feedback,
    style = "text-align:justify;width:50%;min-width:500px;visibility: inherit"
  )
}

MSM_page <- function(label,
                     stimulus,
                     header,
                     audio_dir = "https://s3-eu-west-1.amazonaws.com/media.dots.org/stimuli/MSM",
                     credits = "",
                     save_answer = TRUE,
                     admin_ui = NULL) {
  #browser()
  stopifnot(is.scalar.character(label))
  stimulus_url <- file.path(audio_dir, stimulus)
  prompt <- get_key_input(stimulus_url, credits)
  get_answer <- function(input, state, ...){
    #browser()
    tp <- strsplit(input$marker_seq, ",") %>% unlist() %>% as.integer()
    item_number <- psychTestR::get_local(key = "item_number", state = state)
    psychTestR::set_local(key = "item_number", value = item_number + 1L , state = state)
    #print(tibble(stimulus = stimulus, marker = tp, pos = 1:length(tp)))
    tibble(stimulus = stimulus, marker = input$marker_seq, count = length(tp))
  }
  ui <- shiny::div(header,
                   # shiny::p(stimulus),
                   prompt,
                   MSM_trigger_button(inputId = "next", psychTestR::i18n("CONTINUE"), style = "visibility:hidden"))

  psychTestR::page(ui = ui, label = label, get_answer = get_answer,
                   save_answer = save_answer, validate = NULL,
                   on_complete = NULL, final = FALSE,
                   admin_ui = admin_ui)
}

inbetween_page <- function(label = "liking", item_number, prompt = "LIKING_PROMPT"){
  labels <- purrr::map_chr(sprintf("NUM_LIKERT%d", 1:6), psychTestR::i18n)
  choices <- as.character(1:6)
  label <-sprintf("%s%d", label, item_number)
  prompt <- psychTestR::i18n(prompt)
  psychTestR::NAFC_page(label = label,
                        prompt = prompt,
                        choices = choices,
                        labels = labels,
                        save_answer = T,
                        arrange_vertically = FALSE,
                        button_style = "min-width:75px")
}

