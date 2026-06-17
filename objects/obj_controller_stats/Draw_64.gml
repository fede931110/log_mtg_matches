// obj_controller_stats  –  Draw GUI

var _sw  = display_get_gui_width();
var _sh  = display_get_gui_height();
var _m   = MARGIN;

draw_set_colour(COL_BG);
draw_rectangle(0, 0, _sw, _sh, false);

draw_screen_title(_m, _m, "STATISTICHE");
draw_separator(_m, _sw - _m, _m + 46);

// Tab bar
var _tab_labels = ["Modalita'", "Mazzi", "Avversari"];
var _tw  = (_sw - _m * 2) / 3;
var _ty1 = _m + 50;
for (var i = 0; i < 3; i++) {
    var _tx1 = _m + i * _tw;
    var _act = (i == _tab);
    draw_set_colour(_act ? COL_SURFACE : COL_SURFACE_ALT);
    draw_roundrect_ext(_tx1, _ty1, _tx1 + _tw, _ty1 + TAB_HEIGHT, CORNER_RADIUS, CORNER_RADIUS, false);
    draw_set_colour(_act ? COL_GOLD : COL_BORDER);
    draw_roundrect_ext(_tx1, _ty1, _tx1 + _tw, _ty1 + TAB_HEIGHT, CORNER_RADIUS, CORNER_RADIUS, true);
    draw_set_font(_act ? fnt_body_bold : fnt_body);
    draw_set_colour(_act ? COL_INK : COL_INK_FADED);
    draw_set_halign(fa_center); draw_set_valign(fa_middle);
    draw_text(_tx1 + _tw / 2, _ty1 + TAB_HEIGHT / 2, _tab_labels[i]);
    if (_act) {
        draw_set_colour(COL_GOLD);
        draw_rectangle(_tx1 + 4, _ty1 + TAB_HEIGHT - 3, _tx1 + _tw - 4, _ty1 + TAB_HEIGHT, false);
    }
    if (gui_mouse_click(_tx1, _ty1, _tx1 + _tw, _ty1 + TAB_HEIGHT) && !_act) {
        _tab = i; _scroll = 0;
    }
}

var _py1  = _ty1 + TAB_HEIGHT + GAP;
var _py2  = _sh - NAVBAR_HEIGHT - GAP;
var _row_h = 40;

draw_panel(_m, _py1, _sw - _m, _py2);

// Intestazione tabella
var _cols = ["NOME", "PARTITE", "W", "L", "WIN%"];
var _cx   = [_m + 8, _sw * 0.44, _sw * 0.59, _sw * 0.72, _sw - _m - 8];
var _calign = [fa_left, fa_center, fa_center, fa_center, fa_right];
draw_set_font(fnt_small);
draw_set_colour(COL_INK_FADED);
for (var i = 0; i < array_length(_cols); i++) {
    draw_set_halign(_calign[i]);
    draw_text(_cx[i], _py1 + 12, _cols[i]);
}
draw_separator(_m + 4, _sw - _m - 4, _py1 + 26);

// Dati in base alla tab
var _items = _get_stat_rows();
var _visible = floor((_py2 - _py1 - 32) / _row_h);
var _max_scroll = max(0, array_length(_items) - _visible);
if (mouse_wheel_down()) _scroll = min(_scroll + 1, _max_scroll);
if (mouse_wheel_up())   _scroll = max(_scroll - 1, 0);

for (var i = 0; i < _visible; i++) {
    var _idx = i + _scroll;
    if (_idx >= array_length(_items)) break;
    var _row = _items[_idx];
    var _ry  = _py1 + 32 + i * _row_h;

    if (i mod 2 == 1) {
        draw_set_colour(COL_SURFACE_ALT);
        draw_set_alpha(0.35);
        draw_rectangle(_m + 1, _ry, _sw - _m - 1, _ry + _row_h - 1, false);
        draw_set_alpha(1);
    }

    draw_set_font(fnt_body);
    for (var c = 0; c < array_length(_cols); c++) {
        draw_set_halign(_calign[c]);
        var _val = _row[c];
        draw_set_colour(c == 4 ? COL_GOLD : COL_INK);
        draw_set_valign(fa_middle);
        draw_text(_cx[c], _ry + _row_h / 2, _val);
    }
}

draw_navbar(ROOM_STATS);

if (mouse_check_button_pressed(mb_left)) {
    var _nx = device_mouse_x_to_gui(0);
    var _ny = device_mouse_y_to_gui(0);
    if (_ny >= _sh - NAVBAR_HEIGHT) {
        var _ntabs = [ROOM_MENU, ROOM_HISTORY, ROOM_STATS, ROOM_SETTINGS];
        var _ntw   = _sw / array_length(_ntabs);
        var _nti   = floor(_nx / _ntw);
        if (_nti >= 0 && _nti < array_length(_ntabs) && _ntabs[_nti] != ROOM_STATS) {
            navbar_go(_ntabs[_nti]);
        }
    }
}

// ============================================================
function _get_stat_rows() {
    var _out  = [];
    var _src  = {};
    switch (_tab) {
        case 0: _src = global.stats.per_modalita;   break;
        case 1: _src = global.stats.per_mazzo;      break;
        case 2: _src = global.stats.per_avversario; break;
    }
    var _keys = struct_get_names(_src);
    for (var i = 0; i < array_length(_keys); i++) {
        var _k = _keys[i];
        var _b = _src[$ _k];
        var _nome_disp = (string_length(_k) > 14) ? (string_copy(_k, 1, 12) + "...") : _k;
        array_push(_out, [
            _nome_disp,
            string(_b.totale),
            string(_b.vittorie),
            string(_b.sconfitte),
            win_pct_str(_b.vittorie, _b.totale)
        ]);
    }
    // Ordina per partite totali decrescente
    for (var a = 0; a < array_length(_out) - 1; a++) {
        for (var b = 0; b < array_length(_out) - a - 1; b++) {
            if (real(_out[b][1]) < real(_out[b+1][1])) {
                var _tmp   = _out[b];
                _out[b]    = _out[b+1];
                _out[b+1]  = _tmp;
            }
        }
    }
    return _out;
}
