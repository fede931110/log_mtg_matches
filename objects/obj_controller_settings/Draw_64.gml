// obj_controller_settings  –  Draw GUI
// Layout: meta' schermo lista (scrollabile) / meta' schermo pannello aggiunta

var _sw = display_get_gui_width();
var _sh = display_get_gui_height();
var _m  = MARGIN;

// Sfondo
draw_set_colour(COL_BG);
draw_rectangle(0, 0, _sw, _sh, false);

// Titolo
draw_screen_title(_m, _m, "SETTINGS");
draw_separator(_m, _sw - _m, _m + 46);

// ===  TAB BAR  ===
var _tabs_label = ["Modalita'", "Miei Mazzi", "Avversari"];
var _tw  = (_sw - _m * 2) / 3;
var _ty1 = _m + 50;
var _ty2 = _ty1 + TAB_HEIGHT;
var _modal = (_pending_delete != undefined);

for (var i = 0; i < 3; i++) {
    var _tx1    = _m + i * _tw;
    var _tx2    = _tx1 + _tw;
    var _active = (i == _tab);

    draw_set_colour(_active ? COL_SURFACE : COL_SURFACE_ALT);
    draw_roundrect_ext(_tx1, _ty1, _tx2, _ty2, CORNER_RADIUS, CORNER_RADIUS, false);
    draw_set_colour(_active ? COL_GOLD : COL_BORDER);
    draw_roundrect_ext(_tx1, _ty1, _tx2, _ty2, CORNER_RADIUS, CORNER_RADIUS, true);
    draw_set_font(_active ? fnt_body_bold : fnt_body);
    draw_set_colour(_active ? COL_INK : COL_INK_FADED);
    draw_set_halign(fa_center); draw_set_valign(fa_middle);
    draw_text(_tx1 + _tw / 2, _ty1 + TAB_HEIGHT / 2, _tabs_label[i]);
    if (_active) {
        draw_set_colour(COL_GOLD);
        draw_rectangle(_tx1 + 4, _ty2 - 3, _tx2 - 4, _ty2, false);
    }
    if (!_modal && gui_mouse_click(_tx1, _ty1, _tx2, _ty2) && !_active) {
        _tab               = i;
        _adv_open          = -1;
        _scroll            = 0;
        inp_nome._text     = "";
        keyboard_string    = "";
        dd_adv_sel.selected = 0;
        dd_adv_sel._open   = false;
        if (i == 2 && array_length(global.lookup.avversari) > 0) {
            _adv_open           = 0;
            dd_adv_sel.selected = 1;
        }
    }
}

// ===  LAYOUT 50 / 50  ===
var _cy1  = _ty2 + GAP;
var _cy2  = _sh - NAVBAR_HEIGHT - GAP;
var _half = floor((_cy2 - _cy1 - GAP) / 2);

var _list_y1 = _cy1;
var _list_y2 = _list_y1 + _half;
var _add_y1  = _list_y2 + GAP;
var _add_y2  = _cy2;

// ===  PANNELLO LISTA (meta' superiore, scrollabile)  ===
draw_panel(_m, _list_y1, _sw - _m, _list_y2);

var _row_h      = 40;
var _items      = _get_current_items();
var _visible    = floor(_half / _row_h);
var _max_scroll = max(0, array_length(_items) - _visible);
_scroll = clamp(_scroll, 0, _max_scroll);

if (!_modal && mouse_wheel_down() && gui_mouse_in(_m, _list_y1, _sw - _m, _list_y2)) _scroll++;
if (!_modal && mouse_wheel_up()   && gui_mouse_in(_m, _list_y1, _sw - _m, _list_y2)) _scroll = max(_scroll - 1, 0);

