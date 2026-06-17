// obj_controller_log  –  Draw GUI

var _sw = display_get_gui_width();
var _sh = display_get_gui_height();
var _m  = MARGIN;

draw_set_colour(COL_BG);
draw_rectangle(0, 0, _sw, _sh, false);

draw_screen_title(_m, _m, "NUOVA PARTITA");
draw_separator(_m, _sw - _m, _m + 38);

// Progress steps
var _step_labels = ["Data & Tipo", "Mio Mazzo", "Avversari"];
var _sw3 = (_sw - _m * 2) / 3;
for (var i = 0; i < 3; i++) {
    var _sx  = _m + i * _sw3 + _sw3 / 2;
    var _done = (i < _step);
    var _curr = (i == _step);
    var _col  = _done ? COL_WIN : (_curr ? COL_GOLD : COL_INK_FADED);
    draw_set_colour(_col);
    draw_circle(_sx, _m + 60, 10, !_done && !_curr);
    if (_done) {
        draw_set_font(fnt_body_bold);
        draw_set_colour(COL_SURFACE);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_text(_sx, _m + 60, "✓");
    } else {
        draw_set_font(fnt_body_bold);
        draw_set_colour(_curr ? COL_BG : COL_INK_FADED);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_text(_sx, _m + 60, string(i + 1));
    }
    draw_set_font(fnt_small);
    draw_set_colour(_col);
    draw_text(_sx, _m + 76, _step_labels[i]);
    if (i < 2) {
        draw_set_colour(COL_BORDER);
        draw_line(_sx + 14, _m + 60, _sx + _sw3 - 14, _m + 60);
    }
}

// ===  STEP 0  –  Data, Tipo, Risultato  ===
if (_step == 0) {
    draw_panel(_m, _m + 96, _sw - _m, _m + 96 + 220);

    // Data
    draw_set_font(fnt_body_bold);
    draw_set_colour(COL_INK_FADED);
    draw_set_halign(fa_left);
    draw_text(_m + 12, _m + 110, "DATA");
    draw_set_font(fnt_body);
    draw_set_colour(COL_INK);
    draw_text(_m + 12, _m + 128, _data);
    // Pulsanti +/- giorno
    var _bw2 = 32; var _bh2 = 20; var _bby2 = _m + 124;
    var _bx_p = _sw - _m - GAP - _bw2;
    var _bx_m = _bx_p - _bw2 - 8;
    draw_set_colour(COL_BTN_SECONDARY);
    draw_roundrect_ext(_bx_m, _bby2, _bx_m + _bw2, _bby2 + _bh2, 4, 4, false);
    draw_roundrect_ext(_bx_p, _bby2, _bx_p + _bw2, _bby2 + _bh2, 4, 4, false);
    draw_set_colour(COL_GOLD); draw_set_halign(fa_center); draw_set_valign(fa_middle);
    draw_text(_bx_m + _bw2 / 2, _bby2 + _bh2 / 2, "-");
    draw_text(_bx_p + _bw2 / 2, _bby2 + _bh2 / 2, "+");
    if (gui_mouse_click(_bx_m, _bby2, _bx_m + _bw2, _bby2 + _bh2)) _change_date(-1);
    if (gui_mouse_click(_bx_p, _bby2, _bx_p + _bw2, _bby2 + _bh2)) _change_date(1);

    // Tipo partita
    draw_separator(_m + 4, _sw - _m - 4, _m + 158);
    draw_set_font(fnt_body_bold);
    draw_set_colour(COL_INK_FADED);
    draw_set_halign(fa_left);
    draw_text(_m + 12, _m + 164, "TIPO PARTITA");
    var _mods  = global.lookup.modalita;
    var _pad   = GAP;
    var _bw    = (_sw - _m * 2 - _pad * 2 - GAP * (array_length(_mods) - 1)) / array_length(_mods);
    for (var i = 0; i < array_length(_mods); i++) {
        var _bx = _m + _pad + i * (_bw + GAP);
        var _by = _m + 182;
        var _sel = (i == _tipo_idx);
        draw_set_colour(_sel ? COL_BTN_PRIMARY : COL_BTN_SECONDARY);
        draw_roundrect_ext(_bx, _by, _bx + _bw, _by + BTN_HEIGHT, CORNER_RADIUS, CORNER_RADIUS, false);
        draw_set_colour(_sel ? COL_GOLD : COL_BORDER);
        draw_roundrect_ext(_bx, _by, _bx + _bw, _by + BTN_HEIGHT, CORNER_RADIUS, CORNER_RADIUS, true);
        draw_set_font(_sel ? fnt_body_bold : fnt_body);
        draw_set_colour(_sel ? COL_SURFACE : COL_INK_FADED);
        draw_set_halign(fa_center); draw_set_valign(fa_middle);
        draw_text(_bx + _bw / 2, _by + BTN_HEIGHT / 2, _mods[i].nome);
        if (gui_mouse_click(_bx, _by, _bx + _bw, _by + BTN_HEIGHT)) _tipo_idx = i;
    }

    // Risultato
    draw_separator(_m + 4, _sw - _m - 4, _m + 238);
    draw_set_font(fnt_body_bold);
    draw_set_colour(COL_INK_FADED);
    draw_set_halign(fa_left);
    draw_text(_m + 12, _m + 246, "RISULTATO");
    var _ris_labels = ["W  Vittoria", "L  Sconfitta", "D  Pareggio"];
    var _ris_cols   = [COL_WIN, COL_LOSS, COL_DRAW];
    var _rpad       = GAP;
    var _rbw        = (_sw - _m * 2 - _rpad * 2 - GAP * 2) / 3;
    for (var i = 0; i < 3; i++) {
        var _bx = _m + _rpad + i * (_rbw + GAP);
        var _by = _m + 264;
        var _sel = (i == _ris_idx);
        draw_set_colour(_sel ? _ris_cols[i] : COL_BTN_SECONDARY);
        draw_roundrect_ext(_bx, _by, _bx + _rbw, _by + BTN_HEIGHT, CORNER_RADIUS, CORNER_RADIUS, false);
        draw_set_colour(_sel ? make_colour_rgb(255,255,255) : COL_BORDER);
        draw_roundrect_ext(_bx, _by, _bx + _rbw, _by + BTN_HEIGHT, CORNER_RADIUS, CORNER_RADIUS, true);
        draw_set_font(_sel ? fnt_body_bold : fnt_body);
        draw_set_colour(_sel ? COL_SURFACE : COL_INK_FADED);
        draw_set_halign(fa_center); draw_set_valign(fa_middle);
        draw_text(_bx + _rbw / 2, _by + BTN_HEIGHT / 2, _ris_labels[i]);
        if (gui_mouse_click(_bx, _by, _bx + _rbw, _by + BTN_HEIGHT)) _ris_idx = i;
    }
}

