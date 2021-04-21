key_logger_script <- "
var time_points = [];
Window.prototype._addEventListener = Window.prototype.addEventListener;

Window.prototype.addEventListener = function(a, b, c) {
   console.log('c = ' + c)
   if (c == undefined) c = false;
   this._addEventListener(a, b, c);
   if (!this.eventListenerList) this.eventListenerList = {};
   if (!this.eventListenerList[a]) this.eventListenerList[a] = [];
   this.eventListenerList[a].push({listener:b, options:c });
};

EventTarget.prototype._getEventListeners = function(a) {
   if (! this.eventListenerList) this.eventListenerList = {};
   if (a == undefined)  { return this.eventListenerList; }
   return this.eventListenerList[a];
};

document.getElementById('marker_seq').style.visibility = 'hidden';

num_event_listeners = Object.keys(window._getEventListeners()).length
console.log('Num event listeners: ' + num_event_listeners)

if(num_event_listeners == 0) {
  window.addEventListener('keydown', register_key);
  console.log('Added keydown event listener')
}

String.prototype.toMMSSZZ = function () {
    var msec_num = parseInt(this, 10); // don't forget the second param
    var sec_num = Math.floor(msec_num/1000);
    var milliseconds = msec_num - 1000 * sec_num;

    var hours   = Math.floor(sec_num / 3600);
    var minutes = Math.floor((sec_num - (hours * 3600)) / 60);
    var seconds = sec_num - (hours * 3600) - (minutes * 60);
    //if (hours   < 10) {hours   = '0' + hours;}
    //if (minutes < 10) {minutes = '0' + minutes;}
    //if (seconds < 10) {seconds = '0' + seconds;}
    return String(minutes).padStart(2, '0') + ':' + String(seconds).padStart(2, '0') + '.' + String(milliseconds).padStart(3, '0');
}
var give_key_feedback = true;
function register_key(e) {
  var key = e.which || e.keyCode;

  if (key === 32) { // spacebar

   // eat the spacebar, so it does not stop audio player
   e.preventDefault();

  }
  if(media_played == false){
    return
  }
	if(media_played == 'over'){
    Shiny.onInputChange('next_page', performance.now());
  	return
	}
	var tp = new Date().getTime() - window.startTime
  time_points.push(tp);
  //console.log('Time: ' + tp)
  if(give_key_feedback){
    marker_count = String(time_points.length).padStart(2, '0')
    document.getElementById('marker_feedback').innerHTML = 'Marker ' + marker_count + ': ' + String(Math.round(tp)).toMMSSZZ()
  }
  Shiny.setInputValue('marker_seq', time_points.join(','));

}
"

media_js <- list(
  media_not_played = "var media_played = false;",
  media_played = "media_played = true;",
  media_ended =  "media_played = 'over';",
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
    onended = media_js$media_ended
  )
  if(show_controls){
    return(shiny::tags$div(audio))
  }
  ret <- shiny::tags$div(media_mobile_play_button, audio)
  print(ret)
  ret
}


get_key_input <- function(stimulus_url){
  #browser()
  prompt <- shiny::div(psychTestR::i18n("PROMPT"), style = "text-align:justify;")
  marker_seq <-   shiny::textInput("marker_seq", label="", value="", width = 100)
  marker_feedback <- shiny::div(id = "marker_feedback", "Marker: ---", style = "text-align:center")
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
    style = "text-align:justify;width:50%;min-width:500px;visibility: visible"
  )
}

MSM_page <- function(label,
                     stimulus,
                     header,
                     audio_dir = "https://s3-eu-west-1.amazonaws.com/media.dots.org/stimuli/MSM",
                     save_answer = TRUE,
                     admin_ui = NULL) {
  #browser()
  stopifnot(is.scalar.character(label))
  stimulus_url <- file.path(audio_dir, stimulus)
  prompt <- get_key_input(stimulus_url)
  get_answer <- function(input, state, ...){
    tp <- strsplit(input$marker_seq, ",") %>% unlist() %>% as.integer()
    print(tibble(stimulus = stimulus, marker = tp, pos = 1:length(tp)))
    tibble(stimulus = stimulus, marker = tp, pos = 1:length(tp))
  }
  ui <- shiny::div(header, shiny::p(stimulus), prompt)
  psychTestR::page(ui = ui, label = label, get_answer = get_answer,
                   save_answer = save_answer, validate = NULL,
                   on_complete = NULL, final = FALSE,
                   admin_ui = admin_ui)
}

