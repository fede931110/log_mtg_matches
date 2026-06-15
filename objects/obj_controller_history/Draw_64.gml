// obj_controller_history  –  Draw GUI
// Layout card a 2 righe:  [data | tipo | badge]  /  [mazzo → vs avversari]

var _sw  = display_get_gui_width();
var _sh  = display_get_gui_height();
var _m   = MARGIN;

draw_set_colour(COL_BG);
draw_rectangle(0, 0, _sw, _sh, false);

draw_screen_title(_m, _m, "STORICO PARTITE");
draw_separator(_m, _sw - _m, _m + 38);

// (obj_dropdown filtri si disegnano autonomamente, posizionati in Create)

// Lista filtrata, ordine inverso (più recenti prima)
var _filtrate = filtra_partite(_f_tipo, _f_risultato, _f_mazzo, _f_avversario);
var _ordinata = [];
for (var i = array_length(_filtrate) - 1; i >= 0; i--) {
    array_push(_ordinata, _filtrate[i]);
}

var _list_y1 = _m + 96;
var _list_y2 = _sh - NAVBAR_HEIGHT - GAP;
var _row_h   = 68;
var _visible = floor((_list_y2 - _list_y1) / _row_h);

var _max_scroll = max(0, array_length(_ordinata) - _visible);
if (mouse_wheel_down()) _scroll = min(_scroll + 1, _max_scroll);
if (mouse_wheel_up())   _scroll = max(_scroll - 1, 0);

// Contatore risultati
draw_set_font(fnt_small);
draw_set_colour(COL_INK_FADED);
draw_set_halign(fa_right);
draw_text(_sw - _m, _list_y1 - 10, string(array_length(_ordinata)) + " partite");

// Righe
for (var i = 0; i < _visible; i++) {
    var _idx = i + _scroll;
    if (_idx >= array_length(_ordinata)) break;
    var _p  = _ordinata[_idx];
    var _ry = _list_y1 + i * _row_h;

    // Sfondo card
    var _sel = (_p.id == _selected_id);
    draw_set_colour(_sel ? COL_SURFACE_ALT : (i mod 2 == 0 ? COL_SURFACE : make_colour_rgb(240, 222, 188)));
    draw_roundrect_ext(_m, _ry + 2, _sw - _m, _ry + _row_h - 2, 4, 4, false);
    draw_set_colour(COL_BORDER);
    draw_set_alpha(0.25);
    draw_roundrect_ext(_m, _ry + 2, _sw - _m, _ry + _row_h - 2, 4, 4, true);
    draw_set_alpha(1);

    // Riga 1: data (sx) | tipo (centro) | badge (dx)
    var _ly1 = _ry + 18;
    draw_set_valign(fa_middle);

    draw_set_font(fnt_small);
    draw_set_halign(fa_left);
    draw_set_colour(COL_INK);
    draw_text(_m + 10, _ly1, _p.data);

    draw_set_halign(fa_center);
    draw_set_colour(COL_INK_FADED);
    draw_text(_sw / 2, _ly1, _p.tipo);

    draw_badge(_sw - _m - 26, _ly1, _p.risultato);

    // Riga 2: mazzo (sx) | "vs avversari" (dx)
    var _ly2 = _ry + 50;

    draw_set_font(fnt_body);
    draw_set_halign(fa_left);
    draw_set_colour(COL_INK);
    draw_text(_m + 10, _ly2, _p.mio_mazzo);

    if (is_array(_p.avversari) && array_length(_p.avversari) > 0) {
        var _avv_str = "";
        for (var j = 0; j < array_length(_p.avversari); j++) {
            if (j > 0) _avv_str += ", ";
            _avv_str += _p.avversari[j].nome;
        }
        draw_set_font(fnt_small);
        draw_set_halign(fa_right);
        draw_set_colour(COL_INK_FADED);
        draw_text(_sw - _m - 10, _ly2, "vs " + _avv_str);
    }

    // Click → seleziona / deseleziona
    if (gui_mouse_click(_m, _ry, _sw - _m, _ry + _row_h)) {
        _selected_id = (_selected_id == _p.id) ? -1 : _p.id;
    }
}

// Pannello + bottone elimina per la riga selezionata
if (_selected_id != -1) {
    var _bx = _sw / 2 - 80;
    var _by = _list_y2 - BTN_HEIGHT - GAP;
    draw_set_colour(COL_BTN_SECONDARY);
    draw_set_alpha(0.9);
    draw_rectangle(0, _by - GAP, _sw, _by + BTN_HEIGHT + GAP, false);
    draw_set_alpha(1);
    draw_set_colour(COL_LOSS);
    draw_roundrect_ext(_bx, _by, _bx + 160, _by + BTN_HEIGHT, CORNER_RADIUS, CORNER_RADIUS, false);
    draw_set_colour(COL_SURFACE);
    draw_set_font(fnt_body_bold);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_text(_bx + 80, _by + BTN_HEIGHT / 2, "Elimina partita");
    if (gui_mouse_click(_bx, _by, _bx + 160, _by + BTN_HEIGHT)) {
        rimuovi_partita(_selected_id);
        calc_stats();
        _selected_id = -1;
    }
}

draw_navbar(ROOM_HISTORY);

if (mouse_check_button_pressed(mb_left)) {
    var _nx = device_mouse_x_to_gui(0);
    var _ny = device_mouse_y_to_gui(0);
    if (_ny >= _sh - NAVBAR_HEIGHT) {
        var _ntabs = [ROOM_MENU, ROOM_HISTORY, ROOM_STATS, ROOM_SETTINGS];
        var _ntw   = _sw / array_length(_ntabs);
        var _nti   = floor(_nx / _ntw);
        if (_nti >= 0 && _nti < array_length(_ntabs) && _ntabs[_nti] != ROOM_HISTORY) {
            navbar_go(_ntabs[_nti]);
        }
    }
}
