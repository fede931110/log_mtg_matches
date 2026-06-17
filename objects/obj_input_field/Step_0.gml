// obj_input_field  –  Step

if (mouse_check_button_pressed(mb_left)) {
    var _prev = _focused;
    _focused  = gui_mouse_in(x, y, x + w, y + h);

    if (_focused && !_prev) {
        keyboard_string = _text;
        keyboard_virtual_show(kbv_type_default, kbv_returnkey_done, kbv_autocapitalize_none, true);
        _keyboard_shown = true;
        _keyboard_timer = 30;  // wait 30 frames before checking status (keyboard animate-in)
    } else if (!_focused && _prev) {
        keyboard_virtual_hide();
        _keyboard_shown = false;
        _keyboard_timer = 0;
    }
}

// Countdown cooldown
if (_keyboard_timer > 0) _keyboard_timer--;

// Detect keyboard dismissed by the device's own button (Android only)
if (_focused && _keyboard_shown && _keyboard_timer == 0 && os_type == os_android) {
    if (!keyboard_virtual_status()) {
        _focused        = false;
        _keyboard_shown = false;
    }
}

if (!_focused) exit;

// Blink cursore
_blink = (_blink + 1) mod 60;

var _raw = keyboard_string;
if (string_length(_raw) > max_len) {
    _raw = string_copy(_raw, 1, max_len);
    keyboard_string = _raw;
}
_text   = _raw;
_cursor = string_length(_text);

if (keyboard_check_pressed(vk_enter)) {
    if (on_submit != undefined && string_length(_text) > 0) {
        on_submit(_text);
    }
    _text           = "";
    keyboard_string = "";
    _focused        = false;
    _keyboard_shown = false;
    _keyboard_timer = 0;
    keyboard_virtual_hide();
}

if (keyboard_check_pressed(vk_escape)) {
    _text           = "";
    keyboard_string = "";
    _focused        = false;
    _keyboard_shown = false;
    _keyboard_timer = 0;
    keyboard_virtual_hide();
}
