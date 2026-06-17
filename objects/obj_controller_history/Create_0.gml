// obj_controller_history  –  Create

_sw      = display_get_gui_width();
_sh      = display_get_gui_height();
_scroll  = 0;

// Filtri attivi (stringa vuota = nessun filtro)
_f_tipo      = "";
_f_risultato = "";
_f_mazzo     = "";
_f_avversario = "";

// Dropdown filtri
var _ddw = (_sw - MARGIN * 2 - GAP * 3) / 4;
var _ddy = MARGIN + 54;  // 8px below separator at MARGIN+46

dd_tipo = instance_create_layer(MARGIN, _ddy, "GUI", obj_dropdown);
dd_tipo.w           = _ddw;
dd_tipo.placeholder = "Tipo";
dd_tipo.options     = _build_tipo_options();
dd_tipo.on_change   = method(self, function(i, v) {
    _f_tipo  = (i == 0) ? "" : v;
    _scroll  = 0;
});

dd_ris = instance_create_layer(MARGIN + (_ddw + GAP), _ddy, "GUI", obj_dropdown);
dd_ris.w            = _ddw;
dd_ris.placeholder  = "Risultato";
dd_ris.options      = ["Tutti", "W", "L", "D"];
dd_ris.on_change    = method(self, function(i, v) {
    _f_risultato = (i == 0) ? "" : v;
    _scroll      = 0;
});

dd_mazzo = instance_create_layer(MARGIN + (_ddw + GAP) * 2, _ddy, "GUI", obj_dropdown);
dd_mazzo.w           = _ddw;
dd_mazzo.placeholder = "Mazzo";
dd_mazzo.options     = _build_mazzo_options();
dd_mazzo.on_change   = method(self, function(i, v) {
    _f_mazzo = (i == 0) ? "" : v;
    _scroll  = 0;
});

dd_avv = instance_create_layer(MARGIN + (_ddw + GAP) * 3, _ddy, "GUI", obj_dropdown);
dd_avv.w            = _ddw;
dd_avv.placeholder  = "Avversario";
dd_avv.options      = _build_avv_options();
dd_avv.on_change    = method(self, function(i, v) {
    _f_avversario = (i == 0) ? "" : v;
    _scroll       = 0;
});

// ID partita selezionata per eventuale eliminazione
_selected_id = -1;

// Limite risultati mostrati (-1 = tutti)
_limit = -1;

// Stato drag-scroll (touch)
_drag_start_y     = -1;
_drag_scroll_base = 0;
_is_dragging      = false;

// ============================================================
function _build_tipo_options() {
    var _out = ["Tutti"];
    for (var i = 0; i < array_length(global.lookup.modalita); i++) {
        array_push(_out, global.lookup.modalita[i].nome);
    }
    return _out;
}
function _build_mazzo_options() {
    var _out = ["Tutti"];
    for (var i = 0; i < array_length(global.lookup.miei_mazzi); i++) {
        array_push(_out, global.lookup.miei_mazzi[i]);
    }
    return _out;
}
function _build_avv_options() {
    var _out = ["Tutti"];
    for (var i = 0; i < array_length(global.lookup.avversari); i++) {
        array_push(_out, global.lookup.avversari[i].nome);
    }
    return _out;
}
