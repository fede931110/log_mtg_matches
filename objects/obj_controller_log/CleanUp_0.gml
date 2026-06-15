// obj_controller_log  –  CleanUp
// Distrugge esplicitamente i dropdown avversario creati dinamicamente.
if (variable_instance_exists(self, "_adv_widgets")) {
    for (var i = 0; i < array_length(_adv_widgets); i++) {
        if (instance_exists(_adv_widgets[i].dd_nome))  instance_destroy(_adv_widgets[i].dd_nome);
        if (instance_exists(_adv_widgets[i].dd_mazzo)) instance_destroy(_adv_widgets[i].dd_mazzo);
    }
}
if (instance_exists(btn_avanti))   instance_destroy(btn_avanti);
if (instance_exists(btn_indietro)) instance_destroy(btn_indietro);
if (instance_exists(dd_mazzo))     instance_destroy(dd_mazzo);
