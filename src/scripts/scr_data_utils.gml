// ============================================================
//  DATA UTILITIES  –  persistenza JSON
// ============================================================

/// @desc Carica partite.json in global.partite. Crea array vuoto se il file non esiste.
function load_partite() {
    var _path = working_directory + "partite.json";
    if (file_exists(_path)) {
        var _buf  = buffer_load(_path);
        var _json = buffer_read(_buf, buffer_text);
        buffer_delete(_buf);
        var _parsed = json_parse(_json);
        global.partite = is_array(_parsed) ? _parsed : [];
    } else {
        global.partite = [];
    }
}

/// @desc Salva global.partite su partite.json.
function save_partite() {
    var _json = json_stringify(global.partite, true);
    var _buf  = buffer_create(string_byte_length(_json) + 1, buffer_fixed, 1);
    buffer_write(_buf, buffer_text, _json);
    buffer_save(_buf, working_directory + "partite.json");
    buffer_delete(_buf);
}

/// @desc Carica lookup.json in global.lookup. Genera dati default se il file non esiste.
function load_lookup() {
    var _path = working_directory + "lookup.json";
    if (file_exists(_path)) {
        var _buf  = buffer_load(_path);
        var _json = buffer_read(_buf, buffer_text);
        buffer_delete(_buf);
        global.lookup = json_parse(_json);
    } else {
        global.lookup = _lookup_defaults();
        save_lookup(); // Persiste subito i default
    }
}

/// @desc Salva global.lookup su lookup.json.
function save_lookup() {
    var _json = json_stringify(global.lookup, true);
    var _buf  = buffer_create(string_byte_length(_json) + 1, buffer_fixed, 1);
    buffer_write(_buf, buffer_text, _json);
    buffer_save(_buf, working_directory + "lookup.json");
    buffer_delete(_buf);
}

/// @desc Ritorna lo struct lookup con i dati storici pre-compilati.
function _lookup_defaults() {
    return {
        miei_mazzi: [
            "Merfolk", "Bambolette", "Warriors", "Energie", "Radiazioni",
            "Urza", "Quick Draw", "Sprona", "Eldrazi", "Zombie",
            "Uccelli", "Energie Fallout", "Dr. Who", "Rohan", "Aragorn",
            "Endless", "Miracle", "Manifest", "Ribelli", "Muri"
        ],
        avversari: [
            {
                nome:  "Matteo",
                mazzi: ["Death Toll","Sliver","Miracoli","Detective",
                        "Endless","Muri","Mardu","Temur","Sultai","Jeskai"]
            },
            {
                nome:  "Fabrizio",
                mazzi: ["Bloomburrow","Obscura","Compagnia","Vampiri",
                        "Blitz","Necron","Cavalieri","Mardu"]
            },
            {
                nome:  "Sandro",
                mazzi: ["Draghi","Dogmeat","Orso"]
            },
            {
                nome:  "Daniele",
                mazzi: ["Dinosauri","Angeli","Sauron","Elfi","Wurm","Gonti",
                        "Bloomburrow","Draghi","Elfi Mono","Ezio","Muri","Mardu"]
            },
            {
                nome:  "Poppy",
                mazzi: ["Counter","Blitz","Manifest","Equip","Infect",
                        "Orrori","Dread","Piantine","Cavalieri","Temur"]
            }
        ],
        modalita: [
            { nome: "1v1",          n_avversari: 1 },
            { nome: "3 FFA",        n_avversari: 2 },
            { nome: "4 FFA",        n_avversari: 3 },
            { nome: "5 Obbiettivo", n_avversari: 4 }
        ]
    };
}

// ============================================================
//  OPERAZIONI SU PARTITE
// ============================================================

/// @desc Aggiunge una partita, assegna id progressivo e salva. Ritorna la partita.
/// @param {struct} partita
function aggiungi_partita(partita) {
    partita.id = array_length(global.partite) + 1;
    array_push(global.partite, partita);
    save_partite();
    return partita;
}

/// @desc Rimuove la partita con l'id dato e salva.
/// @param {real} id
function rimuovi_partita(id) {
    var _new = [];
    for (var i = 0; i < array_length(global.partite); i++) {
        if (global.partite[i].id != id) array_push(_new, global.partite[i]);
    }
    global.partite = _new;
    save_partite();
}

// ============================================================
//  OPERAZIONI SU LOOKUP
// ============================================================

