// obj_input_field  –  Create
// Layer: GUI  |  Depth: -100
//
// Utilizzo:
//   var _inp   = instance_create_layer(x, y, "GUI", obj_input_field);
//   _inp.w         = 240;
//   _inp.max_len   = 32;
//   _inp.on_submit = function(value) { my_var = value; };

w          = 240;
h          = INPUT_HEIGHT;
max_len    = 32;
on_submit  = undefined;
placeholder = "Scrivi qui...";

_text      = "";
_focused   = false;
_cursor    = 0;
_blink     = 0;
