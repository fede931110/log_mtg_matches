// obj_dropdown  –  Step

// Reset click-consumed flag once per frame (runs on the oldest living dropdown instance)
if (id == instance_find(obj_dropdown, 0)) {
    global.dd_click_handled = false;
}

if (!enabled) { _open = false; exit; }

var _mx = device_mouse_x_to_gui(0);
var _my = device_mouse_y_to_gui(0);
_hover = point_in_rectangle(_mx, _my, x, y, x + w, y + h);

if (mouse_check_button_pressed(mb_left)) {
    if (_open) {
        // This dropdown is open — process list click and consume the event
        var _vis     = min(array_length(options), _max_visible);
        var _list_h  = _vis * _row_h;
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
        global.dd_click_handled = true;
    } else if (_hover && !global.dd_click_handled) {
        // Close any other open dropdown first
        with (obj_dropdown) {
            if (id != other.id && _open) {
                _open = false;
                depth = _depth_default;
            }
        }
        _open   = true;
        _scroll = 0;
        depth   = -9999;
        global.dd_click_handled = true;
    }
}

if (_open) {
    var _max_scroll = max(0, array_length(options) - _max_visible);
    if (mouse_wheel_down()) _scroll = min(_scroll + 1, _max_scroll);
    if (mouse_wheel_up())   _scroll = max(_scroll - 1, 0);
}
