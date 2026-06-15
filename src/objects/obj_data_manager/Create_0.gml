// obj_data_manager  –  Create
// Proprietà: Persistent = true
// Posizionato in rm_menu (prima room). Sopravvive a tutti i cambi di room.

global.partite = [];
global.lookup  = {};
global.stats   = {};

load_lookup();
load_partite();
calc_stats();
