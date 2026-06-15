// obj_button  –  Draw GUI

var _col_fill, _col_text, _col_border;

switch (style) {
    case "primary":
        _col_fill   = _hover ? COL_BTN_HOVER : COL_BTN_PRIMARY;
        _col_text   = COL_SURFACE;
        _col_border = COL_GOLD_DARK;
        break;
    case "danger":
        _col_fill   = _hover ? make_colour_rgb(160, 30, 30) : COL_LOSS;
        _col_text   = COL_SURFACE;
        _col_border = make_colour_rgb(100, 10, 10);
        break;
    default: // "secondary"
        _col_fill   = _hover ? make_colour_rgb(75, 55, 40) : COL_BTN_SECONDARY;
        _col_text   = COL_GOLD;
        _col_border = COL_BORDER;
}

if (!enabled) {
    _col_fill   = make_colour_rgb(50, 40, 30);
    _col_text   = COL_INK_FADED;
    _col_border = make_colour_rgb(80, 65, 50);
    draw_set_alpha(0.6);
}

var _ox = _pressed ? 1 : 0;
var _oy = _pressed ? 1 : 0;

// ombra sottile
draw_set_colour(COL_BG);
draw_set_alpha(draw_get_alpha() * 0.3);
draw_roundrect_ext(x+2+_ox, y+2+_oy, x+w+2+_ox, y+h+2+_oy, CORNER_RADIUS, CORNER_RADIUS, false);
draw_set_alpha(enabled ? 1 : 0.6);

draw_set_colour(_col_fill);
draw_roundrect_ext(x+_ox, y+_oy, x+w+_ox, y+h+_oy, CORNER_RADIUS, CORNER_RADIUS, false);
draw_set_colour(_col_border);
draw_roundrect_ext(x+_ox, y+_oy, x+w+_ox, y+h+_oy, CORNER_RADIUS, CORNER_RADIUS, true);

draw_set_colour(_col_text);
draw_set_font(fnt_body_bold);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_text(x + w/2 + _ox, y + h/2 + _oy, label);

draw_set_alpha(1);
