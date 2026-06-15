// obj_input_field  –  Step

// Focus / unfocus
if (mouse_check_button_pressed(mb_left)) {
    _focused = gui_mouse_in(x, y, x + w, y + h);
}

if (!_focused) exit;

// Blink cursore
_blink = (_blink + 1) mod 60;

// Backspace
if (keyboard_check_pressed(vk_backspace) && string_length(_text) > 0) {
    _text  = string_copy(_text, 1, string_length(_text) - 1);
    _cursor = string_length(_text);
}

// Invio  →  conferma (vk_enter cattura sia Return che Numpad Enter)
if (keyboard_check_pressed(vk_enter)) {
    if (on_submit != undefined && string_length(_text) > 0) {
        on_submit(_text);
        _text    = "";
        _focused = false;
    }
}

// Tasto Escape  →  annulla
if (keyboard_check_pressed(vk_escape)) {
    _text    = "";
    _focused = false;
}

// Caratteri digitati
var _char = keyboard_lastchar;
if (_char != "" && string_length(_text) < max_len) {
    _text  += _char;
    _cursor = string_length(_text);
}
keyboard_lastchar = "";
