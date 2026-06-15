# Log MTG Matches

App desktop per tracciare partite di **Magic: The Gathering**, costruita con GameMaker.  
Sostituisce un foglio Excel con un'interfaccia dedicata, moderna e tematizzata.

---

## Funzionalità

- **Log partita** — registra data, modalità, risultato, mazzo usato e avversari con i loro mazzi
- **Storico** — lista completa delle partite con filtri per modalità, risultato, mazzo e avversario
- **Statistiche** — win rate globale e suddiviso per modalità di gioco, mazzo e avversario
- **Gestione lookup** — aggiungi/rimuovi modalità di gioco, i tuoi mazzi, avversari e i loro mazzi senza toccare il codice

### Modalità di gioco supportate (configurabili)

| Modalità | Giocatori |
|---|---|
| 1v1 | 2 |
| 3 FFA | 3 |
| 4 FFA | 4 |
| 5 Obbiettivo | 5 |
| *aggiungibile da Settings* | *n* |

---

## Stack

- **Engine**: [GameMaker](https://gamemaker.io/) (GML)
- **Persistenza**: JSON locale (`partite.json`, `lookup.json`)
- **Piattaforma target**: Windows (esportabile su Android/iOS)

---

## Struttura del progetto

```
log_mtg_matches/
├── analisi_app_gamemaker.md   # Analisi architettura e design
├── README.md
└── [progetto GameMaker]/
    ├── objects/
    │   ├── obj_data_manager   # Carica/salva JSON, dati globali (persistent)
    │   ├── obj_button         # Bottone generico riutilizzabile
    │   ├── obj_dropdown       # Lista a tendina con scorrimento
    │   ├── obj_match_row      # Riga singola nello storico
    │   └── obj_stats_panel    # Pannello statistiche
    ├── rooms/
    │   ├── rm_menu            # Dashboard con stats rapide
    │   ├── rm_log_match       # Inserimento nuova partita
    │   ├── rm_history         # Storico con filtri
    │   ├── rm_stats           # Statistiche aggregate
    │   └── rm_settings        # Gestione lookup (mazzi, avversari, modalità)
    └── fonts/
        ├── fnt_title          # Serif — titoli
        └── fnt_body           # Sans-serif — testo dati
```

---

## Design

Interfaccia moderna con palette ispirata alla **pergamena medievale**.

| Token | Colore | Uso |
|---|---|---|
| Background | `#2C1F14` | Sfondo globale (legno scuro) |
| Surface | `#F5E6C8` | Pannelli (pergamena chiara) |
| Accent | `#C9972A` | Oro — titoli, bordi, icone |
| Primary | `#6B2737` | Borgogna — bottoni azione |
| Win | `#3A6B2A` | Verde — badge vittoria |
| Loss | `#8B1A1A` | Rosso — badge sconfitta |

---

## Dati

Le partite vengono salvate localmente in `partite.json`:

```json
{
  "id": 1,
  "data": "23/11/2024",
  "tipo": "3 FFA",
  "risultato": "W",
  "mio_mazzo": "Warriors",
  "avversari": [
    { "nome": "Matteo", "mazzo": "Death Toll" },
    { "nome": "Fabrizio", "mazzo": "Bloomburrow" }
  ]
}
```

Le liste configurabili (mazzi, avversari, modalità) vivono in `lookup.json` e si modificano da dentro l'app.

---

## Roadmap

- [x] Analisi architettura e design
- [ ] `obj_data_manager` — persistenza JSON
- [ ] `rm_settings` — gestione lookup
- [ ] `rm_log_match` — inserimento partita
- [ ] `rm_menu` — dashboard statistiche
- [ ] `rm_history` — storico con filtri
- [ ] `rm_stats` — statistiche dettagliate
