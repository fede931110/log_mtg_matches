// obj_controller_settings  –  Create

_tab            = 0;   // 0 = Modalita'  |  1 = Miei mazzi  |  2 = Avversari
_adv_open       = -1;  // indice avversario espanso in tab 2, -1 = nessuno
_scroll         = 0;
_pending_delete = undefined;
_sw         = display_get_gui_width();
_sh         = display_get_gui_height();

// Input, bottone e dropdown: posizioni iniziali fuori schermo,
// vengono riposizionati ogni frame dal Draw in base al layout 50/50.
inp_nome      = instance_create_layer(0, -200, "GUI", obj_input_field);
inp_nome.w    = _sw - MARGIN * 2 - GAP - 100;

btn_add          = instance_create_layer(0, -200, "GUI", obj_button);
btn_add.label    = "Aggiungi";
btn_add.w        = 100;
btn_add.style    = "primary";
btn_add.on_click = method(self, function() { _on_add(); });

dd_adv_sel = instance_create_layer(-9999, -200, "GUI", obj_dropdown);
dd_adv_sel.w       = _sw - MARGIN * 2;
dd_adv_sel.placeholder = "Seleziona avversario...";
dd_adv_sel.on_change   = method(id, function(idx, val) {
    _adv_open = idx - 1;  // idx 0 = "+ Nuovo avversario" → _adv_open=-1
});

// ============================================================
function _on_add() {
    var _nome = inp_nome._text;
    switch (_tab) {
        case 0:
            if (string_length(_nome) > 0) {
                lookup_add_modalita(_nome, 1);
                inp_nome._text  = "";
                keyboard_string = "";
            }
            break;
        case 1:
            if (string_length(_nome) > 0) {
                lookup_add_mio_mazzo(_nome);
                inp_nome._text  = "";
                keyboard_string = "";
            }
            break;
        case 2:
            if (string_length(_nome) > 0) {
                if (_adv_open >= 0) {
                    var _adv = global.lookup.avversari[_adv_open].nome;
                    lookup_add_mazzo_avversario(_adv, _nome);
                } else {
                    lookup_add_avversario(_nome);
                }
                inp_nome._text  = "";
                keyboard_string = "";
            }
            break;
    }
}
