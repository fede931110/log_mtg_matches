// obj_data_manager  –  Create
// Proprietà: Persistent = true
// Posizionato in rm_menu (prima room). Sopravvive a tutti i cambi di room.

// Adatta la GUI all'aspect ratio reale del dispositivo (larghezza virtuale fissa 480)
// Elimina le bande nere su telefoni con proporzioni diverse da 9:16
var _dw = display_get_width();
var _dh = display_get_height();
if (_dw > 0 && _dh > 0) {
    surface_resize(application_surface, _dw, _dh);
    display_set_gui_size(480, round(480.0 * _dh / _dw));
} else {
    display_set_gui_size(480, 854);
}

global.dd_click_handled = false;

global.partite = [];
global.lookup = {
    miei_mazzi: [],
    avversari:  [],
    modalita:   []
};

// Inizializza stats con la forma completa così Feather conosce i tipi
global.stats = {
    totale:         0,
    vittorie:       0,
    sconfitte:      0,
    pareggi:        0,
    per_modalita:   {},
    per_mazzo:      {},
    per_avversario: {}
};

load_lookup();
load_partite();
calc_stats();
