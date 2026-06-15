# Analisi App "Log MTG Matches" – GameMaker

## Cosa fa l'Excel

Il file `partite_magic.xlsx` è un tracker di partite di Magic: The Gathering con tre fogli:

| Foglio | Scopo |
|---|---|
| `Dati_Partite` | Registro cronologico di ogni partita giocata (61 partite al momento) |
| `Lookup` | Liste di valori validi (tipi partita, mazzi, avversari) |
| `Supporto_Date` | Date di supporto generate automaticamente |

### Struttura di ogni partita registrata

| Campo | Valori possibili |
|---|---|
| Data | gg/mm/aaaa |
| Tipo partita | `1v1`, `3 FFA`, `4 FFA`, `5 Obbiettivo` |
| Risultato | `W` (vinto), `L` (perso), `D` (pari) |
| Mio mazzo | 20 mazzi (Merfolk, Bambolette, Warriors, Energie, …) |
| Avversario 1–4 | Matteo, Fabrizio, Sandro, Daniele, Poppy |
| Mazzo Avversario 1–4 | Lista specifica per ogni avversario |

### Statistiche calcolate dall'Excel

- Partite totali, vittorie, sconfitte globali
- Win/Loss suddivisi per tipo di partita (1v1, 3 FFA, 4 FFA)

---

## Architettura dell'App in GameMaker

GameMaker non è un tool da database, ma gestisce benissimo questo tipo di app con rooms separate, draw GUI e file I/O in JSON.

### Rooms (schermate)

```
rm_menu         → Schermata principale (dashboard rapida)
rm_log_match    → Inserisci nuova partita
rm_history      → Storico partite con filtri
rm_stats        → Statistiche aggregate
rm_settings     → Gestione mazzi e avversari (lista Lookup)
```

---

## Modello dati

### Struttura di una partita (JSON)

```json
{
  "id": 1,
  "data": "23/11/2024",
  "tipo": "1v1",
  "risultato": "W",
  "mio_mazzo": "Warriors",
  "avversari": [
    { "nome": "Matteo", "mazzo": "Death Toll" }
  ]
}
```

Il numero di avversari varia in base al tipo di partita:
- `1v1` → 1 avversario
- `3 FFA` → 2 avversari
- `4 FFA` → 3 avversari
- `5 Obbiettivo` → 4 avversari

### Persistenza

Un singolo file `partite.json` nella cartella dati dell'app (`working_directory`), caricato all'avvio e salvato ad ogni modifica.

```gml
// Salvataggio
var _json = json_stringify(global.partite_array);
var _file = file_text_open_write("partite.json");
file_text_write_string(_file, _json);
file_text_close(_file);
```

### Struttura lookup.json

Tutte le liste configurabili dall'utente vivono in un file separato `lookup.json`, caricato all'avvio e riscritto ad ogni modifica da Settings.

```json
{
  "miei_mazzi": ["Merfolk", "Bambolette", "Warriors", "Energie", "..."],
  "avversari": [
    {
      "nome": "Matteo",
      "mazzi": ["Death Toll", "Sliver", "Miracoli", "Detective", "..."]
    },
    {
      "nome": "Fabrizio",
      "mazzi": ["Bloomburrow", "Obscura", "Compagnia", "..."]
    }
  ],
  "modalita": [
    { "nome": "1v1",          "n_avversari": 1 },
    { "nome": "3 FFA",        "n_avversari": 2 },
    { "nome": "4 FFA",        "n_avversari": 3 },
    { "nome": "5 Obbiettivo", "n_avversari": 4 }
  ]
}
```

Il campo `n_avversari` è fondamentale: dice a `rm_log_match` quanti slot avversario aprire. Aggiungere una nuova modalità (es. "Commander 6 giocatori") significa aggiungere un oggetto con `"n_avversari": 5` — tutto il resto si adatta automaticamente.

### Liste Lookup (in memoria)

```gml
// Inizializzate in obj_data_manager dopo aver letto lookup.json
global.miei_mazzi = [];          // array di stringhe
global.avversari  = [];          // array di struct { nome, mazzi[] }
global.modalita   = [];          // array di struct { nome, n_avversari }
```

---

## Dettaglio Schermate

### rm_menu – Dashboard

Mostra subito le statistiche più utili:

