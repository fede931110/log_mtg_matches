// obj_dropdown  –  Step

if (!enabled) { _open = false; exit; }

var _mx = device_mouse_x_to_gui(0);
var _my = device_mouse_y_to_gui(0);
_hover = point_in_rectangle(_mx, _my, x, y, x + w, y + h);

if (mouse_check_button_pressed(mb_left)) {
    if (_hover) {
        _open  = !_open;
        _scroll = 0;
        depth  = _open ? -9999 : _depth_default;
    } else if (_open) {
        var _vis    = min(array_length(options), _max_visible);
        var _list_h = _vis * _row_h;
        var _in_list = point_in_rectangle(_mx, _my, x, y + h, x + w, y + h + _list_h);
        if (_in_list) {
            var _clicked = floor((_my - (y + h)) / _row_h) + _scroll;
            if (_clicked >= 0 && _clicked < array_length(options)) {
                var _prev = selected;
                selected  = _clicked;
                if (on_change != undefined && selected != _prev) {
                    on_change(selected, options[selected]);
                }
            }
        }
        _open  = false;
        depth  = _depth_default;
    }
}

if (_open) {
    var _max_scroll = max(0, array_length(options) - _max_visible);
    if (mouse_wheel_down()) _scroll = min(_scroll + 1, _max_scroll);
    if (mouse_wheel_up())   _scroll = max(_scroll - 1, 0);
}
