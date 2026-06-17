// obj_input_field  –  Draw GUI

// Sfondo
draw_set_colour(_focused ? make_colour_rgb(250, 240, 215) : COL_SURFACE_ALT);
draw_roundrect_ext(x, y, x + w, y + h, CORNER_RADIUS, CORNER_RADIUS, false);

// Bordo: oro se focused, cuoio altrimenti
draw_set_colour(_focused ? COL_GOLD : COL_BORDER);
draw_roundrect_ext(x, y, x + w, y + h, CORNER_RADIUS, CORNER_RADIUS, true);

// Testo o placeholder
draw_set_font(fnt_body);
draw_set_halign(fa_left);
draw_set_valign(fa_middle);
var _display = (_text == "" && !_focused) ? placeholder : _text;
draw_set_colour(_text == "" ? COL_INK_FADED : COL_INK);
draw_text(x + 10, y + h / 2, _display);

// Cursore lampeggiante
if (_focused && _blink < 30) {
    var _tw = string_width(_text);
    draw_set_colour(COL_GOLD);
    draw_line(x + 10 + _tw + 1, y + 6, x + 10 + _tw + 1, y + h - 6);
}
