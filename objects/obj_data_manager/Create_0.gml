// obj_data_manager  –  Create
// Proprietà: Persistent = true
// Posizionato in rm_menu (prima room). Sopravvive a tutti i cambi di room.

// GUI virtuale 480×854 — GMS2 scala automaticamente su qualsiasi schermo
display_set_gui_size(480, 854);

global.partite = [];
global.lookup  = {};

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
