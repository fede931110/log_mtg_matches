// obj_controller_settings  –  Draw GUI

var _sw  = display_get_gui_width();
var _sh  = display_get_gui_height();
var _m   = MARGIN;
var _con_h = _sh - (_m + 50 + TAB_HEIGHT) - NAVBAR_HEIGHT - INPUT_HEIGHT - GAP * 3;

// Sfondo
draw_set_colour(COL_BG);
draw_rectangle(0, 0, _sw, _sh, false);

// Titolo
draw_screen_title(_m, _m, "SETTINGS");
draw_separator(_m, _sw - _m, _m + 38);

// ===  TAB BAR  ===
var _tabs_label = ["Modalità", "Miei Mazzi", "Avversari"];
var _tw  = (_sw - _m * 2) / 3;
var _ty1 = _m + 50;
var _ty2 = _ty1 + TAB_HEIGHT;

for (var i = 0; i < 3; i++) {
    var _tx1 = _m + i * _tw;
    var _tx2 = _tx1 + _tw;
    var _active = (i == _tab);

    draw_set_colour(_active ? COL_SURFACE : COL_SURFACE_ALT);
    draw_roundrect_ext(_tx1, _ty1, _tx2, _ty2, CORNER_RADIUS, CORNER_RADIUS, false);
    draw_set_colour(_active ? COL_GOLD : COL_BORDER);
    draw_roundrect_ext(_tx1, _ty1, _tx2, _ty2, CORNER_RADIUS, CORNER_RADIUS, true);

    draw_set_font(_active ? fnt_body_bold : fnt_body);
    draw_set_colour(_active ? COL_INK : COL_INK_FADED);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_text(_tx1 + _tw / 2, _ty1 + TAB_HEIGHT / 2, _tabs_label[i]);

    if (_active) {
        draw_set_colour(COL_GOLD);
        draw_rectangle(_tx1 + 4, _ty2 - 3, _tx2 - 4, _ty2, false);
    }

    if (gui_mouse_click(_tx1, _ty1, _tx2, _ty2) && !_active) {
        _tab      = i;
        _adv_open = -1;
        _scroll   = 0;
        inp_nome._text  = "";
        inp_nadv._text  = "";
        _update_input_visibility();
    }
}

// ===  CONTENUTO PANNELLO  ===
var _py1 = _ty2 + GAP;
var _py2 = _py1 + _con_h;
draw_panel(_m, _py1, _sw - _m, _py2);

var _row_h = 40;
var _px    = _m + 12;

// Clip scroll
var _items = _get_current_items();
var _max_scroll = max(0, array_length(_items) - floor(_con_h / _row_h));
_scroll = clamp(_scroll, 0, _max_scroll);

if (mouse_wheel_down() && gui_mouse_in(_m, _py1, _sw - _m, _py2)) _scroll++;
if (mouse_wheel_up()   && gui_mouse_in(_m, _py1, _sw - _m, _py2)) _scroll = max(_scroll - 1, 0);

var _visible = floor(_con_h / _row_h);
for (var i = _scroll; i < min(array_length(_items), _scroll + _visible); i++) {
    var _item  = _items[i];
    var _ry    = _py1 + (i - _scroll) * _row_h;

    if (i mod 2 == 0) {
        draw_set_colour(COL_SURFACE_ALT);
        draw_set_alpha(0.4);
        draw_rectangle(_m + 1, _ry, _sw - _m - 1, _ry + _row_h - 1, false);
        draw_set_alpha(1);
    }

    draw_set_font(fnt_body);
    draw_set_colour(COL_INK);
    draw_set_halign(fa_left);
    draw_set_valign(fa_middle);
    draw_text(_px, _ry + _row_h / 2, _item.label);

    // Info destra (sub-label)
    if (struct_exists(_item, "sub")) {
        draw_set_colour(COL_INK_FADED);
        draw_set_halign(fa_right);
        draw_text(_sw - _m - 80, _ry + _row_h / 2, _item.sub);
    }

    // Bottone elimina
    var _bx = _sw - _m - 70;
    var _bw = 64, _bh = 28;
    var _by = _ry + (_row_h - _bh) / 2;
    var _hover_del = gui_mouse_in(_bx, _by, _bx + _bw, _by + _bh);
    draw_set_colour(_hover_del ? make_colour_rgb(180, 30, 30) : COL_LOSS);
    draw_roundrect_ext(_bx, _by, _bx + _bw, _by + _bh, 4, 4, false);
    draw_set_colour(COL_SURFACE);
    draw_set_font(fnt_small);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_text(_bx + _bw / 2, _by + _bh / 2, "Elimina");

    if (gui_mouse_click(_bx, _by, _bx + _bw, _by + _bh)) {
        _on_delete(_item);
    }

    // Toggle espandi avversario (solo tab 2, livello radice)
    if (_tab == 2 && struct_exists(_item, "adv_idx")) {
        var _toggle_x = _m + 14;
        if (gui_mouse_click(_toggle_x, _ry, _bx, _ry + _row_h)) {
            _adv_open = (_adv_open == _item.adv_idx) ? -1 : _item.adv_idx;
            _scroll   = 0;
        }
    }
}

// ===  AREA INPUT IN BASSO  ===
var _input_y = _py2 + GAP;
inp_nome.y       = _input_y;
inp_nadv.y       = _input_y;
btn_add.y        = _input_y;
inp_nome.x       = _m;
inp_nadv.x       = _m + inp_nome.w + GAP;
btn_add.x        = _sw - _m - btn_add.w;

// Etichette campo
draw_set_font(fnt_small);
draw_set_colour(COL_INK_FADED);
draw_set_halign(fa_left);
var _hint = (_tab == 0) ? "Nome modalità" : (_tab == 1 ? "Nome mazzo" :
             (_adv_open >= 0 ? "Mazzo da aggiungere" : "Nome avversario"));
draw_text(_m, _input_y - 16, _hint);
if (_tab == 0) draw_text(inp_nadv.x, _input_y - 16, "Slot avv.");

draw_navbar(ROOM_SETTINGS);

// Click navbar
if (mouse_check_button_pressed(mb_left)) {
    var _nx = device_mouse_x_to_gui(0);
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
                array_push(_out, {
                    label:   "▶  " + _advs[i].nome,
                    key:     _advs[i].nome,
                    type:    "avversario",
                    adv_idx: i
                });
                if (_adv_open == i) {
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
        case "modalita":          lookup_remove_modalita(item.key);                              break;
        case "mio_mazzo":         lookup_remove_mio_mazzo(item.key);                             break;
        case "avversario":        lookup_remove_avversario(item.key); _adv_open = -1;            break;
        case "mazzo_avversario":  lookup_remove_mazzo_avversario(item.adv_nome, item.key);       break;
    }
}
