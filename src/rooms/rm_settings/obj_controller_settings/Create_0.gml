// obj_controller_settings  –  Create

_tab        = 0;   // 0 = Modalità  |  1 = Miei mazzi  |  2 = Avversari
_adv_open   = -1;  // indice avversario espanso in tab 2, -1 = nessuno
_scroll     = 0;
_sw         = display_get_gui_width();
_sh         = display_get_gui_height();

// Input campo nome (condiviso tra tab, resettato al cambio tab)
inp_nome    = instance_create_layer(MARGIN, _sh - NAVBAR_HEIGHT - INPUT_HEIGHT - 60, "GUI", obj_input_field);
inp_nome.w  = _sw - MARGIN * 2 - 120;

// Input n_avversari (solo tab 0)
inp_nadv    = instance_create_layer(inp_nome.x + inp_nome.w + GAP, inp_nome.y, "GUI", obj_input_field);
inp_nadv.w  = 60;
inp_nadv.max_len   = 2;
inp_nadv.placeholder = "N";

// Bottone "Aggiungi"
btn_add     = instance_create_layer(_sw - MARGIN - 100, inp_nome.y, "GUI", obj_button);
btn_add.label    = "Aggiungi";
btn_add.w        = 100;
btn_add.style    = "primary";
btn_add.on_click = method(self, function() { _on_add(); });

_update_input_visibility();

// ============================================================
function _update_input_visibility() {
    inp_nadv.enabled = (_tab == 0);
}

function _on_add() {
    var _nome = inp_nome._text;
    switch (_tab) {
        case 0:
            var _n = real(inp_nadv._text);
            if (string_length(_nome) > 0 && _n >= 1) {
                lookup_add_modalita(_nome, _n);
                inp_nome._text  = "";
                inp_nadv._text  = "";
            }
            break;
        case 1:
            if (string_length(_nome) > 0) {
                lookup_add_mio_mazzo(_nome);
                inp_nome._text = "";
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
                inp_nome._text = "";
            }
            break;
    }
}