for (var i = _scroll; i < min(array_length(_items), _scroll + _visible); i++) {
    var _item = _items[i];
    var _ry   = _list_y1 + (i - _scroll) * _row_h;

    if (i mod 2 == 0) {
        draw_set_colour(COL_SURFACE_ALT);
        draw_set_alpha(0.4);
        draw_rectangle(_m + 1, _ry, _sw - _m - 1, _ry + _row_h - 1, false);
        draw_set_alpha(1);
    }

    draw_set_font(fnt_body);
    draw_set_colour(COL_INK);
    draw_set_halign(fa_left); draw_set_valign(fa_middle);
    draw_text(_m + 12, _ry + _row_h / 2, _item.label);

    if (struct_exists(_item, "sub")) {
        draw_set_colour(COL_INK_FADED);
        draw_set_halign(fa_right);
        draw_text(_sw - _m - 80, _ry + _row_h / 2, _item.sub);
    }

    // Bottone elimina
    var _bx = _sw - _m - 70;
    var _bw = 64; var _bh = 28;
    var _by = _ry + (_row_h - _bh) / 2;
    draw_set_colour(gui_mouse_in(_bx, _by, _bx+_bw, _by+_bh)
                    ? make_colour_rgb(180,30,30) : COL_LOSS);
    draw_roundrect_ext(_bx, _by, _bx+_bw, _by+_bh, 4, 4, false);
    draw_set_colour(COL_SURFACE);
    draw_set_font(fnt_small);
    draw_set_halign(fa_center); draw_set_valign(fa_middle);
    draw_text(_bx + _bw/2, _by + _bh/2, "Elimina");
    if (!_modal && gui_mouse_click(_bx, _by, _bx+_bw, _by+_bh)) _pending_delete = _item;

    // Click riga avversario → espandi mazzi e sincronizza dropdown
    if (!_modal && _tab == 2 && struct_exists(_item, "adv_idx")) {
        if (gui_mouse_click(_m + 14, _ry, _bx, _ry + _row_h)) {
            _adv_open = (_adv_open == _item.adv_idx) ? -1 : _item.adv_idx;
            dd_adv_sel.selected = clamp(_adv_open + 1, 0, array_length(global.lookup.avversari));
            _scroll = 0;
        }
    }
}

// Messaggio lista vuota
if (array_length(_items) == 0) {
    draw_set_font(fnt_small);
    draw_set_colour(COL_INK_FADED);
    draw_set_halign(fa_center); draw_set_valign(fa_middle);
    draw_text(_sw / 2, (_list_y1 + _list_y2) / 2, "Nessun elemento");
}

// ===  PANNELLO AGGIUNTA (meta' inferiore)  ===
draw_panel(_m, _add_y1, _sw - _m, _add_y2);

var _add_labels = ["AGGIUNGI MODALITA'", "AGGIUNGI MAZZO", "AGGIUNGI AVVERSARIO / MAZZO"];
draw_set_font(fnt_small);
draw_set_colour(COL_INK_FADED);
draw_set_halign(fa_left); draw_set_valign(fa_top);
draw_text(_m + 12, _add_y1 + 14, _add_labels[_tab]);
draw_separator(_m + 4, _sw - _m - 4, _add_y1 + 36);

var _ix   = _m + 12;
var _iw   = _sw - (_m + 12) * 2;
var _btnw = 100;
var _inpw = _iw - GAP - _btnw;
var _row1 = _add_y1 + 48;

if (_tab == 2) {
    var _advs     = global.lookup.avversari;
    var _adv_opts = ["+ Nuovo avversario"];
    for (var i = 0; i < array_length(_advs); i++) {
        array_push(_adv_opts, _advs[i].nome);
    }
    dd_adv_sel.options = _adv_opts;
    dd_adv_sel.x       = _ix;
    dd_adv_sel.y       = _row1;
    dd_adv_sel.w       = _iw;
    dd_adv_sel.enabled = true;
    if (!dd_adv_sel._open) {
        dd_adv_sel.selected = clamp(_adv_open + 1, 0, array_length(_adv_opts) - 1);
    }
    inp_nome.x = _ix;
    inp_nome.y = _row1 + INPUT_HEIGHT + GAP;
    btn_add.x  = _ix + _inpw + GAP;
    btn_add.y  = inp_nome.y;
} else {
    dd_adv_sel.x     = -9999;
    dd_adv_sel._open = false;
    inp_nome.x = _ix;
    inp_nome.y = _row1;
    btn_add.x  = _ix + _inpw + GAP;
    btn_add.y  = _row1;
}

inp_nome.w = _inpw;

inp_nome.visible   = !_modal;
btn_add.visible    = !_modal;
dd_adv_sel.visible = !_modal;
if (_modal) dd_adv_sel._open = false;

inp_nome.placeholder = (_tab == 0) ? "Nome modalita'" :
                       (_tab == 1  ? "Nome mazzo"    :
                       (_adv_open >= 0 ? "Mazzo avversario" : "Nome avversario"));

draw_navbar(ROOM_SETTINGS);

// Click navbar
if (!_modal && mouse_check_button_pressed(mb_left)) {
    var _nx  = device_mouse_x_to_gui(0);
    var _ny2 = device_mouse_y_to_gui(0);
    if (_ny2 >= _sh - NAVBAR_HEIGHT) {
        var _ntabs = [ROOM_MENU, ROOM_HISTORY, ROOM_STATS, ROOM_SETTINGS];
        var _ntw   = _sw / array_length(_ntabs);
        var _nti   = floor(_nx / _ntw);
        if (_nti >= 0 && _nti < array_length(_ntabs) && _ntabs[_nti] != ROOM_SETTINGS) {
            navbar_go(_ntabs[_nti]);
        }
    }
}

