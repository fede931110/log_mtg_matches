// ============================================================
//  COLORS  (make_colour_rgb converte automaticamente in BGR)
// ============================================================
#macro COL_BG            make_colour_rgb(44,  31,  20)   // #2C1F14  legno scuro
#macro COL_SURFACE       make_colour_rgb(245, 230, 200)  // #F5E6C8  pergamena chiara
#macro COL_SURFACE_ALT   make_colour_rgb(237, 217, 163)  // #EDD9A3  pergamena scura (hover, righe alt)
#macro COL_BORDER        make_colour_rgb(160, 132, 92)   // #A0845C  cuoio
#macro COL_INK           make_colour_rgb(30,  18,  9)    // #1E1209  inchiostro quasi nero
#macro COL_INK_FADED     make_colour_rgb(107, 79,  53)   // #6B4F35  inchiostro sbiadito
#macro COL_GOLD          make_colour_rgb(201, 151, 42)   // #C9972A  oro
#macro COL_GOLD_DARK     make_colour_rgb(139, 105, 20)   // #8B6914  oro scuro
#macro COL_WIN           make_colour_rgb(58,  107, 42)   // #3A6B2A  verde vittoria
#macro COL_LOSS          make_colour_rgb(139, 26,  26)   // #8B1A1A  rosso sconfitta
#macro COL_DRAW          make_colour_rgb(107, 92,  62)   // #6B5C3E  marrone pareggio
#macro COL_BTN_PRIMARY   make_colour_rgb(107, 39,  55)   // #6B2737  borgogna principale
#macro COL_BTN_HOVER     make_colour_rgb(139, 51,  72)   // #8B3348  borgogna hover
#macro COL_BTN_SECONDARY make_colour_rgb(61,  43,  31)   // #3D2B1F  marrone scuro secondario

// ============================================================
//  LAYOUT
// ============================================================
#macro MARGIN          24    // margine dai bordi schermo
#macro GAP             12    // gap tra elementi
#macro CORNER_RADIUS    6    // raggio angoli arrotondati
#macro NAVBAR_HEIGHT   56    // altezza barra navigazione inferiore
#macro BTN_HEIGHT      40    // altezza bottoni standard
#macro BTN_PADDING_X   16    // padding orizzontale bottoni
#macro INPUT_HEIGHT    36    // altezza campi input/dropdown
#macro ROW_HEIGHT      48    // altezza riga storico partite
#macro TAB_HEIGHT      40    // altezza tab in rm_settings

// ============================================================
//  ROOM IDs (alias leggibili usati in draw_navbar)
// ============================================================
#macro ROOM_MENU      0
#macro ROOM_LOG       1
#macro ROOM_HISTORY   2
#macro ROOM_STATS     3
#macro ROOM_SETTINGS  4