/// @desc Aggiunge un mazzo alla lista miei_mazzi se non esiste già.
/// @param {string} nome
function lookup_add_mio_mazzo(nome) {
    nome = string_trim(nome);
    if (nome == "") return;
    var _list = global.lookup.miei_mazzi;
    for (var i = 0; i < array_length(_list); i++) {
        if (_list[i] == nome) return;
    }
    array_push(global.lookup.miei_mazzi, nome);
    save_lookup();
}

/// @desc Rimuove un mazzo dalla lista miei_mazzi.
/// @param {string} nome
function lookup_remove_mio_mazzo(nome) {
    var _new = [];
    var _list = global.lookup.miei_mazzi;
    for (var i = 0; i < array_length(_list); i++) {
        if (_list[i] != nome) array_push(_new, _list[i]);
    }
    global.lookup.miei_mazzi = _new;
    save_lookup();
}

/// @desc Aggiunge un avversario se non esiste già.
/// @param {string} nome
function lookup_add_avversario(nome) {
    nome = string_trim(nome);
    if (nome == "") return;
    var _list = global.lookup.avversari;
    for (var i = 0; i < array_length(_list); i++) {
        if (_list[i].nome == nome) return;
    }
    array_push(global.lookup.avversari, { nome: nome, mazzi: [] });
    save_lookup();
}

/// @desc Rimuove un avversario per nome.
/// @param {string} nome
function lookup_remove_avversario(nome) {
    var _new = [];
    var _list = global.lookup.avversari;
    for (var i = 0; i < array_length(_list); i++) {
        if (_list[i].nome != nome) array_push(_new, _list[i]);
    }
    global.lookup.avversari = _new;
    save_lookup();
}

/// @desc Aggiunge un mazzo a un avversario specifico.
/// @param {string} nome_avversario
/// @param {string} nome_mazzo
function lookup_add_mazzo_avversario(nome_avversario, nome_mazzo) {
    nome_mazzo = string_trim(nome_mazzo);
    if (nome_mazzo == "") return;
    var _list = global.lookup.avversari;
    for (var i = 0; i < array_length(_list); i++) {
        if (_list[i].nome == nome_avversario) {
            for (var j = 0; j < array_length(_list[i].mazzi); j++) {
                if (_list[i].mazzi[j] == nome_mazzo) return;
            }
            array_push(_list[i].mazzi, nome_mazzo);
            save_lookup();
            return;
        }
    }
}

/// @desc Rimuove un mazzo da un avversario specifico.
/// @param {string} nome_avversario
/// @param {string} nome_mazzo
function lookup_remove_mazzo_avversario(nome_avversario, nome_mazzo) {
    var _list = global.lookup.avversari;
    for (var i = 0; i < array_length(_list); i++) {
        if (_list[i].nome == nome_avversario) {
            var _new_mazzi = [];
            for (var j = 0; j < array_length(_list[i].mazzi); j++) {
                if (_list[i].mazzi[j] != nome_mazzo) array_push(_new_mazzi, _list[i].mazzi[j]);
            }
            _list[i].mazzi = _new_mazzi;
            save_lookup();
            return;
        }
    }
}

/// @desc Aggiunge una modalità se non esiste già.
/// @param {string} nome
/// @param {real}   n_avversari
function lookup_add_modalita(nome, n_avversari) {
    nome = string_trim(nome);
    if (nome == "") return;
    var _list = global.lookup.modalita;
    for (var i = 0; i < array_length(_list); i++) {
        if (_list[i].nome == nome) return;
    }
    array_push(global.lookup.modalita, { nome: nome, n_avversari: n_avversari });
    save_lookup();
}

/// @desc Rimuove una modalità per nome.
/// @param {string} nome
function lookup_remove_modalita(nome) {
    var _new = [];
    var _list = global.lookup.modalita;
    for (var i = 0; i < array_length(_list); i++) {
        if (_list[i].nome != nome) array_push(_new, _list[i]);
    }
    global.lookup.modalita = _new;
    save_lookup();
}

/// @desc Ritorna l'indice dell'avversario nel lookup, o -1 se non trovato.
/// @param {string} nome
function lookup_find_avversario(nome) {
    var _list = global.lookup.avversari;
    for (var i = 0; i < array_length(_list); i++) {
        if (_list[i].nome == nome) return i;
    }
    return -1;
}

/// @desc Ritorna i mazzi di un avversario come array, o [] se non trovato.
/// @param {string} nome
function lookup_get_mazzi_avversario(nome) {
    var _idx = lookup_find_avversario(nome);
    if (_idx < 0) return [];
    return global.lookup.avversari[_idx].mazzi;
}
