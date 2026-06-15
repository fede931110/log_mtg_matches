// obj_button  –  Create
// Layer: GUI  |  Depth: -100
//
// Utilizzo:
//   var _btn    = instance_create_layer(x, y, "GUI", obj_button);
//   _btn.label    = "Salva";
//   _btn.w        = 160;
//   _btn.h        = BTN_HEIGHT;
//   _btn.style    = "primary";    // "primary" | "secondary" | "danger"
//   _btn.on_click = function() { /* callback */ };
//   _btn.enabled  = true;

label    = "Button";
w        = 160;
h        = BTN_HEIGHT;
style    = "primary";
on_click = undefined;
enabled  = true;

_hover   = false;
_pressed = false;