// ===  MODAL CONFERMA ELIMINAZIONE  ===
if (_modal) {
    draw_set_colour(COL_BG);
    draw_set_alpha(0.80);
    draw_rectangle(0, 0, _sw, _sh, false);
    draw_set_alpha(1);

    var _mw = _sw - MARGIN * 4;
    var _mh = 160;
    var _mx = (_sw - _mw) / 2;
    var _my = (_sh - _mh) / 2;
    draw_panel(_mx, _my, _mx + _mw, _my + _mh);

    draw_set_font(fnt_body_bold);
    draw_set_colour(COL_INK);
    draw_set_halign(fa_center); draw_set_valign(fa_middle);
    draw_text(_sw / 2, _my + 36, "Confermare eliminazione?");

    draw_set_font(fnt_small);
    draw_set_colour(COL_INK_FADED);
    draw_text(_sw / 2, _my + 64, _pending_delete.key);

    var _mbw = (_mw - GAP * 3) / 2;
    var _mbh = BTN_HEIGHT;
    var _mby = _my + _mh - _mbh - GAP;
    var _mbx1 = _mx + GAP;
    var _mbx2 = _mx + GAP + _mbw + GAP;

    draw_set_colour(COL_BTN_SECONDARY);
    draw_roundrect_ext(_mbx1, _mby, _mbx1 + _mbw, _mby + _mbh, CORNER_RADIUS, CORNER_RADIUS, false);
    draw_set_font(fnt_body);
    draw_set_colour(COL_SURFACE);
    draw_set_halign(fa_center); draw_set_valign(fa_middle);
    draw_text(_mbx1 + _mbw / 2, _mby + _mbh / 2, "Annulla");
    if (gui_mouse_click(_mbx1, _mby, _mbx1 + _mbw, _mby + _mbh)) _pending_delete = undefined;

    draw_set_colour(COL_LOSS);
    draw_roundrect_ext(_mbx2, _mby, _mbx2 + _mbw, _mby + _mbh, CORNER_RADIUS, CORNER_RADIUS, false);
    draw_set_font(fnt_body_bold);
    draw_set_colour(COL_SURFACE);
    draw_text(_mbx2 + _mbw / 2, _mby + _mbh / 2, "Conferma");
    if (gui_mouse_click(_mbx2, _mby, _mbx2 + _mbw, _mby + _mbh)) {
        _on_delete(_pending_delete);
        _pending_delete = undefined;
    }
}

// ============================================================
function _get_current_items() {
    var _out = [];
    switch (_tab) {
        case 0:
            var _mods = global.lookup.modalita;
            for (var i = 0; i < array_length(_mods); i++) {
                array_push(_out, {
                    label: _mods[i].nome,
                    sub:   string(_mods[i].n_avversari) + " avv.",
                    key:   _mods[i].nome,
                    type:  "modalita"
                });
            }
            break;
        case 1:
            var _mazzi = global.lookup.miei_mazzi;
            for (var i = 0; i < array_length(_mazzi); i++) {
                array_push(_out, { label: _mazzi[i], key: _mazzi[i], type: "mio_mazzo" });
            }
            break;
        case 2:
            var _advs = global.lookup.avversari;
            for (var i = 0; i < array_length(_advs); i++) {
                var _exp = (_adv_open == i);
                array_push(_out, {
                    label:   (_exp ? "v  " : ">  ") + _advs[i].nome,
                    key:     _advs[i].nome,
                    type:    "avversario",
                    adv_idx: i
                });
                if (_exp) {
                    var _ms = _advs[i].mazzi;
                    for (var j = 0; j < array_length(_ms); j++) {
                        array_push(_out, {
                            label:    "      " + _ms[j],
                            key:      _ms[j],
                            type:     "mazzo_avversario",
                            adv_nome: _advs[i].nome
                        });
                    }
                }
            }
            break;
    }
    return _out;
}

function _on_delete(item) {
    switch (item.type) {
        case "modalita":         lookup_remove_modalita(item.key);                           break;
        case "mio_mazzo":        lookup_remove_mio_mazzo(item.key);                          break;
        case "avversario":       lookup_remove_avversario(item.key); _adv_open = -1;         break;
        case "mazzo_avversario": lookup_remove_mazzo_avversario(item.adv_nome, item.key);    break;
    }
}
