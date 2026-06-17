// obj_controller_menu  –  Draw GUI

var _sw  = display_get_gui_width();
var _sh  = display_get_gui_height();
var _s   = global.stats;
var _m   = MARGIN;

// Sfondo
draw_set_colour(COL_BG);
draw_rectangle(0, 0, _sw, _sh, false);

// Titolo
draw_screen_title(_m, _m, "LOG MTG MATCHES");
draw_separator(_m, _sw - _m, _m + 38);

// === Pannello statistiche globali ===
var _py1 = _m + 50;
draw_panel(_m, _py1, _sw - _m, _py1 + 90);

draw_set_font(fnt_body_bold);
draw_set_colour(COL_INK);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

var _px = _m + 16;
var _pt = _py1 + 14;

draw_set_font(fnt_body_bold);
draw_set_colour(COL_INK);
draw_text(_px, _pt, "Partite totali:  " + string(_s.totale));

draw_set_colour(COL_WIN);
draw_text(_px, _pt + 24, "Vittorie:   " + string(_s.vittorie));
draw_set_colour(COL_LOSS);
draw_text(_px + 160, _pt + 24, "Sconfitte:  " + string(_s.sconfitte));

draw_set_colour(COL_GOLD);
draw_text(_px, _pt + 48, "Win rate:  " + win_pct_str(_s.vittorie, _s.totale));

// === Pannello per modalità ===
var _mod_list = global.lookup.modalita;
var _row_h    = 36;
var _my1      = _py1 + 90 + GAP + BTN_HEIGHT + GAP;
draw_panel(_m, _my1, _sw - _m, _my1 + 16 + array_length(_mod_list) * _row_h);

draw_set_font(fnt_body_bold);
draw_set_colour(COL_INK_FADED);
draw_set_halign(fa_left);
draw_text(_m + 16, _my1 + 10, "MODALITÀ");
draw_set_halign(fa_center);
draw_text(_sw / 2, _my1 + 10, "PARTITE");
draw_set_halign(fa_right);
draw_text(_sw - _m - 16, _my1 + 10, "WIN%");
draw_separator(_m + 4, _sw - _m - 4, _my1 + 28);

for (var i = 0; i < array_length(_mod_list); i++) {
    var _nome = _mod_list[i].nome;
    var _ry   = _my1 + 32 + i * _row_h;
    var _bk   = struct_exists(_s.per_modalita, _nome)
                ? _s.per_modalita[$ _nome]
                : { totale: 0, vittorie: 0, sconfitte: 0 };

    // riga alternata
    if (i mod 2 == 1) {
        draw_set_colour(COL_SURFACE_ALT);
        draw_set_alpha(0.3);
        draw_rectangle(_m + 1, _ry - 2, _sw - _m - 1, _ry + _row_h - 4, false);
        draw_set_alpha(1);
    }

    draw_set_font(fnt_body);
    draw_set_colour(COL_INK);
    draw_set_halign(fa_left);
    draw_text(_m + 16, _ry + _row_h/2 - 8, _nome);
    draw_set_halign(fa_center);
    draw_set_colour(COL_INK);
    draw_text(_sw / 2, _ry + _row_h/2 - 8,
              string(_bk.vittorie) + "W  " + string(_bk.sconfitte) + "L");
    draw_set_halign(fa_right);
    draw_set_colour(COL_GOLD);
    draw_text(_sw - _m - 16, _ry + _row_h/2 - 8, win_pct_str(_bk.vittorie, _bk.totale));
}

// Navbar
draw_navbar(ROOM_MENU);

// Click navbar
if (mouse_check_button_pressed(mb_left)) {
    var _mx = device_mouse_x_to_gui(0);
    var _my = device_mouse_y_to_gui(0);
    var _ny = _sh - NAVBAR_HEIGHT;
    if (_my >= _ny) {
        var _tabs = [ROOM_MENU, ROOM_HISTORY, ROOM_STATS, ROOM_SETTINGS];
        var _tw   = _sw / array_length(_tabs);
        var _ti   = floor(_mx / _tw);
        if (_ti >= 0 && _ti < array_length(_tabs) && _tabs[_ti] != ROOM_MENU) {
            navbar_go(_tabs[_ti]);
        }
    }
}
