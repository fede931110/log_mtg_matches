// obj_controller_menu  –  Create
// Posizionato in rm_menu. Qui viene creato anche obj_data_manager (se non esiste già).

if (!instance_exists(obj_data_manager)) {
    instance_create_layer(0, 0, "Instances", obj_data_manager);
}

// Bottone nuova partita (centrato in alto)
var _sw = display_get_gui_width();
var _bw = 220;
var _bx = _sw / 2 - _bw / 2;

btn_nuova = instance_create_layer(_bx, MARGIN + 60, "GUI", obj_button);
btn_nuova.label    = "+ Nuova Partita";
btn_nuova.w        = _bw;
btn_nuova.style    = "primary";
btn_nuova.on_click = function() { room_goto(rm_log_match); };
