// ============================================================
//  DRAW UTILITIES  –  richiede scr_constants
// ============================================================

/// @desc Disegna un pannello pergamena con ombra e bordo oro.
/// @param {real} x1
/// @param {real} y1
/// @param {real} x2
/// @param {real} y2
function draw_panel(x1, y1, x2, y2) {
    // ombra offset
    draw_set_colour(COL_BG);
    draw_set_alpha(0.45);
    draw_roundrect_ext(x1+3, y1+3, x2+3, y2+3, CORNER_RADIUS, CORNER_RADIUS, false);
    draw_set_alpha(1);
    // fill pergamena
    draw_set_colour(COL_SURFACE);
    draw_roundrect_ext(x1, y1, x2, y2, CORNER_RADIUS, CORNER_RADIUS, false);
    // bordo oro
    draw_set_colour(COL_GOLD);
    draw_roundrect_ext(x1, y1, x2, y2, CORNER_RADIUS, CORNER_RADIUS, true);
}

/// @desc Disegna il badge colorato W / L / D.
/// @param {real} cx  centro x
/// @param {real} cy  centro y
/// @param {string} risultato  "W" | "L" | "D"
function draw_badge(cx, cy, risultato) {
    var _w = 36, _h = 24, _r = 4;
    var _bg = COL_DRAW;
    if (risultato == "W") _bg = COL_WIN;
    else if (risultato == "L") _bg = COL_LOSS;
    var _x1 = cx - _w/2, _y1 = cy - _h/2;
    draw_set_colour(_bg);
    draw_roundrect_ext(_x1, _y1, _x1+_w, _y1+_h, _r, _r, false);
    draw_set_colour(COL_SURFACE);
    draw_set_font(fnt_body_bold);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_text(cx, cy, risultato);
}

/// @desc Disegna il titolo di una schermata (oro su sfondo scuro).
/// @param {real} x
/// @param {real} y
/// @param {string} testo
function draw_screen_title(x, y, testo) {
    draw_set_font(fnt_title);
    draw_set_colour(COL_GOLD);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_text(x, y, testo);
}

/// @desc Disegna un separatore orizzontale color oro sbiadito.
/// @param {real} x1
/// @param {real} x2
/// @param {real} y
function draw_separator(x1, x2, y) {
    draw_set_colour(COL_GOLD_DARK);
    draw_set_alpha(0.4);
    draw_line(x1, y, x2, y);
    draw_set_alpha(1);
}

/// @desc Disegna la barra di navigazione inferiore su layer GUI.
///       Chiama questa funzione dal DrawGUI del controller di ogni room.
/// @param {real} room_id  usa le macro ROOM_MENU, ROOM_HISTORY, ecc.
function draw_navbar(room_id) {
    var _sw = display_get_gui_width();
    var _sh = display_get_gui_height();
    var _y  = _sh - NAVBAR_HEIGHT;

    // sfondo navbar
    draw_set_colour(COL_BTN_SECONDARY);
    draw_rectangle(0, _y, _sw, _sh, false);
    draw_set_colour(COL_GOLD_DARK);
    draw_set_alpha(0.6);
    draw_line(0, _y, _sw, _y);
    draw_set_alpha(1);

    var _tabs  = [["Dashboard", ROOM_MENU], ["Storico", ROOM_HISTORY],
                  ["Stats", ROOM_STATS],    ["Settings", ROOM_SETTINGS]];
    var _n     = array_length(_tabs);
    var _tab_w = _sw / _n;

    for (var i = 0; i < _n; i++) {
        var _label   = _tabs[i][0];
        var _tab_id  = _tabs[i][1];
        var _tx      = i * _tab_w + _tab_w / 2;
        var _ty      = _y + NAVBAR_HEIGHT / 2;
        var _active  = (_tab_id == room_id);

        draw_set_font(fnt_body);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_set_colour(_active ? COL_GOLD : COL_INK_FADED);
        draw_text(_tx, _ty, _label);

        if (_active) {
            draw_set_colour(COL_GOLD);
            draw_rectangle(i * _tab_w + 8, _y + 1, (i+1) * _tab_w - 8, _y + 3, false);
        }
    }
}

/// @desc Naviga alla room corrispondente all'id navbar.
/// @param {real} room_id
function navbar_go(room_id) {
    switch (room_id) {
        case ROOM_MENU:     room_goto(rm_menu);      break;
        case ROOM_HISTORY:  room_goto(rm_history);   break;
        case ROOM_STATS:    room_goto(rm_stats);     break;
        case ROOM_SETTINGS: room_goto(rm_settings);  break;
    }
}

/// @desc Ritorna true se il click GUI è dentro il rettangolo dato.
/// @param {real} x1
/// @param {real} y1
/// @param {real} x2
/// @param {real} y2
function gui_mouse_in(x1, y1, x2, y2) {
    var _mx = device_mouse_x_to_gui(0);
    var _my = device_mouse_y_to_gui(0);
    return point_in_rectangle(_mx, _my, x1, y1, x2, y2);
}

/// @desc Ritorna true se il click GUI è avvenuto dentro il rettangolo.
function gui_mouse_click(x1, y1, x2, y2) {
    return gui_mouse_in(x1, y1, x2, y2) && mouse_check_button_pressed(mb_left);
}
