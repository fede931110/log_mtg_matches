// obj_button  –  Step

if (!enabled) {
    _hover   = false;
    _pressed = false;
    exit;
}

var _mx = device_mouse_x_to_gui(0);
var _my = device_mouse_y_to_gui(0);
_hover = point_in_rectangle(_mx, _my, x, y, x + w, y + h);

if (_hover && mouse_check_button_pressed(mb_left))  _pressed = true;
if (!mouse_check_button(mb_left))                   _pressed = false;

if (_hover && mouse_check_button_released(mb_left) && on_click != undefined) {
    on_click();
}
