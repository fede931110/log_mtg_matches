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
draw_separator(_m, _sw - _m, _m + 46);

// === Pannello statistiche globali ===
// btn_nuova è a y=MARGIN+60=84, h=BTN_HEIGHT=40 → bottom=124
var _py1 = _m + 60 + BTN_HEIGHT + GAP;  // 136
draw_panel(_m, _py1, _sw - _m, _py1 + 130);

draw_set_font(fnt_body_bold);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

var _px = _m + 16;
var _pt = _py1 + 16;

draw_set_colour(COL_INK);
draw_text(_px, _pt, "Partite totali:  " + string(_s.totale));

draw_set_colour(COL_WIN);
draw_text(_px, _pt + 36, "Vittorie:   " + string(_s.vittorie));
draw_set_colour(COL_LOSS);
draw_text(_px + 160, _pt + 36, "Sconfitte:  " + string(_s.sconfitte));

draw_set_colour(COL_GOLD);
draw_text(_px, _pt + 72, "Win rate:  " + win_pct_str(_s.vittorie, _s.totale));

// === Pannello modalità (si estende fino alla navbar) ===
var _mod_list = global.lookup.modalita;
var _n_mod    = array_length(_mod_list);
var _my1      = _py1 + 130 + GAP;
var _my2      = _sh - NAVBAR_HEIGHT - GAP;
var _avail_rh = _my2 - _my1 - 36;
var _row_h    = (_n_mod > 0) ? max(44, min(80, floor(_avail_rh / _n_mod))) : 44;

draw_panel(_m, _my1, _sw - _m, _my2);

draw_set_font(fnt_small);
draw_set_colour(COL_INK_FADED);
draw_set_valign(fa_middle);
draw_set_halign(fa_left);
draw_text(_m + 16, _my1 + 18, "MODALITA'");
draw_set_halign(fa_center);
draw_text(_sw / 2, _my1 + 18, "RECORD");
draw_set_halign(fa_right);
draw_text(_sw - _m - 16, _my1 + 18, "WIN%");
draw_separator(_m + 4, _sw - _m - 4, _my1 + 34);

for (var i = 0; i < _n_mod; i++) {
    var _nome = _mod_list[i].nome;
    var _ry   = _my1 + 36 + i * _row_h;
    var _bk   = struct_exists(_s.per_modalita, _nome)
                ? _s.per_modalita[$ _nome]
                : { totale: 0, vittorie: 0, sconfitte: 0 };

    if (i mod 2 == 1) {
        draw_set_colour(COL_SURFACE_ALT);
        draw_set_alpha(0.3);
        draw_rectangle(_m + 1, _ry, _sw - _m - 1, _ry + _row_h, false);
        draw_set_alpha(1);
    }

    draw_set_font(fnt_body);
    draw_set_valign(fa_middle);

    draw_set_colour(COL_INK);
    draw_set_halign(fa_left);
    draw_text(_m + 16, _ry + _row_h / 2, _nome);

    draw_set_halign(fa_center);
    draw_text(_sw / 2, _ry + _row_h / 2,
              string(_bk.vittorie) + "W  " + string(_bk.sconfitte) + "L");

    draw_set_halign(fa_right);
    draw_set_colour(COL_GOLD);
    draw_text(_sw - _m - 16, _ry + _row_h / 2, win_pct_str(_bk.vittorie, _bk.totale));
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
