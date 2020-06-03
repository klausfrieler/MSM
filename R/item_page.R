
scale_coords <- function(coords, scale_factor = 1){
  if(length(coords) > 1){
    tmp <- sapply(coords, scale_coords, scale_factor)
    names(tmp) <- NULL
    return(tmp)
  }
  paste(
    round(as.integer(unlist(strsplit(coords, ",")))*scale_factor),
    collapse=",")
}

num_positions <- tibble(pos = 0:9,
                        coords = c("101,306,200,404",
                                   "0,1,100,104", "101,1,200,104", "201,1,299,104",
                                   "0,106,100,206", "100,106,200,206", "201,106,299,206",
                                   "0,208,100,300", "101,208,200,300", "201,208,299,300"
                        )
)

generate_area_entry <- function(position, scale_factor = 1){
  if(length(position) > 1){
    return(lapply(position, generate_area_entry, scale_factor))
  }
  num_positions <- num_positions %>% mutate(coords = scale_coords(coords, scale_factor))
  #print(scale_coords(dot_positions$coords, scale_factor))
  click_handler <- sprintf("register_click(%d)", position)
  coords <- num_positions %>% filter(pos == position) %>% pull(coords)

  shiny::tags$area(
    shape = "rect",
    href = "#",
    coords = coords[1],
    alt = position,
    title = position,
    onclick = click_handler)

}

generate_pos_input <- function(position){
  id <- sprintf("position%d", position)
  style <- ifelse(position != 1, "margin-left:20px", "margin-left:0px")
  shiny::tags$input(id = id, name = id, size = 1, style= style)
}
click_script <- "
var clicks = []
var max_length = %d
document.getElementById('pos_seq').style.visibility = 'hidden'
function register_click(position){
clicks.push(position)
Shiny.setInputValue('pos_seq', clicks.join(''));
//document.getElementById('pos_seq').value = clicks.join('')
if(clicks.length == max_length){
Shiny.onInputChange('next_page', performance.now())
}
}
"

get_prompt_num_pad <- function(seq_len){
  prompt <- psychTestR::i18n("PROMPT")
  click_area <- shiny::img(src = sprintf("http://media.gold-msi.org/test_materials/BDS/numpad.jpg"),
                           height = "404",
                           usemap = "#num_positions")
  map <- shiny::tags$map(name = "num_positions", generate_area_entry(0:9, scale_factor = 1))
  img <- shiny::div(shiny::p(prompt), click_area)
  pos_seq <-   shiny::textInput("pos_seq", label="", value="", width = 100)
  pos_inputs <- shiny::div(id = "position_inputs", style="margin-left:50%;visibility:hidden", pos_seq)
  #printf("Get_prompt_num_pad called with %d", seq_len)
  script <- shiny::tags$script(shiny::HTML(sprintf(click_script, seq_len)))
  ui <- shiny::div(id = "position_clicker", script, img, map, pos_inputs)

  shiny::div(
    ui,
    #trigger_button("next", button_text),
    style = "visibility: hidden",
    id = "prompt"
  )
}

BDS_page <- function(label, stimulus, seq_len,
                     save_answer = TRUE,
                     get_answer = NULL,
                     validate = NULL,
                     on_complete = NULL,
                     admin_ui = NULL) {
  stopifnot(is.scalar.character(label))
  #prompt <- get_prompt()
  prompt <- get_prompt_num_pad(seq_len)

  ui <- shiny::div(stimulus, prompt)
  psychTestR::page(ui = ui, label = label, get_answer = get_answer,
                   save_answer = save_answer, validate = validate,
                   on_complete = on_complete, final = FALSE,
                   admin_ui = admin_ui)
}

