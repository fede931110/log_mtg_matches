// obj_dropdown  –  Draw GUI

var _label = (array_length(options) > 0) ? options[selected] : placeholder;

// === Testina chiusa ===
draw_set_colour(_open ? COL_GOLD_DARK : (_hover ? make_colour_rgb(75, 55, 40) : COL_BTN_SECONDARY));
draw_roundrect_ext(x, y, x + w, y + h, CORNER_RADIUS, CORNER_RADIUS, false);
draw_set_colour(_open ? COL_GOLD : COL_BORDER);
draw_roundrect_ext(x, y, x + w, y + h, CORNER_RADIUS, CORNER_RADIUS, true);

draw_set_font(fnt_body);
draw_set_colour(_open ? COL_GOLD : COL_SURFACE);
draw_set_halign(fa_left);
draw_set_valign(fa_middle);
draw_text(x + 10, y + h / 2, _label);

draw_set_halign(fa_right);
draw_set_colour(COL_GOLD);
draw_text(x + w - 10, y + h / 2, _open ? "▲" : "▼");

if (!_open) exit;

// === Lista aperta ===
var _vis    = min(array_length(options), _max_visible);
var _list_h = _vis * _row_h;
var _lx2    = x + w;
var _ly1    = y + h;
var _ly2    = _ly1 + _list_h;

// sfondo lista
draw_set_colour(COL_SURFACE);
draw_roundrect_ext(x, _ly1, _lx2, _ly2, CORNER_RADIUS, CORNER_RADIUS, false);
draw_set_colour(COL_GOLD);
draw_roundrect_ext(x, _ly1, _lx2, _ly2, CORNER_RADIUS, CORNER_RADIUS, true);

var _mx = device_mouse_x_to_gui(0);
var _my = device_mouse_y_to_gui(0);

for (var i = 0; i < _vis; i++) {
    var _opt_i = i + _scroll;
    if (_opt_i >= array_length(options)) break;
    var _ry = _ly1 + i * _row_h;
    var _hovered  = point_in_rectangle(_mx, _my, x, _ry, _lx2, _ry + _row_h);
    var _selected = (_opt_i == selected);

    if (_hovered) {
        draw_set_colour(COL_SURFACE_ALT);
        draw_rectangle(x + 1, _ry, _lx2 - 1, _ry + _row_h - 1, false);
    }
    if (_selected) {
        draw_set_colour(COL_GOLD);
        draw_set_alpha(0.18);
        draw_rectangle(x + 1, _ry, _lx2 - 1, _ry + _row_h - 1, false);
        draw_set_alpha(1);
    }

    draw_set_colour(_selected ? COL_GOLD_DARK : COL_INK);
    draw_set_font(_selected ? fnt_body_bold : fnt_body);
    draw_set_halign(fa_left);
    draw_set_valign(fa_middle);
    draw_text(x + 10, _ry + _row_h / 2, options[_opt_i]);

    if (i < _vis - 1) {
        draw_set_colour(COL_BORDER);
        draw_set_alpha(0.25);
        draw_line(x + 6, _ry + _row_h, _lx2 - 6, _ry + _row_h);
        draw_set_alpha(1);
    }
}