// ===  STEP 1  –  Mio Mazzo  ===
if (_step == 1) {
    draw_panel(_m, _m + 96, _sw - _m, _m + 182);
    draw_set_font(fnt_body_bold);
    draw_set_colour(COL_INK_FADED);
    draw_set_halign(fa_left);
    draw_text(_m + 12, _m + 110, "IL MIO MAZZO");
    dd_mazzo.x = _m + GAP;
    dd_mazzo.y = _m + 132;
}

// ===  STEP 2  –  Avversari  ===
if (_step == 2) {
    var _n_adv = global.lookup.modalita[_tipo_idx].n_avversari;
    draw_panel(_m, _m + 96, _sw - _m, _m + 96 + _n_adv * 84 + 22);
    for (var i = 0; i < _n_adv; i++) {
        var _ly = _m + 130 + i * 84;
        draw_set_font(fnt_body_bold);
        draw_set_colour(COL_INK_FADED);
        draw_set_halign(fa_left);
        draw_text(_m + 12, _ly - 18, "AVVERSARIO " + string(i + 1));
    }
}

// ============================================================
function _change_date(delta) {
    // Parsing veloce gg/mm/aaaa
    var _d  = real(string_copy(_data, 1, 2));
    var _mo = real(string_copy(_data, 4, 2));
    var _y  = real(string_copy(_data, 7, 4));
    var _days_in_month = [0,31,28,31,30,31,30,31,31,30,31,30,31];
    if ((_y mod 4 == 0 && _y mod 100 != 0) || _y mod 400 == 0) _days_in_month[2] = 29;
    _d += delta;
    if (_d < 1)  { _mo--; if (_mo < 1) { _mo = 12; _y--; } _d = _days_in_month[_mo]; }
    if (_d > _days_in_month[_mo]) { _d = 1; _mo++; if (_mo > 12) { _mo = 1; _y++; } }
    _data = string_format(_d, 2, 0) + "/" + string_format(_mo, 2, 0) + "/" + string(_y);
    _data = string_replace_all(_data, " ", "0");
}
