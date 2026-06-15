// obj_controller_log  –  Create

_sw      = display_get_gui_width();
_sh      = display_get_gui_height();
_step    = 0;
// step 0 = data/tipo/risultato  |  step 1 = mio mazzo  |  step 2 = avversari

// --- Valori raccolti ---
_data       = string_format(current_day, 2, 0) + "/" + string_format(current_month, 2, 0) + "/" + string(current_year);
_data       = string_replace_all(_data, " ", "0");
_tipo_idx   = 0;   // indice in global.lookup.modalita
_ris_idx    = 0;   // 0=W 1=L 2=D
_mazzo_idx  = 0;
_avversari  = [];  // array di struct { nome_idx, mazzo_idx }

_risultati  = ["W", "L", "D"];

// --- Widget dropdown mazzo ---
dd_mazzo = instance_create_layer(MARGIN, 0, "GUI", obj_dropdown);
dd_mazzo.options  = global.lookup.miei_mazzi;
dd_mazzo.w        = _sw - MARGIN * 2;
dd_mazzo.on_change = method(self, function(i, v) { _mazzo_idx = i; });
dd_mazzo.visible  = false;

// --- Bottone Avanti / Salva ---
btn_avanti = instance_create_layer(_sw / 2 - 80, _sh - NAVBAR_HEIGHT - BTN_HEIGHT - MARGIN, "GUI", obj_button);
btn_avanti.label    = "Avanti →";
btn_avanti.w        = 160;
btn_avanti.style    = "primary";
btn_avanti.on_click = method(self, function() { _next_step(); });

// --- Bottone Indietro ---
btn_indietro = instance_create_layer(MARGIN, btn_avanti.y, "GUI", obj_button);
btn_indietro.label    = "← Indietro";
btn_indietro.w        = 120;
btn_indietro.style    = "secondary";
btn_indietro.on_click = method(self, function() { _prev_step(); });

_rebuild_avv_dropdowns();

// ============================================================
function _next_step() {
    if (_step == 0) {
        _step = 1;
        dd_mazzo.visible = true;
    } else if (_step == 1) {
        _step = 2;
        dd_mazzo.visible = false;
        _rebuild_avv_dropdowns();
        btn_avanti.label = "Salva Partita";
    } else if (_step == 2) {
        _salva();
    }
    btn_indietro.enabled = (_step > 0);
}

function _prev_step() {
    if (_step > 0) {
        _step--;
        dd_mazzo.visible  = (_step == 1);
        btn_avanti.label  = (_step < 2) ? "Avanti →" : "Salva Partita";
        btn_indietro.enabled = (_step > 0);
    }
}

function _rebuild_avv_dropdowns() {
    // Distruggi i dropdown avversario precedenti
    if (variable_instance_exists(self, "_adv_widgets")) {
        for (var i = 0; i < array_length(_adv_widgets); i++) {
            if (instance_exists(_adv_widgets[i].dd_nome))  instance_destroy(_adv_widgets[i].dd_nome);
            if (instance_exists(_adv_widgets[i].dd_mazzo)) instance_destroy(_adv_widgets[i].dd_mazzo);
        }
    }
    _adv_widgets = [];

    if (_step != 2) return;

    var _n_adv = global.lookup.modalita[_tipo_idx].n_avversari;
    // Riempi _avversari con default se più corto
    while (array_length(_avversari) < _n_adv) {
        array_push(_avversari, { nome_idx: 0, mazzo_idx: 0 });
    }

    var _avv_names = [];
    for (var i = 0; i < array_length(global.lookup.avversari); i++) {
        array_push(_avv_names, global.lookup.avversari[i].nome);
    }

    for (var i = 0; i < _n_adv; i++) {
        var _row_y  = 150 + i * 90;
        var _ddw    = (_sw - MARGIN * 2 - GAP) / 2;

        var _dd_n   = instance_create_layer(MARGIN, _row_y, "GUI", obj_dropdown);
        _dd_n.options    = _avv_names;
        _dd_n.w          = _ddw;
        _dd_n.placeholder = "Avversario " + string(i + 1);
        var _ii = i;
        _dd_n.on_change  = method(self, function(idx, val) {
            _avversari[_ii].nome_idx  = idx;
            _avversari[_ii].mazzo_idx = 0;
            _update_mazzo_dd(_ii);
        });

        var _dd_m   = instance_create_layer(MARGIN + _ddw + GAP, _row_y, "GUI", obj_dropdown);
        _dd_m.w          = _ddw;
        _dd_m.placeholder = "Mazzo";
        _dd_m.on_change  = method(self, function(idx, val) {
            _avversari[_ii].mazzo_idx = idx;
        });

        _update_mazzo_dd(i);
        array_push(_adv_widgets, { dd_nome: _dd_n, dd_mazzo: _dd_m });
    }
}

function _update_mazzo_dd(i) {
    if (i >= array_length(_adv_widgets)) return;
    var _nome     = global.lookup.avversari[_avversari[i].nome_idx].nome;
    var _mazzi    = lookup_get_mazzi_avversario(_nome);
    _adv_widgets[i].dd_mazzo.options  = _mazzi;
    _adv_widgets[i].dd_mazzo.selected = 0;
}

function _salva() {
    var _modalita = global.lookup.modalita[_tipo_idx].nome;
    var _n_adv    = global.lookup.modalita[_tipo_idx].n_avversari;
    var _avv_out  = [];

    for (var i = 0; i < _n_adv; i++) {
        var _a_nome  = global.lookup.avversari[_avversari[i].nome_idx].nome;
        var _mazzi   = lookup_get_mazzi_avversario(_a_nome);
        var _a_mazzo = (array_length(_mazzi) > 0) ? _mazzi[_avversari[i].mazzo_idx] : "";
        array_push(_avv_out, { nome: _a_nome, mazzo: _a_mazzo });
    }

    var _partita = {
        data:       _data,
        tipo:       _modalita,
        risultato:  _risultati[_ris_idx],
        mio_mazzo:  global.lookup.miei_mazzi[_mazzo_idx],
        avversari:  _avv_out
    };
    aggiungi_partita(_partita);
    calc_stats();
    room_goto(rm_menu);
}