```
┌─────────────────────────────────┐
│  LOG MTG MATCHES                │
│─────────────────────────────────│
│  Partite totali: 61             │
│  Vittorie: 41  |  Sconfitte: 20 │
│─────────────────────────────────│
│  1v1    →  W:22  L:6            │
│  3 FFA  →  W:11  L:9            │
│  4 FFA  →  W:?   L:?            │
│─────────────────────────────────│
│  [+ Nuova Partita]              │
│  [Storico]  [Stats]  [Settings] │
└─────────────────────────────────┘
```

### rm_log_match – Inserisci partita

Flusso guidato a step (cambiano le opzioni in base alle scelte):

1. **Data** – auto-compilata con oggi, modificabile con +/- giorno
2. **Tipo partita** – bottoni generati dinamicamente da `global.modalita` (non hardcoded)
3. **Risultato** – bottoni: `W` / `L` / `D`
4. **Mio mazzo** – lista scrollabile dei 20 mazzi
5. **Avversari** – N slot aperti in base al tipo (1→4 slot), ognuno con:
   - Dropdown nome avversario
   - Dropdown mazzo (filtrato in base all'avversario scelto)
6. **Conferma** – bottone "Salva Partita"

Implementazione UI consigliata: sprite per bottoni + `draw_text` + variabile `step_corrente` che controlla cosa viene disegnato.

### rm_history – Storico

Lista scrollabile di tutte le partite, con filtri in cima:

```
Filtri: [Tipo ▼] [Risultato ▼] [Mazzo ▼] [Avversario ▼]

23/11/2024  1v1   W   Warriors   vs Matteo (Death Toll)
23/11/2024  1v1   L   Warriors   vs Matteo (Death Toll)
24/11/2024  1v1   W   Eldrazi    vs Sandro (Draghi)
…
```

- Click su una riga → dettaglio / possibilità di eliminare la partita
- Scroll con rotella mouse o touch drag

### rm_stats – Statistiche

Viste aggregate calcolate al volo dall'array partite:

**Per tipo di partita**
| Tipo | Partite | W | L | Win% |
|---|---|---|---|---|
| 1v1 | 28 | 22 | 6 | 78% |
| 3 FFA | 20 | 11 | 9 | 55% |
| 4 FFA | 10 | … | … | … |

**Per mio mazzo** (top 5 mazzi usati, win%)

**Per avversario** (record contro ognuno)

### rm_settings – Gestione Lookup

Schermata con tre tab/sezioni navigabili:

**Tab 1 — Modalità di gioco**
```
Modalità esistenti:
  1v1           (1 avversario)   [Elimina]
  3 FFA         (2 avversari)    [Elimina]
  4 FFA         (3 avversari)    [Elimina]
  5 Obbiettivo  (4 avversari)    [Elimina]

[+ Aggiungi modalità]
  Nome: [_____________]
  Numero avversari: [ - ] 3 [ + ]
  [Salva]
```

Il campo "numero avversari" controlla direttamente quanti slot si aprono in `rm_log_match`. Non serve toccare altro codice.

**Tab 2 — I miei mazzi**
```
Mazzi attuali:
  Merfolk       [Elimina]
  Bambolette    [Elimina]
  Warriors      [Elimina]
  …

[+ Aggiungi mazzo]
  Nome: [_____________]  [Salva]
```

**Tab 3 — Avversari e i loro mazzi**
```
Avversari:
  ▶ Matteo     [Elimina avversario]
      Death Toll    [Elimina mazzo]
      Sliver        [Elimina mazzo]
      …
      [+ Aggiungi mazzo a Matteo]

  ▶ Fabrizio   [Elimina avversario]
      …

[+ Aggiungi avversario]
  Nome: [_____________]  [Salva]
```

Eliminare un avversario non cancella le partite già registrate con lui — il nome rimane salvato nel JSON storico, sparisce solo dalla lista di scelta futura.

Ogni modifica chiama immediatamente `salva_lookup()` in `obj_data_manager`.

---

## Design UI – Stile Pergamena Moderno

L'obiettivo è un'estetica che evochi il cartone invecchiato, l'inchiostro e i sigilli di cera, ma con layout pulito e leggibile — niente decorazioni kitsch, solo colori e forme.

---

### Palette colori

| Token | Hex | Uso |
|---|---|---|
| `COL_BG` | `#2C1F14` | Sfondo globale (marrone molto scuro, come legno stagionato) |
| `COL_SURFACE` | `#F5E6C8` | Superficie pannelli/card (pergamena chiara) |
| `COL_SURFACE_ALT` | `#EDD9A3` | Pergamena leggermente più scura (righe alternate, hover) |
| `COL_BORDER` | `#A0845C` | Bordi pannelli e separatori (cuoio) |
| `COL_INK` | `#1E1209` | Testo primario (inchiostro quasi nero) |
| `COL_INK_FADED` | `#6B4F35` | Testo secondario/hint (inchiostro sbiadito) |
| `COL_GOLD` | `#C9972A` | Accento dorato — titoli, bordi decorativi, icone |
| `COL_GOLD_DARK` | `#8B6914` | Oro scuro — ombre decorative, bordo bottoni attivi |
| `COL_WIN` | `#3A6B2A` | Verde pergamena — esito W, badge vittoria |
| `COL_LOSS` | `#8B1A1A` | Rosso sigillo — esito L, badge sconfitta |
| `COL_DRAW` | `#6B5C3E` | Marrone neutro — esito D |
| `COL_BTN_PRIMARY` | `#6B2737` | Borgogna — bottone principale (es. "Salva Partita") |
| `COL_BTN_HOVER` | `#8B3348` | Borgogna chiaro — hover bottone primario |
| `COL_BTN_SECONDARY` | `#3D2B1F` | Marrone scuro — bottoni secondari/navigazione |

In GameMaker i colori si definiscono come costanti macro:
```gml
#macro COL_BG       0x142129   // GML usa BGR invertito: converte #2C1F14
#macro COL_SURFACE  0xC8E6F5
// oppure usa make_colour_rgb(r, g, b) per leggibilità
#macro COL_SURFACE  make_colour_rgb(245, 230, 200)
```

---

### Tipografia

GameMaker usa font come asset. Servono **due font** caricati come sprite-font o TTF:

| Font asset | Stile suggerito | Uso |
|---|---|---|
| `fnt_title` | Serif elegante (es. *IM Fell English*, *Cormorant Garamond*) — bold, 28–36px | Titoli schermata, nome app |
| `fnt_body` | Sans-serif pulita (es. *Lato*, *Inter*) — regular, 16–20px | Testo normale, dati |
| `fnt_body_bold` | Stessa family, bold | Etichette, intestazioni tabelle |
| `fnt_small` | `fnt_body` a 13px | Date, hint, testo secondario |

Il contrasto inchiostro su pergamena (`COL_INK` su `COL_SURFACE`) è alto e leggibile. Evita testo chiaro su sfondo chiaro.

---

### Componenti UI

#### Pannello / Card

```
╔══════════════════════════════════════╗   ← bordo COL_GOLD (2px)
║                                      ║   ← fill COL_SURFACE
║   Contenuto                          ║
║                                      ║
╚══════════════════════════════════════╝
```

Angoli arrotondati raggio 6px. Ombra esterna: rettangolo offset +3,+3 in `COL_BG` con alpha 0.4, disegnato prima del pannello.

```gml
// Funzione draw_panel(x1, y1, x2, y2)
draw_set_colour(COL_BG);
draw_set_alpha(0.4);
draw_roundrect(x1+3, y1+3, x2+3, y2+3, 6, 6, false);
draw_set_alpha(1);
draw_set_colour(COL_SURFACE);
draw_roundrect(x1, y1, x2, y2, 6, 6, false);
draw_set_colour(COL_GOLD);
draw_roundrect(x1, y1, x2, y2, 6, 6, true); // true = solo bordo
```

#### Bottone primario (es. "Salva Partita")

- Fill: `COL_BTN_PRIMARY` (borgogna)
- Testo: `COL_SURFACE` (pergamena chiara)
- Bordo: `COL_GOLD_DARK`
- Hover: fill → `COL_BTN_HOVER`, leggero scale-up +2px
- Pressed: fill → `COL_BTN_PRIMARY` scurito, offset testo +1,+1

#### Bottone secondario / navigazione

- Fill: `COL_BTN_SECONDARY`
- Testo: `COL_GOLD`
- Bordo: `COL_BORDER`

#### Badge risultato (W / L / D)

Piccolo rettangolo arrotondato inline nella lista partite:

| Risultato | Background | Testo |
|---|---|---|
| W | `COL_WIN` | `COL_SURFACE` |
| L | `COL_LOSS` | `COL_SURFACE` |
| D | `COL_DRAW` | `COL_SURFACE` |

#### Tab (rm_settings)

Tab selezionata: bordo inferiore 3px `COL_GOLD`, testo `COL_INK`, background `COL_SURFACE`.
Tab inattiva: testo `COL_INK_FADED`, background `COL_SURFACE_ALT`.

#### Input di testo

Rettangolo `COL_SURFACE_ALT` con bordo `COL_BORDER`. Focus: bordo `COL_GOLD`. Testo `COL_INK`, cursore `COL_GOLD`.

#### Dropdown

- Lista chiusa: aspetto identico al bottone secondario, freccia ▼ in `COL_GOLD`
- Lista aperta: pannello `COL_SURFACE` che si sovrappone agli elementi sotto, voci con hover `COL_SURFACE_ALT`

---

### Layout generale

```
┌─────────────────────────────────────────────────┐  ← sfondo COL_BG
│                                                 │
│  ┌─── TITOLO SCHERMATA ───────────────────────┐ │  ← titolo COL_GOLD su COL_BG
│  └────────────────────────────────────────────┘ │
│                                                 │
│  ┌─────────────────────────────────────────┐    │  ← pannello COL_SURFACE
│  │                                         │    │
│  │   Contenuto principale                  │    │
│  │                                         │    │
│  └─────────────────────────────────────────┘    │
│                                                 │
│  [ Nav 1 ]  [ Nav 2 ]  [ Nav 3 ]  [ Nav 4 ]    │  ← bottoni secondari in basso
└─────────────────────────────────────────────────┘
```

- Margine globale: 24px dai bordi schermo
- Gap tra elementi: 12px
- Altezza navbar in basso: 56px fissa

---

### Barra di navigazione inferiore (presente in tutte le room tranne rm_log_match)

```
┌──────────┬──────────┬──────────┬──────────┐
│  Dashboard  │  Storico  │   Stats   │ Settings  │
└──────────┴──────────┴──────────┴──────────┘
```

Tab attiva: icona + testo `COL_GOLD`, sottotitolata da linea 3px.
Tab inattiva: icona + testo `COL_INK_FADED`.

---

## Oggetti GameMaker principali

| Oggetto | Ruolo |
|---|---|
| `obj_data_manager` | Persistent, carica/salva JSON, espone dati globali |
| `obj_button` | Bottone generico riutilizzabile (testo, callback, stato hover/selected) |
| `obj_dropdown` | Lista a tendina con scorrimento |
| `obj_match_row` | Riga della storia (una per partita visibile) |
| `obj_stats_panel` | Disegna un pannello statistico |

---

## Flusso dati

```
Avvio app
  └─ obj_data_manager.Create
        ├─ Carica partite.json → global.partite (array)
        └─ Carica lookup.json  → global.mazzi, avversari, …

Inserisci partita
  └─ rm_log_match raccoglie dati
        └─ obj_data_manager.aggiungi_partita(match_struct)
              ├─ array_push(global.partite, match_struct)
              └─ Salva partite.json

Visualizza stats
  └─ rm_stats calcola al volo iterando global.partite
```

---

## Considerazioni tecniche

**Formato data**: Usare stringhe `"gg/mm/aaaa"` per semplicità, oppure salvare come timestamp Unix e formattare alla visualizzazione.

**UI scrollabile**: Tieni un offset `scroll_y` e disegna solo le righe nel viewport (culling manuale) per evitare lag su liste lunghe.

**Gestione avversari multipli**: Dato che il numero varia (1–4), usa un array di struct dentro ogni partita anziché campi fissi `avversario_1`…`avversario_4`.

**Niente database esterno**: Tutto in JSON locale. Per il volume attuale (centinaia di partite) è più che sufficiente e funziona senza dipendenze.

**Portabilità**: Con GameMaker puoi esportare la stessa app su Windows, Android, iOS — utile se vuoi loggare partite dal telefono.

---

## Riepilogo priorità di sviluppo

1. `obj_data_manager` + caricamento/salvataggio `partite.json` e `lookup.json` ← fondamenta
2. `rm_settings` con le tre tab (modalità, mazzi, avversari) ← **va fatto subito**, perché popola i dati usati da tutto il resto
3. `rm_log_match` con flusso a step dinamico ← funzione core
4. `rm_menu` con statistiche base ← valore immediato
5. `rm_history` con lista e filtri ← comfort
6. `rm_stats` con tabelle dettagliate ← nice to have
