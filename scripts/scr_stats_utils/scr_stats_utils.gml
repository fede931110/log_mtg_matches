// ============================================================
//  STATS UTILITIES
// ============================================================

/// @desc Calcola statistiche aggregate da global.partite.
///       Aggiorna global.stats e ritorna lo struct.
/// @return {struct}
function calc_stats() {
    var _s = {
        totale:    0,
        vittorie:  0,
        sconfitte: 0,
        pareggi:   0,
        per_modalita:   {},
        per_mazzo:      {},
        per_avversario: {}
    };

    var _n = array_length(global.partite);
    for (var i = 0; i < _n; i++) {
        var _p = global.partite[i];
        _s.totale++;
        if      (_p.risultato == "W") _s.vittorie++;
        else if (_p.risultato == "L") _s.sconfitte++;
        else                          _s.pareggi++;

        // --- Per modalità ---
        _bucket_add(_s.per_modalita, _p.tipo, _p.risultato);

        // --- Per mazzo ---
        _bucket_add(_s.per_mazzo, _p.mio_mazzo, _p.risultato);

        // --- Per avversario ---
        if (is_array(_p.avversari)) {
            for (var j = 0; j < array_length(_p.avversari); j++) {
                _bucket_add(_s.per_avversario, _p.avversari[j].nome, _p.risultato);
            }
        }
    }

    global.stats = _s;
    return _s;
}

/// @desc Aggiunge un risultato al bucket identificato da `chiave` nello struct `target`.
function _bucket_add(target, chiave, risultato) {
    if (!struct_exists(target, chiave)) {
        target[$ chiave] = { totale: 0, vittorie: 0, sconfitte: 0, pareggi: 0 };
    }
    target[$ chiave].totale++;
    if      (risultato == "W") target[$ chiave].vittorie++;
    else if (risultato == "L") target[$ chiave].sconfitte++;
    else                       target[$ chiave].pareggi++;
}

/// @desc Ritorna win% come stringa (es. "78%"), o "-" se totale == 0.
/// @param {real} vittorie
/// @param {real} totale
/// @return {string}
function win_pct_str(vittorie, totale) {
    if (totale == 0) return "-";
    return string(round(vittorie / totale * 100)) + "%";
}

/// @desc Filtra global.partite in base a criteri opzionali.
///       Passa "" per ignorare un filtro.
/// @param {string} tipo
/// @param {string} risultato
/// @param {string} mazzo
/// @param {string} avversario
/// @return {Array<any>}
function filtra_partite(tipo, risultato, mazzo, avversario) {
    var _out = [];
    var _n   = array_length(global.partite);
    for (var i = 0; i < _n; i++) {
        var _p = global.partite[i];
        if (tipo       != "" && _p.tipo      != tipo)      continue;
        if (risultato  != "" && _p.risultato != risultato) continue;
        if (mazzo      != "" && _p.mio_mazzo != mazzo)     continue;
        if (avversario != "") {
            var _found = false;
            if (is_array(_p.avversari)) {
                for (var j = 0; j < array_length(_p.avversari); j++) {
                    if (_p.avversari[j].nome == avversario) { _found = true; break; }
                }
            }
            if (!_found) continue;
        }
        array_push(_out, _p);
    }
    return _out;
}

/// @desc Ritorna i top N mazzi ordinati per win% (con almeno min_partite partite).
/// @param {real} n          numero di risultati da ritornare
/// @param {real} min_partite soglia minima di partite per essere inclusi
/// @return {Array<Struct>}  array di struct { nome, totale, vittorie, win_pct }
function top_mazzi(n, min_partite) {
    var _list = [];
    var _keys = struct_get_names(global.stats.per_mazzo);
    for (var i = 0; i < array_length(_keys); i++) {
        var _k = _keys[i];
        var _b = global.stats.per_mazzo[$ _k];
        if (_b.totale >= min_partite) {
            var _pct = (_b.totale > 0) ? (_b.vittorie / _b.totale) : 0;
            array_push(_list, { nome: _k, totale: _b.totale, vittorie: _b.vittorie, win_pct: _pct });
        }
    }
    // Ordina per win_pct decrescente (bubble sort — lista piccola)
    for (var a = 0; a < array_length(_list) - 1; a++) {
        for (var b = 0; b < array_length(_list) - a - 1; b++) {
            if (_list[b].win_pct < _list[b+1].win_pct) {
                var _tmp   = _list[b];
                _list[b]   = _list[b+1];
                _list[b+1] = _tmp;
            }
        }
    }
    // Tronca a n
    var _out = [];
    for (var i = 0; i < min(n, array_length(_list)); i++) {
        array_push(_out, _list[i]);
    }
    return _out;
}
