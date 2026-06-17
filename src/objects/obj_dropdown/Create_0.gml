// obj_dropdown  –  Create
// Layer: GUI  |  Depth: -100 (quando chiuso); si auto-porta a -9999 quando aperto
//
// Utilizzo:
//   var _dd     = instance_create_layer(x, y, "GUI", obj_dropdown);
//   _dd.options   = global.lookup.miei_mazzi;
//   _dd.w         = 220;
//   _dd.selected  = 0;
//   _dd.on_change = function(idx, value) { my_var = value; };

options       = [];
w             = 220;
h             = INPUT_HEIGHT;
selected      = 0;
on_change     = undefined;
enabled       = true;
placeholder   = "Seleziona...";

_open          = false;
_hover         = false;
_row_h         = 32;
_max_visible   = 7;
_scroll        = 0;
_depth_default = depth;
