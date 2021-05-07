key_logger_script <- "
var time_points = [];

document.getElementById('marker_seq').style.visibility = 'hidden';

window.addEventListener('keydown', register_key, true);
console.log('Added keydown event listener')
window.addEventListener('touchdown', register_key, true);
console.log('Added touchdown event listener')

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
    return false;
  }
	if(media_played == 'over'){
    Shiny.onInputChange('next_page', performance.now());
  	return false;
	}
	var tp = new Date().getTime() - window.startTime
  time_points.push(tp);
  //console.log('Time: ' + tp)
  if(give_key_feedback){
    marker_count = String(time_points.length).padStart(2, '0')
    document.getElementById('marker_feedback').innerHTML = '&#x25CF;'.repeat(time_points.length)
    //document.getElementById('marker_feedback').innerHTML = 'Marker ' + marker_count + ': ' + String(Math.round(tp)).toMMSSZZ()
  }
  Shiny.setInputValue('marker_seq', time_points.join(','));

}
"

clean_up_script <- "
  window.removeEventListener('keydown', register_key, true);
  console.log('Removed keydown listener');
  window.removeEventListener('touchdown', register_key, true);
  console.log('Removed touchdown listener');
"
key_logger_script2 <- "
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
  window.addEventListener('keydown', register_key, true);
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
  if(key != 32){
    return;
  }
  if (key === 32) { // spacebar

   // eat the spacebar, so it does not stop audio player
   e.preventDefault();

  }
  if(media_played == false){
    return false;
  }
	if(media_played == 'over'){
    Shiny.onInputChange('next_page', performance.now());
  	return false;
	}
	var tp = new Date().getTime() - window.startTime
  time_points.push(tp);
  //console.log('Time: ' + tp)
  if(give_key_feedback){
    marker_count = String(time_points.length).padStart(2, '0')
    document.getElementById('marker_feedback').innerHTML = '&#x25CF;'.repeat(time_points.length)
    //document.getElementById('marker_feedback').innerHTML = 'Marker ' + marker_count + ': ' + String(Math.round(tp)).toMMSSZZ()
  }
  Shiny.setInputValue('marker_seq', time_points.join(','));

}
"
